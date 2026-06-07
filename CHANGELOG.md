# Changelog

Todos los cambios notables en ConvocaNet. Formato basado en [Keep a Changelog](https://keepachangelog.com/es/1.1.0/).

## [Unreleased]

### Added
- Pestaña "No aprobadas" en `manage_convocatorias` con acciones Rechazar / Re-aprobar, filtrable por status.
- Estado `rejected` en el modelo `Convocatoria` con getter `isRejected` y label bilingüe ("No aprobada" / "Not approved").
- Iconos PWA (`web/icons/Icon-192.png`, `Icon-512.png`) para silenciar 404 del manifest.
- `lib/l10n/`: cadenas nuevas bilingües (ES/EN) para las nuevas acciones.
- `AGENTS.md` con guía compacta para futuros agentes.

### Fixed
- **Admin sub-route navigation**: el click en cualquier botón del panel admin (sidebar, "+ Nueva", Editar, Rechazar, Aprobar, Ver) no actualizaba la pantalla aunque la URL cambiaba. Causa raíz: `GoRouterState.of(context).uri.path` no notifica a dependents cuando la URL cambia entre sub-paths que matchean el mismo `GoRoute` wildcard. Fix: `AdminShell` ahora se suscribe directamente a `routerDelegate.addListener()` y cachea la URL en `_cachedLocation`, lo que sí dispara `setState()`.
- **F5 reload redirige a `/dashboard`**: en el redirect de `routes.dart` y en los guards de `AdminShell`, ahora se trata `user != null && profile.value == null && !profile.hasError` como "still loading" en vez de correr el role check, evitando que el admin sea enviado a `/dashboard` durante el gap entre `authState` y `currentProfileProvider` resolviendo.
- **F5 reload queda en spinner infinito (sin redirigir, pero sin mostrar el panel)**: el `currentProfileProvider` se quedaba en `AsyncData(null)` terminal porque la primera query post-recarga corría antes de que el contexto RLS de Supabase terminara de hidratarse (auth.uid() null → 0 filas → null). Tres cambios: (1) `getCurrentProfile({User? user})` acepta el `User` por parámetro para no leer `_client.auth.currentUser` tarde; (2) el provider reintenta 3 veces con 200 ms entre intentos; (3) los guards usan `profile.isLoading || profile.isRefreshing` en vez de `profile.value == null` para distinguir "futuro en vuelo" de "perfil genuinamente ausente" — un null terminal ahora redirige a `/login` en vez de quedar en loop.
- Icono PWA 404 en consola (resuelto al agregar `Icon-192.png` / `Icon-512.png`).
- Bug histórico del AdminShell: el body se construía con un `_buildChild()` hardcodeado por índice en vez de `widget.child` (ya no aplica: ahora AdminShell no recibe `child`, usa IndexedStack interno).

### Changed
- **Refactor AdminShell**: ya no usa `ShellRoute` ni envuelve las sub-rutas admin con builders separados. Ahora hay dos `GoRoute` top-level (`/admin` y `/admin/:path(.*)`) que ambos retornan `const AdminShell()`. AdminShell hace dispatch interno a un `IndexedStack` con los 5 sub-screens principales.
- **Rutas admin son planas** (no anidadas). Si vas a agregar una nueva ruta admin, declárala como `GoRoute(path: '/admin/<ruta>', builder: ...)` top-level. El builder debe retornar `const AdminShell()` (NO un child específico). AdminShell se encarga del dispatch.
- **Refactor redirect**: `routes.dart` ya no devuelve `path` cuando el profile está cargando. Devuelve `null` y deja que los per-screen guards muestren spinner. Esto evita que el redirect "atrape" navegaciones.

### Database
- Migration `012_add_rejected_status.sql`: extiende el CHECK constraint de `convocatorias.status` para incluir `'rejected'`. Actualiza `get_admin_stats()`.
- `ai-scraper/index.ts` `deduplicate()` ahora excluye `status='rejected'` con `.neq("status", "rejected")` para que el agente re-inserte la convocatoria si reaparece en la fuente.

## Notas para contribuidores

- No hay `flutter test` en CI. La cobertura de pruebas es ~0; el "gate" de calidad es `flutter analyze`.
- Si agregas un status nuevo a `convocatorias.status`, sigue el checklist en `AGENTS.md` § "Modelo de convocatorias — agregar un status nuevo".
- Toda escritura admin pasa por RPCs `SECURITY DEFINER` (ver `AGENTS.md` § "Supabase — gotchas importantes").
- Hay dos archivos `011_*.sql` huérfanos; no commitees sobre el número `011`. El último en repo es `012`.
