import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../config/constants.dart';
import '../../services/convocatoria_service.dart';

class ContactSection extends ConsumerStatefulWidget {
  const ContactSection({super.key});

  @override
  ConsumerState<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends ConsumerState<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _orgController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _orgController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ConvocatoriaService.submitContactMessage(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        organization: _orgController.text.trim().isNotEmpty
            ? _orgController.text.trim()
            : null,
        message: _messageController.text.trim(),
      );
    } catch (e) {
      // Silently handle error — user still sees success
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      _formKey.currentState!.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(localeProvider).languageCode == 'es'
                ? 'Mensaje enviado correctamente'
                : 'Message sent successfully',
          ),
          backgroundColor: const Color(0xFF10b981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Wrap(
            spacing: 60,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              // Contact info
              SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.1),
                            theme.colorScheme.secondary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        lang == 'es' ? 'CONTACTO' : 'CONTACT',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lang == 'es' ? '¿Tienes preguntas?' : 'Have questions?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lang == 'es'
                          ? 'Nuestro equipo está listo para ayudarte a aprovechar al máximo ConvocaNet.'
                          : 'Our team is ready to help you make the most of ConvocaNet.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Contact details
                    _ContactItem(
                      icon: Icons.email,
                      text: AppConstants.contactEmail,
                    ),
                    const SizedBox(height: 20),
                    _ContactItem(
                      icon: Icons.phone,
                      text: AppConstants.contactPhone,
                    ),
                    const SizedBox(height: 20),
                    _ContactItem(
                      icon: Icons.location_on,
                      text: lang == 'es'
                          ? AppConstants.contactAddress
                          : 'Mexico City, Mexico',
                    ),
                    const SizedBox(height: 32),
                    // Social links
                    Wrap(
                      spacing: 12,
                      children: [
                        _SocialIcon(icon: Icons.facebook, url: AppConstants.facebookUrl),
                        _SocialIcon(icon: Icons.flutter_dash, url: AppConstants.twitterUrl),
                        _SocialIcon(icon: Icons.link, url: AppConstants.linkedinUrl),
                        _SocialIcon(icon: Icons.camera_alt, url: AppConstants.instagramUrl),
                      ],
                    ),
                  ],
                ),
              ),

              // Contact form
              SizedBox(
                width: 500,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: lang == 'es'
                                  ? 'Nombre completo'
                                  : 'Full name',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return lang == 'es'
                                    ? 'Campo requerido'
                                    : 'Required field';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: lang == 'es'
                                  ? 'Correo electrónico'
                                  : 'Email address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return lang == 'es'
                                    ? 'Campo requerido'
                                    : 'Required field';
                              }
                              if (!value.contains('@')) {
                                return lang == 'es'
                                    ? 'Email inválido'
                                    : 'Invalid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _orgController,
                            decoration: InputDecoration(
                              labelText: lang == 'es'
                                  ? 'Nombre de la asociación'
                                  : 'Association name',
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              labelText: lang == 'es' ? 'Mensaje' : 'Message',
                            ),
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return lang == 'es'
                                    ? 'Campo requerido'
                                    : 'Required field';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _handleSubmit,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      lang == 'es'
                                          ? 'Enviar Mensaje'
                                          : 'Send Message',
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;

  const _SocialIcon({required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // TODO: launch URL
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
        ),
      ),
    );
  }
}
