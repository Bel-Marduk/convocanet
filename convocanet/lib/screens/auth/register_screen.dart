import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/locale_provider.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _orgController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final List<String> _selectedInterests = [];

  final _interests = [
    ('educacion', 'Educación', 'Education'),
    ('salud', 'Salud', 'Health'),
    ('cultura', 'Cultura', 'Culture'),
    ('social', 'Desarrollo Social', 'Social Development'),
    ('tecnologia', 'Tecnología', 'Technology'),
    ('genero', 'Género', 'Gender'),
    ('alimentacion', 'Alimentación', 'Food'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _orgController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        organization: _orgController.text.trim().isNotEmpty
            ? _orgController.text.trim()
            : null,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        interests: _selectedInterests,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(localeProvider).languageCode == 'es'
                  ? 'Cuenta creada. Revisa tu correo para verificar.'
                  : 'Account created. Check your email to verify.',
            ),
            backgroundColor: const Color(0xFF10b981),
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.campaign,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      lang == 'es' ? 'Crear Cuenta' : 'Create Account',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 32),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: lang == 'es'
                                  ? 'Nombre completo'
                                  : 'Full name',
                              prefixIcon: const Icon(Icons.person_outlined),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? (lang == 'es' ? 'Requerido' : 'Required')
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: lang == 'es'
                                  ? 'Correo electrónico'
                                  : 'Email address',
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return lang == 'es' ? 'Requerido' : 'Required';
                              }
                              if (!v.contains('@')) {
                                return lang == 'es'
                                    ? 'Email inválido'
                                    : 'Invalid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: lang == 'es'
                                  ? 'Contraseña'
                                  : 'Password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return lang == 'es' ? 'Requerido' : 'Required';
                              }
                              if (v.length < 6) {
                                return lang == 'es'
                                    ? 'Mínimo 6 caracteres'
                                    : 'Minimum 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmController,
                            decoration: InputDecoration(
                              labelText: lang == 'es'
                                  ? 'Confirmar contraseña'
                                  : 'Confirm password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                            ),
                            obscureText: true,
                            validator: (v) {
                              if (v != _passwordController.text) {
                                return lang == 'es'
                                    ? 'Las contraseñas no coinciden'
                                    : 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _orgController,
                            decoration: InputDecoration(
                              labelText: lang == 'es'
                                  ? 'Nombre de la organización'
                                  : 'Organization name',
                              prefixIcon: const Icon(Icons.business_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: lang == 'es' ? 'Teléfono' : 'Phone',
                              prefixIcon: const Icon(Icons.phone_outlined),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 24),

                          // Interests
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              lang == 'es'
                                  ? 'Selecciona tus intereses'
                                  : 'Select your interests',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _interests.map((interest) {
                              final isSelected =
                                  _selectedInterests.contains(interest.$1);
                              return FilterChip(
                                label: Text(
                                  lang == 'es' ? interest.$2 : interest.$3,
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedInterests.add(interest.$1);
                                    } else {
                                      _selectedInterests.remove(interest.$1);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              child: _isLoading
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
                                          ? 'Crear Cuenta'
                                          : 'Create Account',
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lang == 'es'
                              ? '¿Ya tienes cuenta?'
                              : 'Already have an account?',
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(
                            lang == 'es' ? 'Iniciar Sesión' : 'Sign in',
                          ),
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
