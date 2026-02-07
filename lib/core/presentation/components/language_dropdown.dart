import 'package:flutter/material.dart';
import 'package:note_app/core/providers/helper_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageOption {
  final Locale locale;
  final String label;
  final String flag;
  const LanguageOption(this.locale, this.label, this.flag);
}

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  static const _options = [
    LanguageOption(Locale('en'), 'English', '🇺🇸'),
    LanguageOption(Locale('km'), 'ភាសាខ្មែរ', '🇰🇭'),
  ];

  @override
  Widget build(BuildContext context) {
    final helper = context.watch<HelperProvider>();
    final current = helper.locale;

    final selected = _options.firstWhere((o) => o.locale == current, orElse: () => _options[0]);

    return GestureDetector(
      onTap: () async {
        final choice = await showModalBottomSheet<LanguageOption>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _LanguagePicker(options: _options, selected: selected),
        );

        if (choice != null) helper.setLocale(choice.locale);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(selected.label, style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  final List<LanguageOption> options;
  final LanguageOption selected;
  const _LanguagePicker({required this.options, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((o) {
          final isSelected = o.locale == selected.locale;
          return ListTile(
            leading: Text(o.flag, style: const TextStyle(fontSize: 20)),
            title: Text(o.label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
            trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () => Navigator.pop(context, o),
          );
        }).toList(),
      ),
    );
  }
}
