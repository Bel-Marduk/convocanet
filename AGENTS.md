# AGENTS.md — ConvocaNet

Guía compacta para sesiones de OpenCode en este repo. Solo incluye lo que un agente no descubriría con leer 2-3 archivos al azar.

## Estructura del repo (no es un monorepo de paquetes)

El directorio raíz es engañoso. Hay **un único proyecto real** en `convocanet/` (Flutter + Supabase). Lo demás es ruido:

- `convocanet/` — la app Flutter, las Supabase migrations y los Edge Functions. **Todo el trabajo de código va aquí.**
- `index.html`, `styles.css`, `script.js` (raíz) — una landing estática legacy. No se usa en producción; el build real es Flutter Web.
- `Nodoka/`, `2026-05-*.png`, `error scroll.png` — capturas de pantalla y assets sueltos. Ignorar.
- `ARCHITECTURE.md` (raíz) — doc de diseño general (v2). Útil para contexto de alto nivel, pero la fuente de verdad es el código.

## Stack y comandos clave

- **Flutter** 3.24.0 stable (fijado en CI). Dart SDK `>=3.2.0 <4.0.0`.
- **State**: Riverpod. **Routing**: go_router. **Backend**: Supabase (Auth + Postgres + Edge Functions Deno).
- **i18n**: ARB en `convocanet/lib/l10n/app_es.arb` y `app_en.arb`. Toda cadena nueva va en ambos.

Comandos (siempre desde `convocanet/`):

| Tarea | Comando |
|-------|---------|
| Instalar deps | `flutter pub get` |
| Lint / análisis estático (es el "test" de este repo) | `flutter analyze` |
| Build web release | `flutter build web --release --base-href /convocanet/ --dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=…` |
| Build Android APK | `flutter build apk --release` |
| Build iOS (sin codesign) | `flutter build ios --release --no-codesign` |
| Generar código de Riverpod | `dart run build_runner build` |

**No hay `flutter test` en CI.** La cobertura de pruebas es ~0; el "gate" de calidad es `flutter analyze`.

## Supabase — gotchas importantes

- **Las credenciales se inyectan en build** con `--dart-define=SUPABASE_URL=…` / `SUPABASE_ANON_KEY=…`. `.env` y `config.json` están en `.gitignore`. `lib/config/constants.dart` tiene valores placeholder (`YOUR_PROJECT.supabase.co`) que solo se reemplazan en build.
- **Migraciones** en `convocanet/supabase/migrations/`, numeradas `NNN_*.sql`. Se ejecutan a mano desde el SQL Editor de Supabase (no hay CI que las corra). El último archivo es `012_add_rejected_status.sql`.
- Hay dos archivos `011_*.sql` (duplicado por error de nombrado). Si vas a agregar una migración, **no repitas el número**; sigue la secuencia.
- **Toda escritura admin pasa por RPCs SECURITY DEFINER**, no por tabla directa. Las policies de RLS hacen `EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')` que puede devolver 0 filas silenciosamente. Por eso existen:
  - `admin_insert_convocatoria(jsonb) -> uuid`
  - `admin_update_convocatoria(uuid, jsonb)`
  - `admin_delete_convocatoria(uuid)`
  
  El cliente (`lib/services/convocatoria_service.dart`) usa siempre estas RPCs para CRUD de admin. Si agregas una nueva operación admin, crea un RPC equivalente.

## Modelo de `convocatorias` — agregar un status nuevo

El campo `status` tiene CHECK constraint en SQL (`'active' | 'permanent' | 'expired' | 'draft' | 'pending' | 'rejected'`). Para agregar uno:

1. Nueva migration con `ALTER TABLE convocatorias DROP CONSTRAINT … ADD CONSTRAINT …` (ver `012` como plantilla).
2. `lib/models/convocatoria.dart` → getter `isXxx` + case en `statusLabel()`.
3. `lib/screens/admin/manage_convocatorias.dart` → chip de filtro + case en `_getStatusColor()`.
4. `lib/screens/admin/edit_convocatoria_screen.dart` → `DropdownMenuItem` en el selector de Estado.
5. `ConvocatoriaService` → método que use `admin_update_convocatoria`.
6. Decidir si el **scraper debe ignorar** el status nuevo en dedup (`supabase/functions/ai-scraper/index.ts`, `deduplicate()`). Convención: si un admin marca como "no aprobada" con intención de que el agente la re-inserte si reaparece, excluirla con `.neq("status", "rejected")`. Caso contrario, no la excluyas.

Hay un índice único parcial en `source_url` (`WHERE source_url IS NOT NULL AND source_url != ''`) → previene duplicados a nivel DB.

## Cron / automatizaciones

- **`pg_cron` 5:00 UTC** → `expire_old_convocatorias()` (marca como `expired` las `active` con `deadline < CURRENT_DATE`). Definido en `supabase/migrations/010_scraper_fixes.sql`.
- **GitHub Actions `run-scraper.yml`** → 7:00 UTC, llama al edge function `ai-scraper` por HTTP. También disparable manual (`workflow_dispatch`).
- **GitHub Actions `fetch-rates.yml`** → 8:00 UTC, llama al edge function `clever-endpoint` (rates de ECB). El nombre "clever-endpoint" es histórico; no renombrarlo sin actualizar el workflow.

## AdminShell — bug histórico a no repetir

`lib/widgets/admin_shell.dart` envuelve las rutas `/admin/*` vía `ShellRoute`. Ya hubo un bug donde el cuerpo se construía con un `_buildChild()` hardcodeado según `_selectedIndex` en vez de `widget.child`, lo que hacía que los botones que navegan con `context.go(...)` (Editar, Ver, etc.) parecieran no hacer nada — la URL cambiaba pero la pantalla no. **Regla: el body de `AdminShell` siempre debe ser `widget.child`**, nunca un widget construido localmente. El nav rail usa `_updateSelectedIndex()` para resaltar el item correcto leyendo `GoRouterState.of(context).uri.path`.

## Auth / roles

- `lib/providers/auth_provider.dart` expone `authStateProvider`, `currentProfileProvider` y `isAdminProvider`. Todas las rutas `/admin/*` requieren `isAdmin` (chequeado en el redirect de `lib/config/routes.dart` y como guard en `AdminShell`).
- El campo `role` vive en `profiles.role` (CHECK: `'user' | 'admin'`). El admin se promueve actualizando esa fila.

## Despliegue

- Push a `main` → `.github/workflows/deploy.yml` (raíz) construye Flutter Web con `--base-href /convocanet/` y publica a **GitHub Pages** en `https://bel-marduk.github.io/convocanet/`.
- Secrets requeridos en el repo: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`. El deploy usa los dos primeros; los workflows de scraper y rates usan el service role.
- **No hay** `flutter build apk` en CI para deploy automático — el artifact Android solo se genera en `convocanet/.github/workflows/ci.yml` (rama `main`) y queda como artifact descargable.

## Verificación rápida antes de hacer commit

1. `cd convocanet && flutter pub get`
2. `flutter analyze` — debe pasar limpio.
3. Si tocaste Supabase: confirma que la migration nueva no rompe el CHECK constraint ni duplica el `012_*`.
4. Si tocaste el scraper: el comportamiento de dedup debe seguir excluyendo `rejected` (ver convención arriba).
