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

## AdminShell — implementación y bugs históricos

`lib/widgets/admin_shell.dart` es un `ConsumerStatefulWidget` (no `ShellRoute` ni `StatefulShellRoute`) que cubre **todas** las rutas `/admin/*` mediante un único `GoRoute` wildcard:

```dart
GoRoute(
  path: '/admin',
  builder: (context, state) => const AdminShell(),
),
GoRoute(
  path: '/admin/:path(.*)',
  builder: (context, state) => const AdminShell(),
),
```

**Cómo decide qué sub-pantalla mostrar:** lee la URL cacheada (`_cachedLocation`, actualizada por un listener en `routerDelegate`) y construye un `IndexedStack` con los 5 sub-screens principales. Las rutas `/admin/convocatorias/new` y `/admin/convocatorias/:id/edit` se renderizan como `EditConvocatoriaScreen` standalone (reemplazan el `IndexedStack`, no se preserva state).

### Bug histórico #1 — body hardcodeado por índice
Hubo un bug donde el cuerpo se construía con un `_buildChild()` hardcodeado según `_selectedIndex` en vez de `widget.child`, lo que hacía que los botones que navegan con `context.go(...)` (Editar, Ver, etc.) parecieran no hacer nada — la URL cambiaba pero la pantalla no. **Regla superada:** en la versión actual NO existe `widget.child`. El body se construye internamente basado en la URL.

### Bug histórico #2 — `GoRouterState.of(context).uri.path` no dispara rebuilds con wildcard
Cuando un `GoRoute` wildcard (`/admin/:path(.*)`) tiene un `builder` que retorna el mismo widget para todos los sub-paths, **`GoRouterState.of(context).uri.path` no notifica a los dependents cuando la URL cambia entre sub-paths que matchean el mismo GoRoute**. El InheritedWidget interno de go_router no se actualiza porque el route matcheado es el mismo.

**Síntoma:** click en el sidebar → URL cambia → redirect corre → pero el `build` del AdminShell no se llama → el `IndexedStack` no cambia de índice → la pantalla no se actualiza.

**Fix (en `admin_shell.dart`):** subscribirse directamente al `routerDelegate.addListener()` (que SÍ es un `ChangeNotifier` y dispara en cada navegación) y llamar `setState()` con la nueva URL cacheada. Ver `_AdminShellState.didChangeDependencies` y `_onRouterChange`.

### Bug histórico #3 — race condition en profile reload
Al recargar la página en `/admin`, el `authStateProvider` resuelve antes que `currentProfileProvider` (que se invalida y re-fetcha). Durante ese gap, `profile.value` puede ser `null` y `isAdminProvider` devuelve `false` → redirect manda al admin a `/dashboard`.

**Fix (en `routes.dart` redirect y en `AdminShell` build):** guard explícito: si `user != null && profile.value == null && !profile.hasError`, tratar como "still loading" y NO correr el role check. Ver el bloque marcado "RACE CONDITION GUARD" en ambos archivos.

## Auth / roles

- `lib/providers/auth_provider.dart` expone `authStateProvider`, `currentProfileProvider` y `isAdminProvider`. Todas las rutas `/admin/*` requieren `isAdmin` (chequeado en el redirect de `lib/config/routes.dart` y como guard en `AdminShell`).
- El campo `role` vive en `profiles.role` (CHECK: `'user' | 'admin'`). El admin se promueve actualizando esa fila.

### Bug histórico #4 — perfil se queda en `AsyncData(null)` al refrescar `/admin`
Síntoma reportado: tras un F5 sobre `https://bel-marduk.github.io/convocanet/#/admin`, la pantalla queda en spinner infinito y el log de consola muestra un único `[REDIRECT] path=/admin isLoggedIn=true` sin re-emisiones posteriores.

Causa: en el ciclo de hidratación de Supabase post-recarga, el `authStateProvider` emite la sesión antes de que (a) `currentUserProvider` propague el `User` y (b) el contexto RLS del cliente postgrest esté listo para resolver `auth.uid()`. El primer `select` a `profiles` se dispara con `auth.uid() == null` y devuelve 0 filas. La función `AuthService.getCurrentProfile()` además leía `_client.auth.currentUser` directamente, que podía ser null en ese mismo tick, y devolvía null sin reintentar. El provider quedaba en `AsyncData(null)` terminal, el guard del redirect lo trataba como "loading" para siempre, y la pantalla no avanzaba.

**Fix (3 partes):**

1. `lib/services/auth_service.dart:103` — `getCurrentProfile({User? user})` ahora acepta el `User` por parámetro. Quien llama desde un provider que ya hizo `ref.watch(currentUserProvider)` lo pasa explícitamente y evita la lectura tardía de `_client.auth.currentUser`.
2. `lib/providers/auth_provider.dart:28` — `currentProfileProvider` reintenta hasta 3 veces con 200 ms entre intentos. Cubre el caso "sesión aún no propagada al contexto postgrest". Si tras 3 intentos sigue null, se devuelve null terminal y el caller lo trata como "perfil genuinamente ausente".
3. `lib/config/routes.dart` redirect guard y `lib/widgets/admin_shell.dart` build guard — usan `profile.isLoading || profile.isRefreshing` en vez de `profile.value == null`. Esto distingue el estado transitorio (futuro en vuelo, esperar) del estado terminal (perfil no existe, redirigir a `/login`). `AsyncRefreshing` es la `AsyncValue` que se obtiene cuando un `FutureProvider` se invalida y conserva el valor anterior: en page reload ese valor anterior es `null` (del tick pre-auth), por eso el guard viejo `value == null` lo confundía con "loading" y el nuevo `isRefreshing` lo identifica correctamente.

### Bug histórico #5 — AdminShell secuestra la pantalla al navegar fuera de `/admin/*`
Síntoma: tras click en "Ver" o "Ver sitio" (AppBar `Icons.open_in_new`), la URL cambiaba (`/convocatoria/:id`, `/`) y el redirect corría, pero la pantalla seguía mostrando el dashboard del admin. El `ConvicatoriaDetailScreen` / `LandingScreen` nunca se construían (log: `[REDIRECT] path=/…: profile resolved isAdmin=true` aparecía, pero `initState` de la pantalla destino nunca se logueaba).

Causa raíz: la doble GoRoute wildcard (`/admin` literal + `/admin/:path(.*)`) crea un "wildcard trap" en go_router 14.6.x. El GoRouter no puede pop el AdminShell (built by the wildcard) y push el nuevo top-level GoRoute, así que la nueva ruta nunca se construye. Confirmado vía logs: el redirect retorna `null` (allow), el GoRoute builder de `/convocatoria/:id` nunca se llama, el `dispose` del AdminShell nunca se llama.

**Fix final: rutas "preview" dentro de `/admin/*`.** En vez de navegar a una ruta top-level (`/convocatoria/:id`, `/`) — que activa el wildcard trap — el admin navega a una ruta que matchea el wildcard, y el `AdminShell` la detecta y renderiza la pantalla apropiada en su `build`:

- `/admin/convocatorias/:id/preview` → `AdminShell` retorna `ConvocatoriaDetailScreen(convocatoriaId: <id>)` sin chrome admin (la detail screen tiene su propio AppBar con back button que `context.go('/admin/convocatorias')`).
- `/admin/preview` → `AdminShell` retorna un `Scaffold` con back button a `/admin` y la `LandingScreen` body.

El botón "Ver convocatoria" en `manage_convocatorias.dart` ahora hace `context.go('/admin/convocatorias/<id>/preview')`. El botón "Ver sitio" en `admin_shell.dart` (mobile + desktop) hace `context.go('/admin/preview')`.

**Por qué este patrón (en vez de `StatefulShellRoute.indexedStack`):** se intentó refactorizar al patrón canónico de go_router 14.x (5 branches con `StatefulShellBranch`), pero el `StatefulNavigationShell.currentIndex` no se actualizaba en cambios de URL entre branches — bug confirmado en el log. Workarounds con `shell.goBranch`, `context.go` + listener `setState` también fallaron. El wildcard + preview-routes es la solución que sí funciona con go_router 14.6.x.

**Cómo verificarlo en el log:** click en "Ver" debe loguear `→ [REDIRECT] path=/admin/convocatorias/<id>/preview: profile resolved isAdmin=true` → `→ [DETAIL] initState id=<id>`.

### Bug histórico #6 — spinner timeout 6s manda a `/login` a un admin confirmado

Síntoma: tras un F5 sobre `https://bel-marduk.github.io/convocanet/#/admin`, el log de consola muestra `[PROFILE] loaded on attempt 1, isAdmin=true` (o sea el profile YA cargó), pero ~6 s después la pantalla salta a `/login` aunque el usuario siga autenticado y sea admin.

Causa: tras el primer load exitoso, una re-invalidación de `currentProfileProvider` (típicamente disparada por un `authState` posterior al F5) llevaba al `AsyncValue` a `AsyncRefreshing(value: Profile(admin=true), isRefreshing: true)`. El bloque "isLoading || isRefreshing" del `AdminShell.build` se re-entraba, re-armaba el timer de 6 s (porque se reseteaba `_spinnerTimedOut = false` al final de cada build), y cuando el timer disparaba volvía a chequear `p.isLoading || p.isRefreshing || p.value == null`. Si el re-fetch todavía estaba en vuelo después de 6 s (lo cual pasa en la primera carga post-F5 con red lenta), `p.value == null` se cumplía momentáneamente y mandaba a `/login`.

**Fix (en `admin_shell.dart`):** flag persistente `bool _everLoaded` en `_AdminShellState`. El timer de 6 s solo se arma si `!_everLoaded && !_spinnerTimedOut`. Cuando el profile resuelve con un value no-null en cualquier build, se setea `_everLoaded = true` y nunca más se rearma el timer. Re-fetches posteriores (post-auth, cambios de sesión) muestran el spinner el tiempo que haga falta, pero ya no pueden mandar al admin a `/login`. Adicionalmente, la condición del callback del timer se simplificó a `if (p.value == null)` — un re-fetch lento con `value` preservado ya no es motivo de redirect.

## Despliegue

- Push a `main` → `.github/workflows/deploy.yml` (raíz) construye Flutter Web con `--base-href /convocanet/` y publica a **GitHub Pages** en `https://bel-marduk.github.io/convocanet/`.
- Secrets requeridos en el repo: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`. El deploy usa los dos primeros; los workflows de scraper y rates usan el service role.
- **No hay** `flutter build apk` en CI para deploy automático — el artifact Android solo se genera en `convocanet/.github/workflows/ci.yml` (rama `main`) y queda como artifact descargable.

## Verificación rápida antes de hacer commit

1. `cd convocanet && flutter pub get`
2. `flutter analyze` — debe pasar limpio.
3. Si tocaste Supabase: confirma que la migration nueva no rompe el CHECK constraint ni duplica el `012_*`.
4. Si tocaste el scraper: el comportamiento de dedup debe seguir excluyendo `rejected` (ver convención arriba).
