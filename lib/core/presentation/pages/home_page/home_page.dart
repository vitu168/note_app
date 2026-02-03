import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/presentation/components/loading_indicator_animation.dart';
import 'package:note_app/core/presentation/widgets/note_card.dart';
import 'package:note_app/core/presentation/pages/setting_page/settings_page.dart';
import 'package:note_app/core/presentation/pages/add_note_page/add_note_page.dart';
import 'package:note_app/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _sortOption = 'Date';
  bool _isGridView = true;
  final List<NoteInfo> _notes = [
    NoteInfo(
      id: 1,
      name: 'Welcome to Notes!',
      description:
          'This is your first note. Try adding more or favoriting this one.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: 'user1',
    ),
    NoteInfo(
      id: 2,
      name: 'Project Meeting',
      description:
          'Discuss milestones, assign tasks, and set deadlines for Q4.',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      updatedAt: DateTime.now().subtract(Duration(days: 1)),
      userId: 'user1',
    ),
    NoteInfo(
      id: 3,
      name: 'Flutter Tips',
      description:
          'Explore animations and state management in Flutter for better UIs.',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      updatedAt: DateTime.now().subtract(Duration(days: 2)),
      userId: 'user1',
    ),
    NoteInfo(
      id: 4,
      name: 'Grocery List',
      description: 'Milk, eggs, bread, and fruits for the week.',
      createdAt: DateTime.now().subtract(Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(Duration(hours: 5)),
      userId: 'user1',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _notes
        .where((n) =>
            (n.name ?? '')
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            (n.description ?? '')
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,

      drawer: Drawer(
        child: SingleChildScrollView(
          child: SafeArea(
            child: AboutListTile(
              icon: Icon(Icons.info),
              applicationIcon: Icon(Icons.flutter_dash),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).notes,
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded,
                color: Theme.of(context).colorScheme.primary),
            tooltip: AppLocalizations.of(context).notifications,
            onPressed: () {
              _showNotificationsDialog(context);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                _showProfileDialog(context);
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                child: Icon(Icons.person,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFe0eafc),
                  Color(0xFFcfdef3),
                  Color(0xFFf9f6f7),
                ],
              ),
            ),
          ),
          // Decorative blurred circles
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withValues(alpha: 0.10),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: kToolbarHeight + 16),
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).searchHint,
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: Theme.of(context).colorScheme.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: Theme.of(context).colorScheme.primary),
                            onPressed: () =>
                                setState(() => _searchController.clear()),
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.13),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                // Sort and View Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const AddNotePage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                // Fade + Slide from bottom
                                final offsetAnimation = Tween<Offset>(
                                  begin: const Offset(0, 0.15),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ));
                                final fadeAnimation = CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeIn,
                                );
                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: FadeTransition(
                                    opacity: fadeAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 400),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add,
                            color: Colors.white, size: 20),
                        label: Text(
                          AppLocalizations.of(context).addNote,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          elevation: 0,
                          minimumSize: const Size(0, 44),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Dropdown for sort options
                        SizedBox(
                          height: 44,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sortOption,
                                borderRadius: BorderRadius.circular(12),
                                dropdownColor:
                                    Theme.of(context).colorScheme.surface,
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                                icon: Icon(Icons.arrow_drop_down,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                items: [
                                  DropdownMenuItem(
                                    value: 'Date Range',
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today_rounded,
                                            size: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        const SizedBox(width: 8),
                                        Text(AppLocalizations.of(context)
                                            .sortDate),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Title',
                                    child: Row(
                                      children: [
                                        Icon(Icons.title_rounded,
                                            size: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        const SizedBox(width: 8),
                                        Text(AppLocalizations.of(context)
                                            .sortTitle),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Favorites',
                                    child: Row(
                                      children: [
                                        Icon(Icons.star_rounded,
                                            size: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        const SizedBox(width: 8),
                                        Text(AppLocalizations.of(context)
                                            .sortFavorites),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _sortOption = value!;
                                    _notes.sort((a, b) {
                                      switch (_sortOption) {
                                        case 'Title':
                                          return (a.name ?? '')
                                              .toLowerCase()
                                              .compareTo(
                                                  (b.name ?? '').toLowerCase());
                                        case 'Favorites':
                                          return (b.isFavorite ? 1 : 0)
                                              .compareTo(a.isFavorite ? 1 : 0);
                                        case 'Date Range':
                                        default:
                                          return b.updatedAt?.compareTo(
                                                  a.updatedAt ??
                                                      DateTime.now()) ??
                                              0;
                                      }
                                    });
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Grid/List Switch
                        SizedBox(
                          height: 44,
                          width: 44,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isGridView ? Icons.list : Icons.grid_view,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              tooltip: _isGridView
                                  ? AppLocalizations.of(context).switchToList
                                  : AppLocalizations.of(context).switchToGrid,
                              onPressed: () {
                                setState(() {
                                  _isGridView = !_isGridView;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Notes Grid or List
                Expanded(
                  child: filteredNotes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.note_add_rounded,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context).noNotes,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _isGridView
                          ? MasonryGridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              itemCount: filteredNotes.length,
                              itemBuilder: (context, i) => AnimatedOpacity(
                                opacity: 1.0,
                                duration:
                                    Duration(milliseconds: 300 + (i * 100)),
                                child: GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'View note: ${filteredNotes[i].name}')),
                                    );
                                  },
                                  onLongPress: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Long press: ${filteredNotes[i].name}')),
                                    );
                                  },
                                  child: NoteCard(note: filteredNotes[i]),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredNotes.length,
                              itemBuilder: (context, i) => AnimatedOpacity(
                                opacity: 1.0,
                                duration:
                                    Duration(milliseconds: 300 + (i * 100)),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'View note: ${filteredNotes[i].name}')),
                                      );
                                    },
                                    onLongPress: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Long press: ${filteredNotes[i].name}')),
                                      );
                                    },
                                    child: NoteCard(note: filteredNotes[i]),
                                  ),
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      //floatingActionButtonLocation: const AboveBottomNavigationBar(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNotificationsDialog(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {
        'title': 'Reminder',
        'body': 'Don\'t forget your meeting at 10:00 AM.',
        'time': '5 min ago',
      },
      {
        'title': 'Note Saved',
        'body': 'Your note "Project Meeting" was saved successfully.',
        'time': '1 hour ago',
      },
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 420, minWidth: 320),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active_rounded,
                        color: Theme.of(context).colorScheme.primary, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).notifications,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
              const Divider(height: 18, thickness: 1),
              if (notifications.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.notifications_off_rounded,
                          size: 54, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context).noNotifications,
                        style: GoogleFonts.poppins(
                            fontSize: 15, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 18),
                    itemBuilder: (context, i) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.13),
                        child: Icon(
                          notifications[i]['title'] == 'Reminder'
                              ? Icons.alarm_rounded
                              : Icons.note_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        notifications[i]['title'] == 'Reminder'
                            ? AppLocalizations.of(context).notificationReminder
                            : AppLocalizations.of(context)
                                .notificationNoteSaved,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notifications[i]['title'] == 'Reminder'
                                ? AppLocalizations.of(context)
                                    .notificationReminderBody
                                : AppLocalizations.of(context)
                                    .notificationNoteSavedBody,
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            notifications[i]['time']!,
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _LoadingRefresh() async {
    final completer = Completer<void>();
    Future.delayed(const Duration(seconds: 2), () {
      completer.complete();
    });
    return completer.future;
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      child: const LoadingAnimation(
        size: 50,
        color: Colors.blueAccent,
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 20,
                ),
              ),
              CircleAvatar(
                radius: 44,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.13),
                child: Icon(Icons.person,
                    size: 48, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 18),
              Text(
                AppLocalizations.of(context).profileName, // e.g. John Doe
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)
                    .profileEmail, // e.g. john.doe@example.com
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: Text(
                    AppLocalizations.of(context).editProfile,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(AppLocalizations.of(context).editSoon)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.settings_rounded, size: 18),
                  label: Text(
                    AppLocalizations.of(context).settings,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5),
                      width: 1.3,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AboveBottomNavigationBar extends FloatingActionButtonLocation {
  const AboveBottomNavigationBar();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;
    final double navbarHeight =
        scaffoldGeometry.scaffoldSize.height - scaffoldGeometry.contentBottom;
    final double x = scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width -
        16;
    final double y =
        scaffoldGeometry.scaffoldSize.height - navbarHeight - fabHeight - 16;
    return Offset(x, y);
  }
}
