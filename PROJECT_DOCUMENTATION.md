# Note App — Project Documentation

> A complete reference for the Flutter `note_app` project: structure, scopes, data flow, and recommended next steps.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [High-Level Architecture](#3-high-level-architecture)
4. [Folder Structure](#4-folder-structure)
5. [Scope Details](#5-scope-details)
   - 5.1 [Entry Point](#51-entry-point-libmaindart)
   - 5.2 [Configuration](#52-configuration-libcoreconfig)
   - 5.3 [Constants](#53-constants-libcoreconstants)
   - 5.4 [Theme](#54-theme-libcoretheme)
   - 5.5 [Models](#55-models-libcoremodels)
   - 5.6 [Services](#56-services-libcoreservices)
   - 5.7 [Providers (State)](#57-providers-libcoreproviders)
   - 5.8 [Data Layer](#58-data-layer-libcoredata)
   - 5.9 [Pages (UI)](#59-pages-libcorepresentationpages)
   - 5.10 [Auth Pages](#510-auth-pages-libcorepresentationauth)
   - 5.11 [Localization](#511-localization-libl10n)
6. [App Flow](#6-app-flow)
   - 6.1 [Cold Start Flow](#61-cold-start-flow)
   - 6.2 [Authentication Flow](#62-authentication-flow)
   - 6.3 [Note CRUD Flow](#63-note-crud-flow)
   - 6.4 [Chat Flow](#64-chat-flow)
   - 6.5 [Notification Flow (FCM)](#65-notification-flow-fcm)
   - 6.6 [Theme & Locale Flow](#66-theme--locale-flow)
7. [Backend Map](#7-backend-map)
8. [Known Issues & Half-Finished Items](#8-known-issues--half-finished-items)
9. [New Ideas & Recommendations](#9-new-ideas--recommendations)
10. [Quick File Reference](#10-quick-file-reference)

---

## 1. Project Overview

**Name:** `note_app`
**Type:** Flutter cross-platform note-taking application with chat and notifications
**Platforms supported:** iOS, Android, Web, macOS, Windows, Linux
**Languages:** English (`en`) + Khmer (`km`)
**Version:** `1.0.0+1` (see [pubspec.yaml](pubspec.yaml))

### Core Features
- Note creation, editing, deletion (REST backend)
- Favorites & archive (favorites persisted on backend; archive client-only)
- Real-time 1-on-1 chat (Supabase Realtime + REST messenger)
- User profiles with avatar upload
- FCM push notifications
- Dark/light theme + dynamic primary color
- English/Khmer localization

---

## 2. Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter (Dart `>=3.1.0 <4.0.0`) |
| State management | `provider` ^6.0.5 |
| Auth & Storage (file) | `supabase_flutter` ^2.0.0 |
| Push notifications | `firebase_core`, `firebase_messaging`, `flutter_local_notifications` |
| HTTP | `dio` ^5.4.0 |
| Local DB | `sqflite` ^2.3.0 *(declared but unused — see [§8](#8-known-issues--half-finished-items))* |
| Persistence | `shared_preferences` ^2.2.2 |
| Image picking | `image_picker` ^1.1.2 |
| UI | `google_fonts`, `flutter_staggered_grid_view` |
| Localization | `flutter_localizations`, `intl` ^0.20.2 |

---

## 3. High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                    │
│  Pages (StatelessWidget) ↔ Providers (ChangeNotifier)  │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│                    SERVICE LAYER                        │
│  ApiService(Dio) │ ChatService │ StorageService │ FCM   │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│                    BACKENDS                             │
│  REST API (Render)  │  Supabase  │  Firebase (FCM)     │
└─────────────────────────────────────────────────────────┘
```

The app uses **three backends in parallel**:

1. **Custom REST API** at `https://note-app-backend-1-6y7y.onrender.com` — primary store for notes, user profiles, and async chat messages.
2. **Supabase** — auth (alternative path), realtime chat subscriptions, and avatar file storage.
3. **Firebase** — Cloud Messaging only (FCM tokens, push delivery).

---

## 4. Folder Structure

```
note_app/
├─ android/  ios/  macos/  windows/  linux/  web/   ← platform shells
├─ assets/                                          ← logos, fonts
├─ lib/
│  ├─ main.dart                                    ← entry point
│  ├─ firebase_options.dart                        ← FlutterFire config
│  ├─ l10n/                                        ← ARBs + generated
│  └─ core/
│     ├─ config/        supabase_config.dart
│     ├─ constants/     colors, fonts, dims, enums, languages
│     ├─ theme/         AppTheme + ThemeExtension + context ext
│     ├─ models/        DTOs (notes, chat, user, notification)
│     ├─ services/      API clients, repositories, FCM, store
│     ├─ providers/     ChangeNotifier state holders
│     ├─ data/          custom_auth_service + supabase auth_service
│     ├─ utility/       (empty placeholder)
│     └─ presentation/
│        ├─ auth/       splash + welcome
│        └─ pages/      home, add_note, archive, chat, favorites,
│                       notification, profile, setting, note_view,
│                       main_page.dart
├─ pubspec.yaml
├─ l10n.yaml
└─ scripts/
```

---

## 5. Scope Details

### 5.1 Entry Point ([lib/main.dart](lib/main.dart))

Initialization order:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. **Firebase init** (non-web) → registers `firebaseMessagingBackgroundHandler`, requests permission, calls `ChatNotificationService.instance.init()`
3. **Supabase init** with hardcoded credentials from [supabase_config.dart](lib/core/config/supabase_config.dart)
4. **MultiProvider** wrap with 6 providers:
   - `HelperProvider` — theme/locale/color
   - `HomePageProvider` — notes list state
   - `ChatPageProvider` — chat list state
   - `ArchivePageProvider` — archived notes
   - `NoteDetailPageProvider` — add/edit note
   - `UserProfileProvider` — current user profile
5. `runApp(NoteApp)` → `MaterialApp` whose `home` is `SplashPage`.

`MaterialApp` reads `themeMode`, `locale`, and primary color from `HelperProvider`.

---

### 5.2 Configuration ([lib/core/config/](lib/core/config/))

**[supabase_config.dart](lib/core/config/supabase_config.dart)** exports:
- `supabaseUrl` — `https://mehhjrcssziznafrcxle.supabase.co`
- `supabaseAnonKey` — JWT
- `supabaseAuthRedirectTo` — used for email verification redirect

> ⚠️ Credentials are hardcoded in source. Move to `--dart-define` env or `.env` file before publishing (see [§9](#9-new-ideas--recommendations)).

---

### 5.3 Constants ([lib/core/constants/](lib/core/constants/))

| File | Purpose |
|------|---------|
| `color_constant.dart` | `AppColors` — light/dark palette + 6 note colors + theme-aware helpers |
| `font_constant.dart` | `AppFonts` — Poppins/Inter/JetBrains Mono, 12 sizes, semantic text styles |
| `language_constant.dart` | Supported languages (`en`, `km`) — has minor inconsistency with names list including `zh` |
| `properties_constant.dart` | `AppDimensions` (spacing, radii, durations) + `Responsive` helpers + `Padding` extension |
| `enum_constant.dart` | `DynamicButtonType`, `DynamicButtonSize`, `DialogType`, `DialogSize` |

---

### 5.4 Theme ([lib/core/theme/](lib/core/theme/))

| File | Role |
|------|------|
| `app_theme.dart` | `AppTheme.lightThemeFor(Color)` & `darkThemeFor(Color)` — full `ThemeData` with embedded `AppThemeExtension` |
| `app_theme_extension.dart` | Semantic design tokens (`primaryMuted`, `surfaceElevated`, `iconBlue/Green/...`, `dangerMuted`); implements `lerp()` |
| `app_context_ext.dart` | `BuildContext` extension: `context.appTheme`, `context.isDark`, `context.primaryColor` |

Material 3 is **disabled**; styles defined manually for full control.

---

### 5.5 Models ([lib/core/models/](lib/core/models/))

| Model | File | Key fields |
|-------|------|------------|
| `AuthResponse` / `AuthUser` | `auth_response.dart` | userId, email, name?, accessToken, refreshToken |
| `ChatMessage` | `chat_message.dart` | id, conversationId, senderId, text/imageUrl, status, reactions[], replyTo*, isDeleted |
| `MessageStatus` (enum) | `chat_message.dart` | sending, sent, delivered, read, failed |
| `MessageReaction` | `chat_message.dart` | userId, emoji |
| `Conversation` | `chat_message.dart` | id, user1Id, user2Id, lastMessage* |
| `ChatMessengerMessage` | `chat_messenger_message.dart` | int id, content, messageType, isRead — REST DTO |
| `MessageType` (enum) | `message_type.dart` | text/image/voice + `detectFromContent()` |
| `NoteInfo` | `note_info.dart` | id, name, description, createdAt, updatedAt, userId, isFavorites |
| `NotificationItem` | `notification_item.dart` | id, title, body, receivedAt, senderId, isRead |
| `UserProfile` | `user_profile.dart` | id, name, avatarUrl, email, isNote |

All models implement `fromJson` / `toJson` / `copyWith`.

---

### 5.6 Services ([lib/core/services/](lib/core/services/))

| Service | Pattern | Responsibility |
|---------|---------|----------------|
| `api_service.dart` | Singleton (Dio) | HTTP base client, error mapping (400/401/403/404/422/500), token mgmt, file up/download |
| `note_api_service.dart` | Singleton | Typed `/api/NoteInfo` CRUD + paging + search + favorites filter |
| `note_repository.dart` | Singleton | In-memory cache + client-side archive `Set<int>` + repository over `NoteApiService` |
| `note_services.dart` | — | **Stub**, returns empty list (unused) |
| `chat_service.dart` | Static | **Supabase realtime** chat: `getOrCreateConversation`, `loadMessages`, `sendMessage`, `toggleReaction`, `markRead`, `subscribeToMessages` |
| `chat_messenger_api_service.dart` | Singleton | **REST** `/api/ChatMessenger` for messenger inbox + unread count |
| `user_profile_api_service.dart` | Singleton | `/api/UserProfile` CRUD + `ensureProfile` (idempotent create) |
| `storage_service.dart` | Singleton | Supabase Storage `avatars` bucket upload (jpg/png/webp content-type) |
| `chat_notification_service.dart` | Singleton | FCM listeners + `flutter_local_notifications` channel — suppresses if `activeChatUserId == senderId` |
| `notification_store.dart` | Singleton ChangeNotifier | In-memory list of `NotificationItem` (newest first), `unreadCount`, mark/clear methods — **session only** |

---

### 5.7 Providers ([lib/core/providers/](lib/core/providers/))

| Provider | Role |
|----------|------|
| `auth_provider.dart` | Wraps `CustomAuthService` — `signUp/signIn/signOut/initializeAuth` |
| `helper_provider.dart` | `ThemeMode` + primary `Color` + `Locale`, all persisted to `SharedPreferences`. Static `L10n` defines supported locales. |
| `language_provider.dart` | **Empty stub** (1 line) |
| `service_provider.dart` | **Empty stub** (1 line) |
| `user_profile_provider.dart` | Wraps `UserProfileApiService` — `syncOnLogin/reload/updateProfile` |

> Page-specific providers (HomePage, ChatPage, ArchivePage, NoteDetail, NotificationPage) live alongside their pages under `presentation/pages/<page>/`.

---

### 5.8 Data Layer ([lib/core/data/](lib/core/data/))

- **`services/custom_auth_service.dart`** — REST auth: `/api/auth/signup`, `/api/auth/signin`. Persists `userId`, tokens, name, email to `SharedPreferences`. On `signOut` deletes FCM device record + Firebase token.
- **`supabase/auth_service.dart`** — Supabase-native auth (alternate path, currently used only by `ProfilePage` for user metadata). Exposes `onAuthStateChange()` stream.

---

### 5.9 Pages ([lib/core/presentation/pages/](lib/core/presentation/pages/))

```
SplashPage ──▶ WelcomePage ──▶ MainPage (3-tab IndexedStack)
                                 ├─ [0] HomePage   ─────▶ NoteViewPage ─▶ AddNotePage
                                 ├─ [1] ChatPage   ─────▶ ChatDetailPage
                                 └─ [2] SettingsPage
                                MenuDrawer ──▶ Archive / Favorites / Profile
                                FAB        ──▶ AddNotePage
```

| Page | Purpose | Notes |
|------|---------|-------|
| `main_page.dart` | 3-tab `IndexedStack` + drawer + FAB | Loads profile + notes on init, refreshes FCM token |
| `home_page/` | Grid/list notes, search, sort, favorites filter | Greeting by hour, NoteCard taps → NoteView |
| `chat_page/` | User list with last-message previews + unread badges | `ConversationPreview` per user (last/time/unread) |
| `chat_detail_page.dart` | Realtime conversation | Subscribes via `ChatService.subscribeToMessages` |
| `add_note_page/` | Create/edit note | Has reminder picker UI but no backend support |
| `note_view_page/` | Read-only view with edit/delete | Pops `true` to refresh home |
| `archive_page/` | Archived notes (client-only) | Restore / delete-permanent |
| `favorites_page/` | Favorites view | **Not wired into navigation** |
| `notification_page/` | NotificationStore listing | **Not wired into navigation** |
| `profile_page/` | Profile view + edit (name/avatar/email) | Uses Supabase auth metadata + `UserProfileProvider` |
| `setting_page/` | Theme/color/language/logout | Fade transition on enter |

---

### 5.10 Auth Pages ([lib/core/presentation/auth/](lib/core/presentation/auth/))

- **`splash_page.dart`** — 2.2 s animated logo + tagline; on completion checks `CustomAuthService.getCurrentUser()` and pushes `MainPage` or `WelcomePage`.
- **`welcome_page.dart`** — Login & sign-up entry.

---

### 5.11 Localization ([lib/l10n/](lib/l10n/))

- ARB sources: `app_en.arb`, `app_km.arb`
- Generated: `app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_km.dart`
- Configured by [l10n.yaml](l10n.yaml) and `flutter: generate: true`
- Sample keys: `hello`, `settings`, `darkMode`, `appLanguage`, `notifications`, `addNote`, `chatTitle`, `archive`, `home`, `notificationsTitle`, `logout`, …

---

## 6. App Flow

### 6.1 Cold Start Flow

```
main()
  ├─ Firebase.initializeApp
  ├─ FirebaseMessaging.onBackgroundMessage(handler)
  ├─ FirebaseMessaging.requestPermission()
  ├─ ChatNotificationService.init()    ← local notif channel + foreground listener
  ├─ Supabase.initialize(url, anonKey)
  └─ runApp(MultiProvider → NoteApp → MaterialApp(home: SplashPage))

SplashPage
  ├─ animate 2.2 s
  ├─ CustomAuthService.getCurrentUser()
  └─ → MainPage  (signed in) | WelcomePage (signed out)
```

### 6.2 Authentication Flow

```
WelcomePage  ── signUp/signIn ──▶  CustomAuthService
                                       │
                                       ├─ POST /api/auth/signup or /signin
                                       ├─ stores userId+tokens in SharedPreferences
                                       └─ returns AuthResponse → AuthUser
                                       
MainPage.initState
  ├─ UserProfileProvider.syncOnLogin()  ──▶  ensureProfile (idempotent)
  ├─ HomePageProvider.loadNotes()
  └─ FirebaseMessaging.getToken()       ──▶  registers device w/ backend

Logout:
  CustomAuthService.signOut()
    ├─ DELETE /api/device/{userId}
    ├─ FirebaseMessaging.deleteToken()
    └─ clears SharedPreferences
```

### 6.3 Note CRUD Flow

```
HomePageProvider                      NoteRepository                NoteApiService          REST API
      │                                     │                              │                    │
loadNotes() ───────────────────────▶ getNotes(...) ────────────▶  GET /api/NoteInfo ──────▶ [...]
      ◀── notifyListeners ──── _cache populated ◀── List<NoteInfo> ◀───────┘                    │
                                                                                                │
addNote() ─────────▶ addNote() ────────────▶ POST /api/NoteInfo ────────────────────────────▶  ✓
toggleArchive() ─── _archived.add(id) (client-only)                                              │
toggleFavorite() ── PUT (isFavorites)  ────────────────────────────────────────────────────▶  ✓
```

Filtering (`favoritesOnly`, archived hidden) and sorting (`date`/`title`/`favorites`) happen **client-side** in `HomePageProvider.filteredNotes`.

### 6.4 Chat Flow

There are **two parallel chat systems**:

**A. Inbox / List view (REST)**
```
ChatPage → ChatPageProvider.loadUsers(currentUserId)
  ├─ UserProfileApiService.getProfiles()
  ├─ ChatMessengerApiService.getMessages(senderId=me)  ┐
  ├─ ChatMessengerApiService.getMessages(receiverId=me)├─▶ build ConversationPreview map
  └─ ChatMessengerApiService.getUnreadCount(me)        ┘
```

**B. Conversation view (Supabase Realtime)**
```
ChatDetailPage
  ├─ ChatService.getOrCreateConversation(me, other)
  ├─ ChatService.loadMessages(convId)
  ├─ ChatService.subscribeToMessages(convId, onInsert, onUpdate)  ← realtime channel
  └─ sendMessage / toggleReaction / markRead → Supabase tables
```

> ⚠️ The two systems are **not integrated** — preview data and conversation messages live in different tables.

### 6.5 Notification Flow (FCM)

```
Server pushes FCM ─▶ Firebase
                       │
              ┌────────┴───────────┐
              │                    │
        Foreground             Background
              │                    │
  onMessage listener     firebaseMessagingBackgroundHandler
              │                    │
  showChatNotification()      OS displays notification automatically
              │
  if activeChatUserId == senderId → suppress
  else flutter_local_notifications.show(...)
              │
  ⛔ NotificationStore.add(...)    ← currently NOT called → orphan
              │
  NotificationPage (orphan, not in nav)
```

### 6.6 Theme & Locale Flow

```
HelperProvider (ChangeNotifier)
  ├─ themeMode    ─ persisted "themeMode" int in SharedPreferences
  ├─ primaryColor ─ persisted "primaryColor" int (Color.value)
  └─ locale       ─ persisted "languageCode" string

MaterialApp consumes via context.watch<HelperProvider>()
  ├─ theme: AppTheme.lightThemeFor(primaryColor)
  ├─ darkTheme: AppTheme.darkThemeFor(primaryColor)
  ├─ themeMode
  └─ locale
```

---

## 7. Backend Map

| Concern | Endpoint / System |
|---------|-------------------|
| Sign up / sign in | `POST /api/auth/signup`, `/api/auth/signin` (REST) |
| Notes CRUD | `/api/NoteInfo` (REST) |
| User profiles | `/api/UserProfile` (REST) |
| Chat messenger inbox | `/api/ChatMessenger` (REST) |
| Realtime chat msgs | Supabase tables `conversations`, `messages` (Postgres + Realtime) |
| Avatar storage | Supabase Storage `avatars` bucket |
| Push messaging | Firebase Cloud Messaging |
| FCM token registration | `POST /api/device`, `DELETE /api/device/{userId}` |

---

## 8. Known Issues & Half-Finished Items

| # | Item | Location | Status |
|---|------|----------|--------|
| 1 | `NotificationPage` not in nav | [notification_page/](lib/core/presentation/pages/notification_page/) | Built but unreachable |
| 2 | `NotificationStore.add()` never invoked | [chat_notification_service.dart](lib/core/services/chat_notification_service.dart) | FCM messages don't populate the in-app list |
| 3 | `FavoritesPage` not in nav | [favorites_page/](lib/core/presentation/pages/favorites_page/) | Built but unreachable as standalone view |
| 4 | `language_provider.dart` empty | [language_provider.dart](lib/core/providers/language_provider.dart) | Logic actually lives in `HelperProvider` |
| 5 | `service_provider.dart` empty | [service_provider.dart](lib/core/providers/service_provider.dart) | Stub |
| 6 | `note_services.dart` placeholder | [note_services.dart](lib/core/services/note_services.dart) | Returns empty list, never used |
| 7 | Reminder picker has no backend | [add_note_page/](lib/core/presentation/pages/add_note_page/) | UI only; no schedule logic |
| 8 | Archive is client-only | [note_repository.dart](lib/core/services/note_repository.dart) | `_archived: Set<int>` lost on app restart |
| 9 | Hardcoded Supabase keys | [supabase_config.dart](lib/core/config/supabase_config.dart) | Should be env-injected |
| 10 | `sqflite` declared, not used | [pubspec.yaml](pubspec.yaml) | Remove or wire up offline cache |
| 11 | `.next/` folder in repo | `.next/` | Next.js build artifact unrelated to Flutter — add to `.gitignore` |
| 12 | `language_constant.dart` lists `zh` | [language_constant.dart](lib/core/constants/language_constant.dart) | Inconsistent with supported locales |
| 13 | `flutter_lints: ^2.0.0` is old | [pubspec.yaml](pubspec.yaml) | Bump to `^4.0.0` for current Dart 3 lints |
| 14 | Two chat systems unmerged | `chat_service.dart` vs `chat_messenger_api_service.dart` | Inbox previews don't reflect realtime messages |

---

## 9. New Ideas & Recommendations

### 🔧 Quick Wins (1–2 hours each)

1. **Wire up `NotificationPage`** — add a bell icon in the `MainPage` AppBar with an unread badge from `NotificationStore.instance.unreadCount`. Tap → push `NotificationPage`.
2. **Hook FCM → store** — inside `ChatNotificationService._onForegroundFcm` (and `showChatNotification`), call `NotificationStore.instance.add(title, body, senderId)` so in-app history actually populates.
3. **Add `FavoritesPage` to drawer** — already built, just missing a `ListTile` in `MenuDrawer`.
4. **Move secrets to `--dart-define`** — replace [supabase_config.dart](lib/core/config/supabase_config.dart) constants with `String.fromEnvironment('SUPABASE_URL')` etc.
5. **Add `.next/` to `.gitignore`** — and likely delete the folder.
6. **Delete dead files** — `language_provider.dart`, `service_provider.dart`, `note_services.dart` are all empty/unused.

### 💎 Feature Ideas

7. **Persist `NotificationStore`** — back it with `SharedPreferences` (last 50 items) so notifications survive app restarts.
8. **Persist archive state** — add `isArchived` to backend `NoteInfo` schema, or persist `_archived` Set in `SharedPreferences`.
9. **Reminders** — finish the reminder picker:
   - Schedule a local notification via `flutter_local_notifications` when saving a note with a reminder.
   - Persist reminder time in the note (new `reminderAt` field).
10. **Offline support with `sqflite`** — you already have the dep. Cache notes locally; sync when online; show "offline" banner.
11. **Voice notes** — `MessageType.voice` already exists in the enum — wire it up with `record` + `audioplayers`.
12. **Note tags / folders** — add a `tags: List<String>` field for richer organization. Filter chip row above notes grid.
13. **Rich-text / Markdown** — use `flutter_markdown` for note content rendering; `flutter_quill` for editing.
14. **Note sharing** — share via `share_plus`, or generate a public read-only link via Supabase RLS.
15. **Search across chat messages** — currently only filters notes. Extend to chat inbox.
16. **Pull-to-refresh** on home/chat/archive — `RefreshIndicator` is trivial to add.
17. **Empty-state illustrations** — replace plain text with friendly Lottie animations (`lottie` package).
18. **Biometric lock** — there's already a `biometric` localization key. Wire `local_auth` to gate the app on launch.
19. **Note color tagging** — you have 6 note colors in `AppColors`; let users assign one per note (visual category).
20. **Soft delete + trash** — undo accidental deletes (30-day retention).

### 🏗️ Architectural Improvements

21. **Unify chat systems** — pick one source of truth. Recommended: keep Supabase for all messages (realtime + history), drop `ChatMessengerApiService`, or vice-versa. Two systems → bugs.
22. **Adopt a router** — `go_router` would make navigation declarative and deep-linkable (esp. for opening a chat from a notification).
23. **Inject dependencies** — singletons everywhere makes testing hard. Move services into the `MultiProvider` tree or use `get_it`.
24. **Split `HelperProvider`** — it does 3 unrelated things (theme/color/locale). One provider per concern improves rebuild scope.
25. **Add a model code-gen** — `freezed` + `json_serializable` would replace all the hand-written `fromJson`/`copyWith` boilerplate.
26. **Error handling layer** — `ApiService._handleBadResponse` returns strings; convert to typed `Failure` classes (`AuthFailure`, `NetworkFailure`, …) and surface via `Provider`s.
27. **Tests** — there are zero tests. At minimum: unit tests for models' JSON round-trips, and widget tests for `HomePage` empty/list states.
28. **CI/CD** — `.github/` exists but no workflows visible. Add lint + analyze + test on PRs; build artifacts on tags.

### 🎨 UX Polish

29. **Skeleton loaders** instead of `CircularProgressIndicator` (use `shimmer` package).
30. **Haptic feedback** on note save / message send (`HapticFeedback.lightImpact`).
31. **Undo SnackBar** after delete actions.
32. **Note reorder** via drag-and-drop in list view.
33. **Quick actions** from app icon (Android/iOS) — "New note", "New chat".

### 🔒 Security & Privacy

34. **Rotate hardcoded Supabase anon key** after moving to env vars (it's been committed to the repo).
35. **Enable Supabase RLS** on `messages`, `conversations`, `avatars` — confirm policies prevent cross-user reads.
36. **Sanitize note input** if rendering as HTML/Markdown later (XSS).
37. **Token refresh** — `CustomAuthService` stores access + refresh tokens, but I don't see refresh logic on 401. Add an interceptor in `ApiService` that retries with refresh token.

---

## 10. Quick File Reference

| Component | Path |
|-----------|------|
| Main entry | [lib/main.dart](lib/main.dart) |
| Supabase config | [lib/core/config/supabase_config.dart](lib/core/config/supabase_config.dart) |
| Theme | [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) |
| Theme tokens | [lib/core/theme/app_theme_extension.dart](lib/core/theme/app_theme_extension.dart) |
| Auth (REST) | [lib/core/data/services/custom_auth_service.dart](lib/core/data/services/custom_auth_service.dart) |
| Auth (Supabase) | [lib/core/data/supabase/auth_service.dart](lib/core/data/supabase/auth_service.dart) |
| Notes API | [lib/core/services/note_api_service.dart](lib/core/services/note_api_service.dart) |
| Notes Repository | [lib/core/services/note_repository.dart](lib/core/services/note_repository.dart) |
| Chat (Realtime) | [lib/core/services/chat_service.dart](lib/core/services/chat_service.dart) |
| Chat (REST) | [lib/core/services/chat_messenger_api_service.dart](lib/core/services/chat_messenger_api_service.dart) |
| FCM service | [lib/core/services/chat_notification_service.dart](lib/core/services/chat_notification_service.dart) |
| Notification store | [lib/core/services/notification_store.dart](lib/core/services/notification_store.dart) |
| Storage (avatars) | [lib/core/services/storage_service.dart](lib/core/services/storage_service.dart) |
| User profile API | [lib/core/services/user_profile_api_service.dart](lib/core/services/user_profile_api_service.dart) |
| Helper provider | [lib/core/providers/helper_provider.dart](lib/core/providers/helper_provider.dart) |
| Auth provider | [lib/core/providers/auth_provider.dart](lib/core/providers/auth_provider.dart) |
| User profile provider | [lib/core/providers/user_profile_provider.dart](lib/core/providers/user_profile_provider.dart) |
| Splash | [lib/core/presentation/auth/splash_page.dart](lib/core/presentation/auth/splash_page.dart) |
| Main shell | [lib/core/presentation/pages/main_page.dart](lib/core/presentation/pages/main_page.dart) |
| Home | [lib/core/presentation/pages/home_page/](lib/core/presentation/pages/home_page/) |
| Add / edit note | [lib/core/presentation/pages/add_note_page/](lib/core/presentation/pages/add_note_page/) |
| Note view | [lib/core/presentation/pages/note_view_page/](lib/core/presentation/pages/note_view_page/) |
| Archive | [lib/core/presentation/pages/archive_page/](lib/core/presentation/pages/archive_page/) |
| Favorites | [lib/core/presentation/pages/favorites_page/](lib/core/presentation/pages/favorites_page/) |
| Chat list | [lib/core/presentation/pages/chat_page/](lib/core/presentation/pages/chat_page/) |
| Notification UI | [lib/core/presentation/pages/notification_page/](lib/core/presentation/pages/notification_page/) |
| Profile | [lib/core/presentation/pages/profile_page/](lib/core/presentation/pages/profile_page/) |
| Settings | [lib/core/presentation/pages/setting_page/](lib/core/presentation/pages/setting_page/) |
| Localization (EN) | [lib/l10n/app_en.arb](lib/l10n/app_en.arb) |
| Localization (KM) | [lib/l10n/app_km.arb](lib/l10n/app_km.arb) |

---

*Document generated 2026-04-29.*
