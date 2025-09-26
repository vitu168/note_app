# Copilot Instructions for Note App Project

## Project Overview
This is a professional Flutter mobile note-taking app with a modern, portfolio-inspired UI.  
The app supports light/dark themes, reminders, favorites, archive, search, and user profile management.  
**The app connects to a Supabase backend for authentication and real-time note storage.**

---

## Supabase Configuration Configuration

- **Supabase URL:** `https://atmmyhssaafgascfoikm.supabase.co` `https://atmmyhssaafgascfoikm.supabase.co`
- **Supabase anon key:**  
  ```
  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF0bW15aHNzYWFmZ2FzY2ZvaWttIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzMTAxNjEsImV4cCI6MjA2MDg4NjE2MX0.G6wJKDINQbzFONYIFvIcyUVHn9Uzs9u1Haae5CnOC5s  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF0bW15aHNzYWFmZ2FzY2ZvaWttIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzMTAxNjEsImV4cCI6MjA2MDg4NjE2MX0.G6wJKDINQbzFONYIFvIcyUVHn9Uzs9u1Haae5CnOC5s
  ```
- Use these credentials to initialize Supabase in your Flutter app.

------

## App Flow

1. **Welcome Page**
   - Shows a gradient background and app branding.
   - User can "Get Started" or "Continue as Guest" to enter the app.   - User can "Get Started" or "Continue as Guest" to enter the app.

2. **Main Navigation**
   - Uses a BottomNavigationBar for Home, Favorites, Archive, and Settings.Home, Favorites, Archive, and Settings.
   - Navigation should always keep the bottom bar visible.e.

3. **Home Page**
   - Displays a search bar, add note button, sort options, and grid/list toggle.st toggle.
   - Notes are shown in a grid or list with animated transitions. animated transitions.
   - Tapping a note opens the note detail page.
   - Long-pressing a note shows context actions (edit, delete, share, etc.).   - Long-pressing a note shows context actions (edit, delete, share, etc.).

4. **Add/Edit Note Page**
   - Form with title, content, color picker, reminder (date/time picker), and save button.(date/time picker), and save button.
   - Validation for required fields.
   - UI uses cards, rounded corners, and soft gradients.   - UI uses cards, rounded corners, and soft gradients.

5. **Favorites & Archive Pages**
   - Same layout as Home, but filtered for favorite or archived notes.vorite or archived notes.
   - Search and grid/list toggle available.   - Search and grid/list toggle available.
   - Empty state with friendly illustration and message.h friendly illustration and message.

6. **Settings Page**
   - Shows user profile (avatar, name, email) at the top.   - Shows user profile (avatar, name, email) at the top.
   - Options for theme, language, about, and sign out.- Options for theme, language, about, and sign out.
   - Profile dialog can be opened from the Home page profile icon.   - Profile dialog can be opened from the Home page profile icon.

7. **Profile Dialog**7. **Profile Dialog**
   - Shows avatar, name, email, and buttons for editing profile or going to settings.or going to settings.
   - Clean, modern, and user-friendly design.

8. **Notifications**
   - Notification dialog shows reminders and app messages in a list.
   - Empty state with icon and message if no notifications.

---

## Supabase IntegrationSupabase Integration

- Use the `supabase_flutter` package for all backend operations.base_flutter` package for all backend operations.
- Authenticate users with Supabase Auth (email/password or OAuth).- Authenticate users with Supabase Auth (email/password or OAuth).
- Store notes, favorites, archives, and reminders in Supabase tables.Supabase tables.
- Use Supabase real-time features to update notes instantly across devices.te notes instantly across devices.
- Perform CRUD operations (create, read, update, delete) on notes via Supabase.d, update, delete) on notes via Supabase.
- Store user profile data (name, email, avatar) in Supabase.pabase.
- Handle errors and loading states gracefully in the UI.
- Secure all data access with row-level security (RLS) policies in Supabase. in Supabase.

---

## Coding Style## Coding Style

- Use Dart best practices and idiomatic Flutter code.- Use Dart best practices and idiomatic Flutter code.
- Use `GoogleFonts.poppins` for all text.ts.poppins` for all text.
- Use `Provider` for state management.- Use `Provider` for state management.
- Use `Theme.of(context)` for all colors and theming.
- Use `const` where possible and null safety throughout.
- Use `SizedBox`, `Padding`, and `Card` for spacing and layout. for spacing and layout.
- Use descriptive variable and method names.
- Separate business logic from UI.
- Add comments for complex logic.

---

## UI Guidelines

- Use gradients and soft backgrounds for main screens.backgrounds for main screens.
- Use rounded corners and subtle shadows for cards and dialogs. subtle shadows for cards and dialogs.
- Use clear, friendly labels and icons.abels and icons.
- All forms should use `TextFormField` with validation. `TextFormField` with validation.
- Use modern, accessible color schemes.
- Maintain visual consistency across all screens.- Maintain visual consistency across all screens.

------

## File Structure## File Structure

- Screens: `lib/screens/`
- Widgets: `lib/widgets/`
- Models: `lib/models/`
- Themes: `lib/theme/`
- Supabase services: `lib/services/supabase_service.dart` (or similar)- Supabase services: `lib/services/supabase_service.dart` (or similar)

------


**End of Copilot Instructions**---- Do not store sensitive data on the device; use Supabase for all persistent storage.- Do not break the navigation flow (always keep the bottom navigation bar visible).- Do not use global variables for state.- Do not use hardcoded colors or fonts (use theme and GoogleFonts).- Do not use deprecated Flutter APIs.## Do Not## Do Not

- Do not use deprecated Flutter APIs.
- Do not use hardcoded colors or fonts (use theme and GoogleFonts).
- Do not use global variables for state.
- Do not break the navigation flow (always keep the bottom navigation bar visible).
- Do not store sensitive data on the device; use Supabase for all persistent storage.

---

**End of Copilot Instructions**