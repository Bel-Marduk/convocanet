import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';

class ManageUsers extends ConsumerWidget {
  const ManageUsers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'es' ? 'Gestionar Usuarios' : 'Manage Users'),
      ),
      body: Center(
        child: Text(
          lang == 'es'
              ? 'Gestión de usuarios - Próximamente'
              : 'User management - Coming soon',
        ),
      ),
    );
  }
}
