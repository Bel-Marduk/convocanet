import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';

class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isSpanish = locale.languageCode == 'es';

    return TextButton.icon(
      icon: const Icon(Icons.language, size: 18),
      label: Text(
        isSpanish ? 'ES' : 'EN',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onPressed: () {
        ref.read(localeProvider.notifier).toggleLocale();
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
