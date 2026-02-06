import 'package:flutter/material.dart';
import 'package:note_app/core/constants/color_constant.dart';
import 'package:note_app/core/constants/properties_constant.dart';
import 'package:note_app/l10n/app_localizations.dart';

/// Reusable bottom navigation component used across the app.
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge * 3),
        child: BottomNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          currentIndex: currentIndex,
          onTap: onTap,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondaryLight,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: AppDimensions.elevation,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: strings.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.star_rounded),
              label: strings.favorites,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.archive_rounded),
              label: strings.archive,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              label: strings.settings,
            ),
          ],
        ),
      ),
    );
  }
}
