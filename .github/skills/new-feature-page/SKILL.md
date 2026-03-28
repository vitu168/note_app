---
name: new-feature-page
description: "Scaffold a new feature page in this Flutter note app project. Use when: creating a new page, adding a new screen, new feature, scaffold page, add feature, new route."
---

# New Feature Page Skill

## Overview

Scaffolds a complete new feature page for this Flutter note app, following the exact project conventions:
- **State management**: `ChangeNotifier` + `Provider`
- **Backend**: Supabase via `NoteRepository`
- **Localization**: `AppLocalizations` (en / km)
- **Structure**: `lib/core/presentation/pages/<feature_name>/`

## Steps

### Step 1: Gather Information

Ask the user (or infer from context):
- `featureName` — e.g., `tags`, `reminders`, `trash` (snake_case)
- `FeatureName` — PascalCase version (e.g., `Tags`, `Reminders`, `Trash`)
- What data the page shows (list of items? detail view? form?)
- Does it need Supabase data access, or is it UI-only?

---

### Step 2: Create the Provider

Create `lib/core/presentation/pages/<feature_name>_page/<feature_name>_page_provider.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/services/note_repository.dart';

class <FeatureName>PageProvider extends ChangeNotifier {
  final NoteRepository _repo = NoteRepository();

  List<NoteInfo> _items = [];
  bool _loading = false;

  List<NoteInfo> get items => _items;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      // TODO: implement fetch logic using _repo
      _items = await _repo.getNotes(); // replace with correct call
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async => load();
}
```

**Rules:**
- Always wrap async in `try/finally` to reset `_loading`
- Always call `notifyListeners()` after state changes
- Never put UI logic here — only state and data operations

---

### Step 3: Create the Page Widget

Create `lib/core/presentation/pages/<feature_name>_page/<feature_name>_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:note_app/core/presentation/pages/<feature_name>_page/<feature_name>_page_provider.dart';
import 'package:note_app/l10n/app_localizations.dart';

class <FeatureName>Page extends StatefulWidget {
  const <FeatureName>Page({super.key});

  @override
  State<<FeatureName>Page> createState() => _<FeatureName>PageState();
}

class _<FeatureName>PageState extends State<<FeatureName>Page> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<<FeatureName>PageProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<<FeatureName>PageProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.<featureName>Title), // add l10n key
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.items.isEmpty
              ? Center(child: Text(l10n.noData)) // use existing empty state
              : ListView.builder(
                  itemCount: provider.items.length,
                  itemBuilder: (context, index) {
                    final item = provider.items[index];
                    return ListTile(
                      title: Text(item.name ?? ''),
                      subtitle: Text(item.description ?? ''),
                    );
                  },
                ),
    );
  }
}
```

**Rules:**
- Use `context.watch<>()` for reactive rebuilds
- Use `context.read<>()` for one-time calls (inside callbacks/initState)
- Load data in `initState` via `addPostFrameCallback`
- All user-visible strings must use `AppLocalizations`

---

### Step 4: Register the Provider in `main.dart`

Add the new provider to the `MultiProvider` list in `lib/main.dart`:

```dart
// Add this import:
import 'package:note_app/core/presentation/pages/<feature_name>_page/<feature_name>_page_provider.dart';

// Add inside MultiProvider providers list:
ChangeNotifierProvider(create: (_) => <FeatureName>PageProvider()),
```

---

### Step 5: Add l10n Keys

Add the new localization keys to both ARB files:

**`lib/l10n/app_en.arb`:**
```json
"<featureName>Title": "<Feature Display Name>",
```

**`lib/l10n/app_km.arb`:**
```json
"<featureName>Title": "<Khmer translation>",
```

Then run:
```bash
flutter gen-l10n
```

---

### Step 6: Add Navigation (if needed)

If the page is accessed from the bottom nav, add it to:
`lib/core/presentation/pages/main_page.dart`

If it's a push route from another page:
```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const <FeatureName>Page()),
);
```

---

### Step 7: Validate

- [ ] Provider file created and compiles
- [ ] Page widget created and compiles  
- [ ] Provider registered in `main.dart`
- [ ] l10n keys added to both `app_en.arb` and `app_km.arb`
- [ ] `flutter gen-l10n` run successfully (`flutter pub get` if needed)
- [ ] Page navigates correctly from existing UI
- [ ] No hardcoded strings visible to user
- [ ] Loading and empty states handled

---

## Templates

### Minimal UI-only Page (no data)
```dart
class <FeatureName>Page extends StatelessWidget {
  const <FeatureName>Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.<featureName>Title)),
      body: const Center(child: Text('Coming soon')),
    );
  }
}
```

### Existing project patterns to follow
- Empty state widget: `EmptyData` from `lib/core/presentation/components/empty_data.dart`
- Loading indicator: `LoadingIndicatorAnimation` from `lib/core/presentation/components/loading_indicator_animation.dart`
- Note card widget: `NoteCard` from `lib/core/presentation/widgets/note_card.dart`

---

## Common Pitfalls

- **Don't** call `load()` directly in `initState` — always wrap in `addPostFrameCallback` to avoid calling `setState` during build
- **Don't** forget to register the provider in `main.dart` — the app will throw a `ProviderNotFoundException` at runtime
- **Don't** hardcode display strings — all text must go through `AppLocalizations`
- **Don't** use `setState` inside the provider — providers use `notifyListeners()`
- **Don't** use `var` for provider fields — always use explicit types
- **Avoid** `listen: true` (default) in callbacks — use `context.read<>()` inside `onPressed`, `onTap`, etc.
