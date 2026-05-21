import 'package:url_launcher/url_launcher.dart';
import '../config/constants.dart';
import '../models/convocatoria.dart';

class WhatsappService {
  // Generate WhatsApp share link for a convocatoria
  static String generateShareLink(Convocatoria convocatoria, String lang) {
    final title = convocatoria.title(lang);
    final amount = convocatoria.formattedAmount;
    final deadline = convocatoria.deadline != null
        ? '${convocatoria.deadline!.day}/${convocatoria.deadline!.month}/${convocatoria.deadline!.year}'
        : (lang == 'es' ? 'Permanente' : 'Permanent');

    final message = '${AppConstants.whatsappMessage}'
        '*$title*\n'
        '${lang == 'es' ? 'Monto' : 'Amount'}: $amount\n'
        '${lang == 'es' ? 'Vence' : 'Deadline'}: $deadline\n\n'
        '${lang == 'es' ? 'Ver más en' : 'See more at'}: '
        'https://convocanet.org/convocatoria/${convocatoria.id}';

    final encodedMessage = Uri.encodeComponent(message);
    return '${AppConstants.whatsappBaseUrl}?text=$encodedMessage';
  }

  // Generate WhatsApp notification link for new convocatoria
  static String generateNotificationLink(Convocatoria convocatoria, String lang) {
    final title = convocatoria.title(lang);
    final amount = convocatoria.formattedAmount;

    final message = '🔔 ${lang == 'es' ? 'Nueva convocatoria en ConvocaNet' : 'New call on ConvocaNet'}!\n\n'
        '*$title*\n'
        '${lang == 'es' ? 'Monto' : 'Amount'}: $amount\n\n'
        '${lang == 'es' ? 'Ver detalles' : 'See details'}: '
        'https://convocanet.org/convocatoria/${convocatoria.id}';

    final encodedMessage = Uri.encodeComponent(message);
    return '${AppConstants.whatsappBaseUrl}?text=$encodedMessage';
  }

  // Open WhatsApp with a link
  static Future<bool> openWhatsApp(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  // Share convocatoria via WhatsApp
  static Future<bool> shareConvocatoria(Convocatoria convocatoria, String lang) async {
    final url = generateShareLink(convocatoria, lang);
    return await openWhatsApp(url);
  }

  // Send notification via WhatsApp
  static Future<bool> sendNotification(Convocatoria convocatoria, String lang) async {
    final url = generateNotificationLink(convocatoria, lang);
    return await openWhatsApp(url);
  }
}
