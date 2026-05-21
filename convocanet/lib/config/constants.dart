class AppConstants {
  static const String appName = 'ConvocaNet';
  static const String appVersion = '1.0.0';

  // Supabase — Configurar con --dart-define-from-file=config.json
  // O reemplazar directamente los valores por defecto
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_PROJECT.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_ANON_KEY',
  );

  // WhatsApp message template
  static const String whatsappBaseUrl = 'https://wa.me/';
  static const String whatsappMessage = '¡Nueva convocatoria en ConvocaNet!\n\n';

  // Contact info
  static const String contactEmail = 'contacto@convocanet.org';
  static const String contactPhone = '+525512345678';
  static const String contactAddress = 'Ciudad de México, México';

  // Social links
  static const String facebookUrl = 'https://facebook.com/convocanet';
  static const String twitterUrl = 'https://twitter.com/convocanet';
  static const String linkedinUrl = 'https://linkedin.com/company/convocanet';
  static const String instagramUrl = 'https://instagram.com/convocanet';
}
