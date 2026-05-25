import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../services/convocatoria_service.dart';
import '../../models/country.dart';
import '../../widgets/user_bottom_nav.dart';

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
  String? _selectedCountry;
  List<String> _selectedInterests = [];
  List<Country> _countries = [];

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
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load countries
    try {
      final countries = await ConvocatoriaService.getCountries();
      if (mounted) setState(() => _countries = countries);
    } catch (_) {}

    // Load profile
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getCurrentProfile();
    if (profile != null && mounted) {
      _nameController.text = profile.fullName;
      _orgController.text = profile.organization ?? '';
      _phoneController.text = profile.phone ?? '';
      setState(() {
        _whatsappEnabled = profile.whatsappEnabled;
        _selectedCountry = profile.country;
        _selectedInterests = List.from(profile.interests);
      });
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
          country: _selectedCountry,
          interests: _selectedInterests,
          whatsappEnabled: _whatsappEnabled,
        );
        await AuthService.updateProfile(updated);

        if (mounted) {
          // Invalidate the profile provider to refresh cached data
          ref.invalidate(currentProfileProvider);

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
          tooltip: lang == 'es' ? 'Volver' : 'Back',
        ),
        title: Text(lang == 'es' ? 'Mi Perfil' : 'My Profile'),
      ),
      bottomNavigationBar: UserBottomNav(currentIndex: 3),
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

                      // Name
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

                      // Organization
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

                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: lang == 'es' ? 'Teléfono' : 'Phone',
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Country dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        decoration: InputDecoration(
                          labelText:
                              lang == 'es' ? 'País' : 'Country',
                          prefixIcon:
                              const Icon(Icons.public_outlined),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(
                              lang == 'es'
                                  ? 'Seleccionar país'
                                  : 'Select country',
                            ),
                          ),
                          ..._countries.map((country) => DropdownMenuItem(
                                value: country.nameEs,
                                child: Text(
                                  lang == 'es'
                                      ? country.nameEs
                                      : country.nameEn,
                                ),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCountry = value);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Interests
                      Text(
                        lang == 'es'
                            ? 'Intereses / Sectores'
                            : 'Interests / Sectors',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                            selectedColor: theme.colorScheme.primary
                                .withOpacity(0.15),
                            checkmarkColor: theme.colorScheme.primary,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // WhatsApp toggle
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

                      // Save button
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

                      // Logout button
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
