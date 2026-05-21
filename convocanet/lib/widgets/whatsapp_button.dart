import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/convocatoria.dart';
import '../providers/locale_provider.dart';
import '../services/whatsapp_service.dart';

class WhatsAppButton extends ConsumerWidget {
  final Convocatoria convocatoria;
  final bool isNotification;
  final VoidCallback? onPressed;

  const WhatsAppButton({
    super.key,
    required this.convocatoria,
    this.isNotification = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;

    return ElevatedButton.icon(
      icon: const Icon(Icons.share, size: 18),
      label: Text(
        isNotification
            ? (lang == 'es' ? 'Notificar por WhatsApp' : 'Notify via WhatsApp')
            : (lang == 'es' ? 'Compartir por WhatsApp' : 'Share via WhatsApp'),
      ),
      onPressed: onPressed ??
          () async {
            if (isNotification) {
              await WhatsappService.sendNotification(convocatoria, lang);
            } else {
              await WhatsappService.shareConvocatoria(convocatoria, lang);
            }
          },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
      ),
    );
  }
}
