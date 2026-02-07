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
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge * 3),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge * 3),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            child: Semantics(
              container: true,
              label: 'Main navigation',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _NavItem(
                          icon: Icons.home_rounded,
                          label: strings.home,
                          selected: currentIndex == 0,
                          onTap: () => onTap(0),
                        ),
                        _NavItem(
                          icon: Icons.favorite_rounded,
                          label: strings.favorites,
                          selected: currentIndex == 1,
                          onTap: () => onTap(1),
                        ),
                        _NavItem(
                          icon: Icons.archive_rounded,
                          label: strings.archive,
                          selected: currentIndex == 2,
                          onTap: () => onTap(2),
                        ),
                        _NavItem(
                          icon: Icons.settings_rounded,
                          label: strings.settings,
                          selected: currentIndex == 3,
                          onTap: () => onTap(3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Telegram-style compact navigation item (icon-only with circular selected background).
class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label; // used for semantics/accessibility
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;
  bool _pressed = false;

  void _setHover(bool v) {
    if (_hover == v) return;
    setState(() => _hover = v);
  }

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedBg = AppColors.primary;
    final Color selectedIconColor = Colors.white;
    final Color unselectedIconColor = Theme.of(context).iconTheme.color ?? AppColors.textSecondaryLight;

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => _setHover(true),
        onExit: (_) => _setHover(false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          behavior: HitTestBehavior.translucent,
          child: Semantics(
            container: true,
            label: widget.label,
            selected: widget.selected,
            child: AnimatedContainer(
              duration: AppDimensions.duration,
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              transform: Matrix4.identity()
                ..translate(0.0, _hover ? -4.0 : 0.0)
                ..scale(_pressed ? 0.97 : (_hover ? 1.03 : 1.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // circular icon background like Telegram (smaller)
                  AnimatedContainer(
                    duration: AppDimensions.duration,
                    curve: Curves.easeOutCubic,
                    width: widget.selected ? 40 : (_hover ? 36 : 34),
                    height: widget.selected ? 40 : (_hover ? 36 : 34),
                    decoration: BoxDecoration(
                      color: widget.selected ? selectedBg : (_hover ? Theme.of(context).colorScheme.surface.withOpacity(0.04) : Colors.transparent),
                      shape: BoxShape.circle,
                      boxShadow: widget.selected
                          ? [
                              BoxShadow(
                                color: selectedBg.withOpacity(0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              )
                            ]
                          : (_hover
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        splashColor: Colors.white.withOpacity(0.12),
                        highlightColor: Colors.white.withOpacity(0.06),
                        onTap: widget.onTap,
                        child: Center(
                          child: Icon(
                            widget.icon,
                            size: widget.selected ? 20 : 18,
                            color: widget.selected ? selectedIconColor : unselectedIconColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // small active indicator dot when selected (Telegram-like)
                  AnimatedOpacity(
                    duration: AppDimensions.duration,
                    opacity: widget.selected ? 1.0 : 0.0,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: widget.selected ? selectedBg : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
