import 'package:flutter/material.dart';
import 'shimmer_box.dart';

/// Skeleton placeholder that mirrors the shape of a [NoteCard].
/// Supports both list and grid modes.
class NoteCardSkeleton extends StatelessWidget {
  const NoteCardSkeleton({super.key, this.isGrid = false});

  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark ? const Color(0xFF1E1E1E) : theme.colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: isGrid ? _GridContent() : _ListContent(),
    );
  }
}

class _ListContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title row
        Row(
          children: [
            const Expanded(child: ShimmerBox(width: double.infinity, height: 16)),
            const SizedBox(width: 8),
            ShimmerBox(width: 18, height: 18, borderRadius: 4),
          ],
        ),
        const SizedBox(height: 10),
        // Description line 1
        const ShimmerBox(width: double.infinity, height: 12),
        const SizedBox(height: 6),
        // Description line 2 (shorter)
        const ShimmerBox(width: 200, height: 12),
        const SizedBox(height: 14),
        // Footer: date + badge
        Row(
          children: [
            ShimmerBox(width: 80, height: 10, borderRadius: 4),
            const Spacer(),
            ShimmerBox(width: 56, height: 20, borderRadius: 10),
          ],
        ),
      ],
    );
  }
}

class _GridContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title row
        Row(
          children: [
            const Expanded(child: ShimmerBox(width: double.infinity, height: 15)),
            const SizedBox(width: 8),
            ShimmerBox(width: 16, height: 16, borderRadius: 4),
          ],
        ),
        const SizedBox(height: 10),
        // Description lines
        const ShimmerBox(width: double.infinity, height: 11),
        const SizedBox(height: 5),
        const ShimmerBox(width: double.infinity, height: 11),
        const SizedBox(height: 5),
        ShimmerBox(width: 80, height: 11, borderRadius: 4),
        const SizedBox(height: 14),
        // Date
        ShimmerBox(width: 60, height: 9, borderRadius: 4),
      ],
    );
  }
}

/// Renders a shimmer skeleton list/grid that matches the home page layout.
class NoteListSkeleton extends StatelessWidget {
  const NoteListSkeleton({
    super.key,
    this.isGrid = false,
    this.itemCount = 6,
  });

  final bool isGrid;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: itemCount,
        itemBuilder: (_, __) => const NoteCardSkeleton(isGrid: true),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: NoteCardSkeleton(),
      ),
    );
  }
}
