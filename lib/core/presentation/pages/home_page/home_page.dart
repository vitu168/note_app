import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/core/presentation/components/item_gap.dart';
import 'package:note_app/core/presentation/pages/home_page/home_page_provider.dart';
import 'package:note_app/core/presentation/widgets/note_card.dart';
import 'package:note_app/core/presentation/components/empty_data.dart';
import 'package:note_app/core/presentation/pages/note_view_page/note_view_page.dart';
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/providers/user_profile_provider.dart';
import 'package:note_app/core/theme/app_context_ext.dart';
import 'package:note_app/core/theme/app_theme_extension.dart';
import 'package:note_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomePageProvider>().loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openNote(NoteInfo note) async {
    final refreshed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => NoteViewPage(note: note)),
    );
    if (refreshed == true && context.mounted) {
      context.read<HomePageProvider>().loadNotes();
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  IconData _greetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_cloudy_rounded;
    return Icons.nightlight_round;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomePageProvider>();
    final l10n = AppLocalizations.of(context);
    final filteredNotes = provider.filteredNotes;
    final t = context.appTheme;
    final profile = context.watch<UserProfileProvider>().profile;
    final userName = profile?.name ?? profile?.email ?? l10n.profileName;

    return Scaffold(
      backgroundColor: t.surfaceElevated,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildHeader(context, t, l10n, userName),
            ),

            itemGap(height: 20),

            // ── Search bar ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearchBar(context, provider, l10n, t),
            ),

            itemGap(height: 24),

            // ── Section title + count ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    l10n.notes,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: t.titleText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: t.primaryMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filteredNotes.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: t.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            itemGap(height: 8),

            // ── Notes list ─────────────────────────────────────
            Expanded(
              child: provider.loading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredNotes.isEmpty
                      ? EmptyData(message: l10n.noNotes)
                      : RefreshIndicator(
                          onRefresh: provider.refresh,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                            itemCount: filteredNotes.length,
                            itemBuilder: (context, index) {
                              final note = filteredNotes[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: NoteCard(
                                  note: note,
                                  onTap: () => _openNote(note),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppThemeExtension t,
    AppLocalizations l10n,
    String userName,
  ) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    return Row(
      children: [
        // Avatar with initial
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: t.primaryMuted,
          ),
          child: Center(
            child: Text(
              initial,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: t.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Greeting + name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(_greetingIcon(), size: 14, color: t.hintText),
                  const SizedBox(width: 4),
                  Text(
                    _greeting(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: t.hintText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: t.titleText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Notification button
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: t.surface,
            shape: BoxShape.circle,
            boxShadow: context.isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.notifications_outlined,
              color: t.bodyText,
              size: 22,
            ),
            tooltip: l10n.notifications,
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    HomePageProvider provider,
    AppLocalizations l10n,
    AppThemeExtension t,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: context.isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: provider.setSearch,
        style: GoogleFonts.poppins(fontSize: 14, color: t.bodyText),
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          hintStyle: GoogleFonts.poppins(
            color: t.hintText,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: t.hintText,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        ),
      ),
    );
  }
}

