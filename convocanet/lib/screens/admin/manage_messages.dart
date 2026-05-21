import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';

class ManageMessages extends ConsumerWidget {
  const ManageMessages({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'es' ? 'Mensajes de Contacto' : 'Contact Messages'),
      ),
      body: Center(
        child: Text(
          lang == 'es'
              ? 'Mensajes de contacto - Próximamente'
              : 'Contact messages - Coming soon',
        ),
      ),
    );
  }
}
