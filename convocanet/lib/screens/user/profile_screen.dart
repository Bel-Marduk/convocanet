import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _orgController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _whatsappEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getCurrentProfile();
    if (profile != null && mounted) {
      _nameController.text = profile.fullName;
      _orgController.text = profile.organization ?? '';
      _phoneController.text = profile.phone ?? '';
      setState(() => _whatsappEnabled = profile.whatsappEnabled);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentProfile = await AuthService.getCurrentProfile();
      if (currentProfile != null) {
        final updated = currentProfile.copyWith(
          fullName: _nameController.text.trim(),
          organization: _orgController.text.trim().isNotEmpty
              ? _orgController.text.trim()
              : null,
          phone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          whatsappEnabled: _whatsappEnabled,
        );
        await AuthService.updateProfile(updated);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ref.read(localeProvider).languageCode == 'es'
                    ? 'Perfil actualizado'
                    : 'Profile updated',
              ),
              backgroundColor: const Color(0xFF10b981),
            ),
          );
        }
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

  Future<void> _handleLogout() async {
    await AuthService.signOut();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orgController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'es' ? 'Mi Perfil' : 'My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang == 'es' ? 'Mi Perfil' : 'My Profile',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 32),
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
                        controller: _orgController,
                        decoration: InputDecoration(
                          labelText: lang == 'es'
                              ? 'Organización'
                              : 'Organization',
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
                      SwitchListTile(
                        title: Text(
                          lang == 'es'
                              ? 'Notificaciones por WhatsApp'
                              : 'WhatsApp notifications',
                        ),
                        subtitle: Text(
                          lang == 'es'
                              ? 'Recibir alertas de nuevas convocatorias'
                              : 'Receive alerts for new calls',
                        ),
                        value: _whatsappEnabled,
                        onChanged: (value) {
                          setState(() => _whatsappEnabled = value);
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSave,
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
                                      ? 'Guardar cambios'
                                      : 'Save changes',
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _handleLogout,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                          child: Text(
                            lang == 'es' ? 'Cerrar sesión' : 'Sign out',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
