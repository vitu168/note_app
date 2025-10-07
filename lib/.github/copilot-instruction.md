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

## UI Design Guidelines

### Colors
- **Primary Colors:**
  - Primary: `#6366F1` (Indigo)
  - Primary Light: `#8B5CF6` (Violet)
  - Primary Dark: `#4F46E5` (Dark Indigo)

- **Secondary Colors:**
  - Secondary: `#EC4899` (Pink)
  - Secondary Light: `#F472B6` (Light Pink)
  - Secondary Dark: `#DB2777` (Dark Pink)

- **Accent Colors:**
  - Accent: `#F59E0B` (Amber)
  - Accent Light: `#FCD34D` (Light Amber)
  - Accent Dark: `#D97706` (Dark Amber)

- **Neutral Colors:**
  - White: `#FFFFFF`
  - Black: `#000000`
  - Gray Scale: 50-900 (from `#F9FAFB` to `#111827`)

- **Semantic Colors:**
  - Success: `#10B981` (Emerald)
  - Warning: `#F59E0B` (Amber)
  - Error: `#EF4444` (Red)
  - Info: `#3B82F6` (Blue)

- **Background Colors:**
  - Light Background: `#FAFAFA`
  - Dark Background: `#121212`
  - Light Surface: `#FFFFFF`
  - Dark Surface: `#1E1E1E`

- **Note Colors:** 8 predefined colors for note backgrounds (Light Yellow, Blue, Green, Red, Gray, Pink, Purple, Mint)

### Typography
- **Font Families:**
  - Primary: Poppins (Google Fonts)
  - Secondary: Inter (Google Fonts)
  - Monospace: JetBrains Mono (Google Fonts)

- **Font Sizes:**
  - XS: 10px
  - SM: 12px
  - MD: 14px
  - LG: 16px
  - XL: 18px
  - XXL: 20px
  - XXXL: 24px
  - XXXXL: 28px
  - XXXXXL: 32px

- **Font Weights:**
  - Light: 300
  - Regular: 400
  - Medium: 500
  - SemiBold: 600
  - Bold: 700
  - ExtraBold: 800

- **Line Heights:**
  - Tight: 1.2
  - Normal: 1.4
  - Relaxed: 1.6
  - Loose: 1.8

- **Letter Spacing:**
  - Tight: -0.5px
  - Normal: 0px
  - Wide: 0.5px
  - Extra Wide: 1.0px

### Spacing & Layout
- **Border Radius:**
  - Small: 4px
  - Medium: 8px
  - Large: 12px
  - Extra Large: 16px
  - Round: 24px (for buttons, FABs)

- **Padding:**
  - XS: 4px
  - SM: 8px
  - MD: 16px
  - LG: 24px
  - XL: 32px
  - XXL: 48px

- **Margins:**
  - Same scale as padding (4px to 48px)

- **Shadows:**
  - Light Shadow: `rgba(0, 0, 0, 0.1)`
  - Medium Shadow: `rgba(0, 0, 0, 0.15)`
  - Dark Shadow: `rgba(0, 0, 0, 0.25)`

### Buttons
- **Primary Button:**
  - Background: Primary gradient (Indigo to Violet)
  - Text: White
  - Font: Button Medium (14px, SemiBold)
  - Border Radius: 24px
  - Padding: 16px horizontal, 12px vertical
  - Elevation: 2dp

- **Secondary Button:**
  - Background: Transparent
  - Border: 1px solid Primary
  - Text: Primary
  - Font: Button Medium (14px, SemiBold)
  - Border Radius: 24px
  - Padding: 16px horizontal, 12px vertical

- **Text Button:**
  - Background: Transparent
  - Text: Primary
  - Font: Button Small (12px, SemiBold)
  - Padding: 8px horizontal, 4px vertical

- **FAB (Floating Action Button):**
  - Background: Primary
  - Icon: White, 24px
  - Size: 56px
  - Border Radius: 28px (circular)
  - Elevation: 6dp

### Cards & Surfaces
- **Note Cards:**
  - Border Radius: 12px
  - Elevation: 2dp (light mode), 4dp (dark mode)
  - Padding: 16px
  - Background: Note colors or surface color

- **Dialog Cards:**
  - Border Radius: 16px
  - Elevation: 8dp
  - Padding: 24px
  - Background: Surface color

- **List Items:**
  - Border Radius: 8px
  - Padding: 16px
  - Background: Surface color with subtle opacity

### Form Elements
- **Text Fields:**
  - Border Radius: 12px
  - Border: 1px solid Gray 300 (inactive), Primary (active)
  - Padding: 16px
  - Font: Body Medium (14px, Regular)
  - Background: Surface color

- **Dropdowns:**
  - Same as text fields
  - Icon: Chevron down (20px)

- **Checkboxes & Switches:**
  - Active Color: Primary
  - Inactive Color: Gray 400
  - Size: 24px (checkbox), 48px width (switch)

### Icons
- **Sizes:**
  - Small: 16px
  - Medium: 20px
  - Large: 24px
  - Extra Large: 32px

- **Colors:**
  - Primary: Primary color
  - Secondary: Gray 600
  - Accent: Accent color
  - Error: Error color

### Animations
- **Duration:**
  - Fast: 150ms
  - Normal: 300ms
  - Slow: 500ms

- **Easing:**
  - Standard: `Curves.easeInOut`
  - Enter: `Curves.easeOut`
  - Exit: `Curves.easeIn`

### Responsive Design
- **Breakpoints:**
  - Mobile: < 640px
  - Tablet: 640px - 1024px
  - Desktop: > 1024px

- **Grid:**
  - Columns: 4 (mobile), 8 (tablet), 12 (desktop)
  - Gutter: 16px
  - Margin: 16px

### Dark Mode
- **Color Mapping:**
  - Background: Dark Background (#121212)
  - Surface: Dark Surface (#1E1E1E)
  - Text Primary: Light Gray (#F9FAFB)
  - Text Secondary: Medium Gray (#9CA3AF)
  - Shadows: Light shadows with white tint

### Accessibility
- **Contrast Ratios:**
  - Normal Text: 4.5:1 minimum
  - Large Text: 3:1 minimum
  - Icons: 3:1 minimum

- **Touch Targets:**
  - Minimum Size: 44px x 44px
  - Recommended Size: 48px x 48px

- **Focus Indicators:**
  - Border: 2px solid Primary
  - Border Radius: 4px

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

---

## Custom Loading Animation Widget

### Overview
The app includes a beautiful, friendly, animated circular loading indicator called `LoadingAnimation`. This widget is fully consistent with the app's design system, using primary/secondary colors and smooth, modern animation.

### Features
- Animated cycle line (arc) with smooth sweep and rotation
- Uses `AppColors.primary` and `AppColors.primaryLight` for color consistency
- Customizable size, line width, and animation duration
- Background circle for subtle, friendly appearance
- Reusable anywhere a loading state is needed

### Usage Example
```
import 'package:note_app/core/presentation/components/loading_animation.dart';

// In your widget tree:
const LoadingAnimation();
```

#### Example Page
See `lib/core/presentation/pages/loading_animation_example_page.dart` for a full example page demonstrating the loading animation in context:

```
import 'package:flutter/material.dart';
import '../components/loading_animation.dart';

class LoadingAnimationExamplePage extends StatelessWidget {
  const LoadingAnimationExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading Animation Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingAnimation(),
            const SizedBox(height: 24),
            const Text('Loading... Please wait'),
          ],
        ),
      ),
    );
  }
}
```

### Design Notes
- The animation duration and arc sweep are tuned for a friendly, non-distracting effect
- Colors and sizing follow the design system (see Color & Typography sections above)
- Prefer this widget over the default `CircularProgressIndicator` for a more branded, delightful experience

---

**End of Copilot Instructions**