# ConvocaNet — Arquitectura del Sistema (v2)

> Revisión basada en el estado real del proyecto — Flutter + Supabase ya implementado.

---

## 1. Estado Actual del Proyecto

### Lo que YA existe:

| Componente | Estado | Ubicación |
|-----------|--------|-----------|
| Landing Page estática (HTML/CSS/JS) | Completa | `/index.html`, `/styles.css`, `/script.js` |
| App Flutter (Web + Android + iOS) | ~85% completa | `/convocanet/` |
| Supabase Schema + RLS + Seeds | Completo | `/convocanet/supabase/migrations/` |
| AI Scraper (Edge Function) | Completo | `/convocanet/supabase/functions/ai-scraper/` |
| CI/CD (GitHub Actions) | Completo | `/convocanet/.github/workflows/ci.yml` |
| Autenticación (email + OAuth) | Completa | `/convocanet/lib/services/auth_service.dart` |
| Sistema de idiomas (ES/EN) | Completo | `/convocanet/lib/l10n/` |
| Tema oscuro/claro | Completo | `/convocanet/lib/providers/theme_provider.dart` |
| WhatsApp Service | Completo | `/convocanet/lib/services/whatsapp_service.dart` |
| 15 fuentes de datos configuradas | Completo | `/convocanet/supabase/functions/ai-scraper/sources.ts` |

### Stack actual:
- **Frontend:** Flutter 3.24+ (Dart)
- **State Management:** Riverpod
- **Routing:** GoRouter
- **Backend:** Supabase (Auth, PostgreSQL, Edge Functions)
- **UI:** Material 3, Google Fonts (Inter), flutter_animate
- **Auth:** Supabase Auth + Google Sign-In + Apple Sign-In

---

## 2. Lo que FALTA por Implementar

### Crítico (para lanzamiento MVP):

| # | Tarea | Archivo | Complejidad |
|---|-------|---------|-------------|
| 1 | **Credenciales Supabase reales** | `lib/config/constants.dart` | Baja |
| 2 | **Verificar rol de admin en rutas** | `lib/config/routes.dart:90` | Media |
| 3 | **Cargar convocatorias desde Supabase** (landing) | `lib/screens/landing/convocatorias_section.dart` | COMPLETO |
| 4 | **Cargar convocatorias desde Supabase** (dashboard) | `lib/screens/user/dashboard_screen.dart:91` | COMPLETO |
| 5 | **Pantalla Gestión de Usuarios** | `lib/screens/admin/manage_users.dart` | Alta |
| 6 | **Pantalla Gestión de Mensajes** | `lib/screens/admin/manage_messages.dart` | Media |
| 7 | **Formulario de contacto → Supabase** | `lib/screens/landing/contact_section.dart:36` | COMPLETO |
| 8 | **Logout desde menú de usuario** | `lib/widgets/navbar.dart:132` | Baja |
| 9 | **Abrir WhatsApp desde alertas** | `lib/screens/user/dashboard_screen.dart:211` | Baja |
| 10 | **Scroll suave a contacto desde CTA** | `lib/screens/landing/landing_screen.dart:141` | COMPLETO |

### Importante (post-lanzamiento):

| # | Tarea | Descripción |
|---|-------|-------------|
| 11 | Notificaciones push (FCM/APNs) | Para alertar sobre nuevas convocatorias |
| 12 | Búsqueda de texto completo | Usar la función `search_convocatorias` ya creada |
| 13 | Favoritos desde landing | Permitir guardar sin ir al detalle |
| 14 | Paginación infinita | Scroll infinito en listados |
| 15 | PWA configuration | Service worker para offline |
| 16 | Analytics | PostHog o Supabase Analytics |

---

## 3. Diagrama de Arquitectura Real

```
┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND (Flutter 3.24+)                  │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │  Web (PWA)   │  │   Android    │  │       iOS        │  │
│  │  GitHub Pages │  │   APK/AAB   │  │  TestFlight/IPA  │  │
│  └──────┬───────┘  └──────┬───────┘  └────────┬─────────┘  │
│         └─────────────────┼───────────────────┘             │
│                           │                                  │
│  ┌────────────────────────┼──────────────────────────────┐  │
│  │              Shared Dart Codebase (95%)                │  │
│  │                                                        │  │
│  │  lib/                                                  │  │
│  │  ├── config/     (constants, theme, routes)            │  │
│  │  ├── models/     (Profile, Convocatoria, Category)     │  │
│  │  ├── services/   (Supabase, Auth, Convocatoria, WA)    │  │
│  │  ├── providers/  (Riverpod: auth, theme, locale)       │  │
│  │  ├── screens/    (Landing, Auth, User, Admin, Shared)  │  │
│  │  ├── widgets/    (Cards, Nav, Counters, Toggles)       │  │
│  │  └── l10n/       (ES/EN translations)                  │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│                    BACKEND (Supabase)                         │
│                                                              │
│  ┌───────────┐  ┌──────────────┐  ┌───────────────────────┐ │
│  │   Auth    │  │  PostgreSQL  │  │   Edge Functions      │ │
│  │  (GoTrue) │  │  + RLS       │  │   (Deno/TypeScript)   │ │
│  │           │  │              │  │                       │ │
│  │ • Email   │  │ • profiles   │  │ • ai-scraper          │ │
│  │ • Google  │  │ • convocatorias│ │   (15 fuentes,       │ │
│  │ • Apple   │  │ • categories │  │    Claude API)        │ │
│  └───────────┘  │ • favorites  │  └───────────────────────┘ │
│                 │ • messages   │                             │
│                 │ • audit_log  │  ┌───────────────────────┐ │
│                 └──────────────┘  │   Storage             │ │
│                                   │   (fotos/perfiles)    │ │
│                 ┌──────────────┐  └───────────────────────┘ │
│                 │   Realtime   │                             │
│                 │  (WebSocket) │  ┌───────────────────────┐ │
│                 └──────────────┘  │   pg_cron             │ │
│                                   │   (auto-expire)       │ │
│                                   └───────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│              NOTIFICACIONES (Futuro)                         │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  WhatsApp Business API (Twilio/360dialog)            │   │
│  │  → Envío automático cuando nueva convocatoria        │   │
│  │    coincide con intereses del usuario                │   │
│  │                                                      │   │
│  │  Firebase Cloud Messaging (FCM)                      │   │
│  │  → Push notifications para Android/iOS               │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

---

## 4. Modelo de Datos (Ya Implementado)

```sql
-- Tablas existentes en /convocanet/supabase/migrations/

profiles          → auth.users extendido (nombre, org, teléfono, país, intereses, rol)
categories        → 10 categorías con nombre bilingüe, slug, icono, color
convocatorias     → títulos bilingües, descripción, monto, fecha límite, región, fuente, estatus
user_favorites    → muchos-a-muchos (usuario ↔ convocatoria)
contact_messages  → mensajes del formulario de contacto
audit_log         → registro de acciones administrativas

-- Funciones SQL:
get_dashboard_stats()        → estadísticas para el dashboard
get_matching_convocatorias() → convocatorias según intereses del usuario
search_convocatorias()       → búsqueda de texto completo con filtros

-- Vencimiento automático:
pg_cron → marca convocatorias vencidas diariamente
```

---

## 5. Estrategia de Publicación

### Web (Gratis)

| Servicio | Estado | Notas |
|----------|--------|-------|
| GitHub Pages | **Configurado** | CI/CD ya despliega a gh-pages |
| Vercel | Alternativa | Mejor performance, dominio .vercel.app |
| Netlify | Alternativa | Similar a Vercel |

**Proceso actual:** `git push` → GitHub Actions → `flutter build web` → GitHub Pages

### Android (Gratis - $25)

| Servicio | Estado | Notas |
|----------|--------|-------|
| EAS Build / GitHub Actions | **Configurado** | CI/CD genera APK |
| Google Play Console | Pendiente | $25 USD una vez |
| Distribución directa APK | Gratis | Sin Play Store |

**Proceso:** `flutter build apk` → subir a Play Store o distribuir directamente

### iOS ($99/año obligatorio)

| Servicio | Estado | Notas |
|----------|--------|-------|
| GitHub Actions (macOS) | **Configurado** | Build sin codesign |
| TestFlight | Pendiente | Requiere Apple Developer ($99/año) |
| App Store | Pendiente | Requiere Apple Developer ($99/año) |

**Alternativa gratis:** PWA (app web instalable) — no necesita App Store

---

## 6. Flujos de Usuario (Implementados)

### Flujo de Registro (COMPLETO)
```
Landing → Clic "Registrarse" → Formulario (nombre, email, password,
  organización, teléfono, intereses) → Supabase Auth → Email verificación
  → Dashboard
```

### Flujo de Búsqueda (PARCIAL — falta cargar de Supabase)
```
Dashboard → Explorar convocatorias → Filtros (categoría, país, estatus)
  → Clic en tarjeta → Detalle → Guardar / Compartir WhatsApp
```

### Flujo de Notificación WhatsApp (IMPLEMENTADO servicio, falta trigger automático)
```
Servicio WhatsApp genera link con mensaje formateado →
  url_launcher abre WhatsApp → Usuario envía manualmente
```

### Flujo Admin (PARCIAL — faltan 2 pantallas)
```
Admin Dashboard → Gestionar Convocatorias (CRUD completo)
  → Gestionar Usuarios (TODO)
  → Gestionar Mensajes (TODO)
```

---

## 7. Próximos Pasos Recomendados

### Inmediato (1-2 sesiones):
1. Configurar Supabase real (crear proyecto, obtener URL + anon key)
2. Ejecutar migraciones SQL en Supabase
3. Completar las 10 tareas críticas listadas arriba
4. Probar en web (`flutter run -d chrome`)

### Corto plazo (1 semana):
5. Deploy en GitHub Pages
6. Build APK para Android
7. Configurar dominio custom (opcional)

### Medio plazo (2-3 semanas):
8. Notificaciones WhatsApp automáticas (cron + Edge Function)
9. Push notifications (FCM)
10. Búsqueda de texto completo

---

## 8. Costos

| Item | Costo | Estado |
|------|-------|--------|
| Supabase (Free) | $0 | Listo para usar |
| GitHub Pages | $0 | Ya configurado |
| GitHub Actions | $0 (2000 min/mes) | Ya configurado |
| Google Play | $25 (una vez) | Pendiente |
| Apple Developer | $99/año | Opcional (PWA es gratis) |
| Claude API (scraper) | ~$5-15/mes | Pendiente configurar |
| Dominio custom | ~$10/año | Opcional |
| **Total MVP** | **$0 - $25** | |
| **Total producción** | **~$135/año** | Con iOS |

---

## 9. Arquitectura Original Propuesta vs Realidad

| Aspecto | Propuesta (React+Expo) | Realidad (Flutter) |
|---------|----------------------|-------------------|
| Framework | React + Expo | Flutter 3.24+ |
| State | Zustand + React Query | Riverpod |
| Routing | Expo Router | GoRouter |
| CSS | NativeWind | Material 3 + Google Fonts |
| Backend | Supabase | Supabase ✓ (igual) |
| AI Agent | Claude API | Claude API ✓ (igual) |
| WhatsApp | Twilio | WhatsApp Service (url_launcher) |

**Conclusión:** El proyecto ya está en Flutter y es ~85% funcional. No tiene sentido cambiar a React+Expo. La prioridad debe ser completar el 15% restante y lanzar.
