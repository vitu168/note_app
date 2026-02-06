import 'package:flutter/material.dart';
import 'package:note_app/core/constants/color_constant.dart';
import 'package:note_app/core/constants/font_constant.dart';
import 'package:note_app/core/constants/properties_constant.dart';
import 'package:note_app/l10n/app_localizations.dart';

/// A reusable Drawer widget that centralizes the app's side menu UI.
///
/// Provide [onItemSelected] to handle navigation index selections from the
/// parent widget (e.g., `MainPage`).
class MenuDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;

  const MenuDrawer({Key? key, this.selectedIndex = 0, this.onItemSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final textColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppDimensions.radius),
                  bottomRight: Radius.circular(AppDimensions.radius),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: AppDimensions.iconLarge,
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: AppDimensions.spacing),
                  Flexible(
                    child: Text(
                      'Note App',
                      style: AppFonts.heading6.copyWith(color: textColor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildItem(context, index: 0, icon: Icons.home_rounded, label: strings.home),
                  _buildItem(context, index: 1, icon: Icons.star_rounded, label: strings.favorites),
                  _buildItem(context, index: 2, icon: Icons.archive_rounded, label: strings.archive),
                  const Divider(),
                  _buildItem(context, index: 3, icon: Icons.settings_rounded, label: strings.settings),
                  const SizedBox(height: AppDimensions.spacingLarge),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingSmall),
              child: TextButton.icon(
                onPressed: () {
                  // Example: settings or sign out fallback
                  if (onItemSelected != null) onItemSelected!(3);
                },
                icon: const Icon(Icons.logout_rounded, size: AppDimensions.iconSmall),
                label: Text(strings.logout, style: AppFonts.labelMedium),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, {required int index, required IconData icon, required String label}) {
    final selected = index == selectedIndex;
    return ListTile(
      selected: selected,
      selectedTileColor: AppColors.primary.withOpacity(0.08),
      leading: Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondaryLight),
      title: Text(label, style: AppFonts.labelMedium.copyWith(color: selected ? AppColors.primary : AppColors.getTextPrimary(context))),
      onTap: () {
        Navigator.of(context).pop();
        if (onItemSelected != null) onItemSelected!(index);
      },
    );
  }
}
