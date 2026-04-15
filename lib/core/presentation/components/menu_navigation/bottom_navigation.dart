import 'package:flutter/material.dart';
import 'package:note_app/l10n/app_localizations.dart';

/// Dark pill-shaped floating bottom navigation bar with an integrated FAB.
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTapped;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabTapped,
  });

  static const Color _kNavBg = Color(0xFF1A1826);
  static const Color _kIconInactive = Color(0xFF9E9EB8);

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final Color accent = Theme.of(context).colorScheme.primary;

    return Semantics(
      container: true,
      label: 'Main navigation',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  color: _kNavBg,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: strings.home,
                      selected: currentIndex == 0,
                      accent: accent,
                      inactiveColor: _kIconInactive,
                      onTap: () => onTap(0),
                    ),
                    _NavItem(
                      icon: Icons.star_outline_rounded,
                      activeIcon: Icons.star_rounded,
                      label: strings.favorites,
                      selected: currentIndex == 1,
                      accent: accent,
                      inactiveColor: _kIconInactive,
                      onTap: () => onTap(1),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: strings.profile,
                      selected: currentIndex == 2,
                      accent: accent,
                      inactiveColor: _kIconInactive,
                      onTap: () => onTap(2),
                    ),
                    _NavItem(
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings_rounded,
                      label: strings.settings,
                      selected: currentIndex == 3,
                      accent: accent,
                      inactiveColor: _kIconInactive,
                      onTap: () => onTap(3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onFabTapped,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final Color accent;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.accent,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: label,
        selected: selected,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  selected ? activeIcon : icon,
                  key: ValueKey(selected),
                  color: selected ? accent : inactiveColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: selected ? 1.0 : 0.0,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
