import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/core/presentation/components/item_gap.dart';
import 'package:note_app/core/presentation/pages/home_page/home_page_provider.dart';
import 'package:note_app/core/presentation/widgets/note_card.dart';
import 'package:note_app/core/presentation/components/empty_data.dart';
import 'package:note_app/core/presentation/pages/note_view_page/note_view_page.dart';
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/providers/user_profile_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomePageProvider>();
    final l10n = AppLocalizations.of(context);
    final filteredNotes = provider.filteredNotes;
    final theme = Theme.of(context);
    final profile = context.watch<UserProfileProvider>().profile;
    final userName = profile?.name ?? profile?.email ?? l10n.profileName;
    final userEmail = profile?.email ?? l10n.profileEmail;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _buildHeader(context, theme, l10n, userName, userEmail),
            ),

            itemGap(height: 16),

            // ── Search bar ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearchBar(context, provider, l10n, theme),
            ),

            itemGap(height: 20),

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
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filteredNotes.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
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

  Widget _buildHeader(BuildContext context, ThemeData theme,
      AppLocalizations l10n, String userName, String userEmail) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          child: Text(
            initial,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                userEmail,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, HomePageProvider provider,
      AppLocalizations l10n, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
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
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          hintStyle: GoogleFonts.poppins(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
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

