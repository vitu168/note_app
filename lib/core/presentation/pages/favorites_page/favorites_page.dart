import 'package:flutter/material.dart';
import 'package:note_app/core/presentation/pages/favorites_page/favorites_page_provider.dart';
import 'package:note_app/core/presentation/widgets/note_card.dart';
import 'package:note_app/core/constants/color_constant.dart';
import 'package:note_app/core/constants/font_constant.dart';
import 'package:note_app/core/constants/properties_constant.dart';
import 'package:note_app/core/presentation/components/form_text_input.dart';
import 'package:note_app/core/presentation/components/empty_data.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesPageProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<FavoritesPageProvider>();
    final filteredNotes = provider.favorites
        .where((n) =>
            (n.name ?? '')
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            (n.description ?? '')
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.star_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: AppDimensions.spacing),
            Text(
              'Favorites',
              style: AppFonts.heading5.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              color: theme.colorScheme.primary,
            ),
            tooltip: _isGridView ? 'List View' : 'Grid View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            FormTextInput(
              label: 'Search',
              initialValue: _searchController.text,
              onChanged: (v) => setState(() => _searchController.text = v),
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
              decoration: InputDecoration(
                hintText: 'Search...',
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLarge),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLarge),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.13),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLarge),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            const SizedBox(height: 16),
            // Notes list/grid or empty state
            Expanded(
              child: filteredNotes.isEmpty
                  ? const EmptyData(message: 'No favorited notes')
                  : _isGridView
                      ? GridView.builder(
                          itemCount: filteredNotes.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.95,
                          ),
                          itemBuilder: (context, i) =>
                              NoteCard(note: filteredNotes[i]),
                        )
                      : ListView.separated(
                          itemCount: filteredNotes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) =>
                              NoteCard(note: filteredNotes[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
