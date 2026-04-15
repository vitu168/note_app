import 'package:flutter/material.dart';
import 'shimmer_box.dart';

/// Skeleton placeholder that mirrors the shape of a [_UserTile] in ChatPage.
class UserTileSkeleton extends StatelessWidget {
  const UserTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.transparent,
      child: Row(
        children: [
          // Avatar circle
          ShimmerBox(width: 50, height: 50, borderRadius: 25),
          const SizedBox(width: 14),
          // Name + email column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140, height: 14, borderRadius: 6),
                const SizedBox(height: 7),
                ShimmerBox(width: 180, height: 11, borderRadius: 5),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Badge pill
          ShimmerBox(width: 52, height: 22, borderRadius: 11),
          const SizedBox(width: 6),
          // Chevron
          ShimmerBox(width: 16, height: 16, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Renders a shimmer skeleton list of user tiles.
class UserListSkeleton extends StatelessWidget {
  const UserListSkeleton({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 84,
        color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
      ),
      itemBuilder: (_, __) => const UserTileSkeleton(),
    );
  }
}
