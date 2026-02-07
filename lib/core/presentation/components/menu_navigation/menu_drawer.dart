import 'package:flutter/material.dart';
import 'package:note_app/core/constants/color_constant.dart';
import 'package:note_app/core/constants/font_constant.dart';
import 'package:note_app/core/constants/properties_constant.dart';
import 'package:note_app/l10n/app_localizations.dart';

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
                color: AppColors.primary.withValues(alpha: 0.06),
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
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: selected ? AppColors.primary.withValues(alpha: 0.03) : Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            if (onItemSelected != null) onItemSelected!(index);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: AppDimensions.iconLarge,
                  height: AppDimensions.iconLarge,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondaryLight, size: AppDimensions.icon),
                ),
                const SizedBox(width: AppDimensions.spacing),
                Expanded(
                  child: Text(
                    label,
                    style: AppFonts.labelMedium.copyWith(color: selected ? AppColors.primary : AppColors.getTextPrimary(context)),
                  ),
                ),
                if (selected)
                  Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: AppDimensions.iconSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
