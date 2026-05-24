import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../services/convocatoria_service.dart';

class NewsletterSection extends ConsumerStatefulWidget {
  const NewsletterSection({super.key});

  @override
  ConsumerState<NewsletterSection> createState() => _NewsletterSectionState();
}

class _NewsletterSectionState extends ConsumerState<NewsletterSection> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  bool _submitted = false;
  bool _alreadyExists = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _submitted = false;
      _alreadyExists = false;
    });

    try {
      final result = await ConvocatoriaService.subscribeNewsletter(
        _emailController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _submitting = false;
          if (result) {
            _submitted = true;
            _emailController.clear();
          } else {
            _alreadyExists = true;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: isMobile ? 16 : 24,
      ),
      color: isDark ? const Color(0xFF1e293b) : const Color(0xFFF8fafc),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeft(theme, lang, isDark),
                    const SizedBox(height: 40),
                    _buildForm(theme, lang, isDark),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildLeft(theme, lang, isDark)),
                    const SizedBox(width: 60),
                    Expanded(child: _buildForm(theme, lang, isDark)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLeft(ThemeData theme, String lang, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                theme.colorScheme.secondary.withOpacity(isDark ? 0.2 : 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            'NEWSLETTER',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
              letterSpacing: 0.1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          lang == 'es' ? 'Apuesta por el cambio' : 'Bet on change',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.02,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          lang == 'es'
              ? 'Descubre oportunidades exclusivas y las últimas convocatorias. ¡Suscríbete a nuestro Newsletter y no te pierdas ninguna oportunidad!'
              : 'Discover exclusive opportunities and the latest calls. Subscribe to our Newsletter and never miss an opportunity!',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(ThemeData theme, String lang, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15.2),
                    decoration: InputDecoration(
                      hintText: lang == 'es'
                          ? 'Ingresa tu email'
                          : 'Enter your email',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return lang == 'es'
                            ? 'Ingresa tu email'
                            : 'Enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return lang == 'es'
                            ? 'Email no válido'
                            : 'Invalid email';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4f46e5), Color(0xFF3730a3)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              lang == 'es' ? 'Suscribirse' : 'Subscribe',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.4,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_submitted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF10b981), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lang == 'es'
                        ? '¡Suscripción exitosa! Pronto recibirás nuestras novedades.'
                        : 'Successfully subscribed! You\'ll receive our updates soon.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF10b981),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_alreadyExists) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFF59e0b), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lang == 'es'
                        ? 'Este email ya está suscrito.'
                        : 'This email is already subscribed.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFF59e0b),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
