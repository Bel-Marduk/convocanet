import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/locale_provider.dart';
import '../../models/convocatoria.dart';
import '../../models/category.dart';
import '../../services/convocatoria_service.dart';
import '../../models/country.dart';

class EditConvocatoriaScreen extends ConsumerStatefulWidget {
  final String? convocatoriaId;

  const EditConvocatoriaScreen({super.key, this.convocatoriaId});

  @override
  ConsumerState<EditConvocatoriaScreen> createState() =>
      _EditConvocatoriaScreenState();
}

class _EditConvocatoriaScreenState
    extends ConsumerState<EditConvocatoriaScreen> {
  static const _currencies = [
    'MXN', 'USD', 'EUR', 'GBP', 'CAD', 'BRL',
    'ARS', 'COP', 'CLP', 'PEN', 'GTQ', 'CRC',
    'PAB', 'BOB', 'PYG', 'UYU', 'VES', 'HNL',
    'NIO', 'DOP',
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleEsController = TextEditingController();
  final _titleEnController = TextEditingController();
  final _descEsController = TextEditingController();
  final _descEnController = TextEditingController();
  final _reqEsController = TextEditingController();
  final _reqEnController = TextEditingController();
  final _amountController = TextEditingController();
  final _sourceUrlController = TextEditingController();
  final _sourceNameController = TextEditingController();

  String _status = 'active';
  String _currency = 'MXN';
  String? _categoryId;
  bool _isPublic = true;
  DateTime? _deadline;
  bool _isLoading = false;
  bool _isEditing = false;
  List<Category> _categories = [];
  List<Country> _countries = [];
  List<int> _selectedCountryIndices = [];

  @override
  void initState() {
    super.initState();
    if (widget.convocatoriaId != null) {
      _isEditing = true;
      _initForEdit();
    } else {
      _loadCategories();
      _loadCountries();
    }
  }

  Future<void> _initForEdit() async {
    await _loadCategories();
    await _loadCountries();
    await _loadConvocatoria();
  }

  Future<void> _loadCategories() async {
    final categories = await ConvocatoriaService.getCategories();
    setState(() => _categories = categories);
  }

  Future<void> _loadCountries() async {
    final countries = await ConvocatoriaService.getCountries();
    setState(() => _countries = countries);
  }

  Future<void> _loadConvocatoria() async {
    final conv =
        await ConvocatoriaService.getConvocatoriaById(widget.convocatoriaId!);
    if (conv != null) {
      _titleEsController.text = conv.titleEs;
      _titleEnController.text = conv.titleEn;
      _descEsController.text = conv.descriptionEs;
      _descEnController.text = conv.descriptionEn;
      _reqEsController.text = conv.requirementsEs ?? '';
      _reqEnController.text = conv.requirementsEn ?? '';
      _amountController.text = (conv.amountLocal ?? conv.amountUsd)?.toString() ?? '';
      _sourceUrlController.text = conv.sourceUrl ?? '';
      // Parse selected countries from regionEs
      if (conv.regionEs != null && conv.regionEs!.isNotEmpty) {
        final saved = conv.regionEs!.split(',').map((c) => c.trim()).toList();
        _selectedCountryIndices = [];
        for (int i = 0; i < _countries.length; i++) {
          if (saved.contains(_countries[i].nameEs)) {
            _selectedCountryIndices.add(i);
          }
        }
      }
      _sourceNameController.text = conv.sourceName ?? '';
      setState(() {
        _status = conv.status;
        _currency = conv.currency;
        _categoryId = conv.categoryId;
        _isPublic = conv.isPublic;
        _deadline = conv.deadline;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final convocatoria = Convocatoria(
        id: widget.convocatoriaId ?? '',
        titleEs: _titleEsController.text.trim(),
        titleEn: _titleEnController.text.trim(),
        descriptionEs: _descEsController.text.trim(),
        descriptionEn: _descEnController.text.trim(),
        requirementsEs: _reqEsController.text.trim().isNotEmpty
            ? _reqEsController.text.trim()
            : null,
        requirementsEn: _reqEnController.text.trim().isNotEmpty
            ? _reqEnController.text.trim()
            : null,
        categoryId: _categoryId,
        amountUsd: null,
        amountLocal: _amountController.text.isNotEmpty
            ? double.tryParse(_amountController.text)
            : null,
        currency: _currency,
        deadline: _deadline,
        regionEs: _selectedCountryIndices.isNotEmpty
            ? _selectedCountryIndices.map((i) => _countries[i].nameEs).join(', ')
            : null,
        regionEn: _selectedCountryIndices.isNotEmpty
            ? _selectedCountryIndices.map((i) => _countries[i].nameEn).join(', ')
            : null,
        sourceUrl: _sourceUrlController.text.trim().isNotEmpty
            ? _sourceUrlController.text.trim().replaceAll(RegExp(r'\s+'), '')
            : null,
        sourceName: _sourceNameController.text.trim().isNotEmpty
            ? _sourceNameController.text.trim()
            : null,
        status: _status,
        isPublic: _isPublic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await ConvocatoriaService.updateConvocatoria(convocatoria);
      } else {
        await ConvocatoriaService.createConvocatoria(convocatoria);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(localeProvider).languageCode == 'es'
                  ? 'Convocatoria guardada'
                  : 'Call saved',
            ),
            backgroundColor: const Color(0xFF10b981),
          ),
        );
        context.go('/admin/convocatorias');
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
  void dispose() {
    _titleEsController.dispose();
    _titleEnController.dispose();
    _descEsController.dispose();
    _descEnController.dispose();
    _reqEsController.dispose();
    _reqEnController.dispose();
    _amountController.dispose();
    _sourceUrlController.dispose();
    _sourceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title ES
                      TextFormField(
                        controller: _titleEsController,
                        decoration: const InputDecoration(
                          labelText: 'Título (Español)',
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Campo requerido'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Title EN
                      TextFormField(
                        controller: _titleEnController,
                        decoration: const InputDecoration(
                          labelText: 'Title (English)',
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Required field'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Description ES
                      TextFormField(
                        controller: _descEsController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción (Español)',
                        ),
                        maxLines: 3,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Campo requerido'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Description EN
                      TextFormField(
                        controller: _descEnController,
                        decoration: const InputDecoration(
                          labelText: 'Description (English)',
                        ),
                        maxLines: 3,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Required field'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Category
                      DropdownButtonFormField<String>(
                        value: _categoryId,
                        decoration: InputDecoration(
                          labelText: lang == 'es' ? 'Categoría' : 'Category',
                        ),
                        items: _categories
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name(lang)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _categoryId = value);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Amount, Currency and Status
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: 180,
                            child: TextFormField(
                              controller: _amountController,
                              decoration: InputDecoration(
                                labelText: lang == 'es' ? 'Monto' : 'Amount',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(
                            width: 160,
                            child: DropdownButtonFormField<String>(
                              value: _currency,
                              decoration: InputDecoration(
                                labelText: lang == 'es' ? 'Moneda' : 'Currency',
                              ),
                              items: _currencies.map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              )).toList(),
                              onChanged: (value) {
                                setState(() => _currency = value!);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: DropdownButtonFormField<String>(
                              value: _status,
                              decoration: InputDecoration(
                                labelText: lang == 'es' ? 'Estado' : 'Status',
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'active',
                                  child: Text(lang == 'es' ? 'Activa' : 'Active'),
                                ),
                                DropdownMenuItem(
                                  value: 'pending',
                                  child: Text(lang == 'es' ? 'Pendiente' : 'Pending'),
                                ),
                                DropdownMenuItem(
                                  value: 'permanent',
                                  child: Text(lang == 'es' ? 'Permanente' : 'Permanent'),
                                ),
                                DropdownMenuItem(
                                  value: 'draft',
                                  child: Text(lang == 'es' ? 'Borrador' : 'Draft'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _status = value!);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Deadline
                      ListTile(
                        title: Text(
                          _deadline != null
                              ? '${lang == 'es' ? 'Fecha límite' : 'Deadline'}: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                              : (lang == 'es'
                                  ? 'Seleccionar fecha límite'
                                  : 'Select deadline'),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _deadline ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => _deadline = date);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Countries
                      Text(
                        lang == 'es' ? 'Países que aplican' : 'Eligible countries',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_countries.length, (i) {
                          final selected = _selectedCountryIndices.contains(i);
                          final label = _countries[i].name(lang);
                          return FilterChip(
                            label: Text(label),
                            selected: selected,
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  _selectedCountryIndices.add(i);
                                } else {
                                  _selectedCountryIndices.remove(i);
                                }
                              });
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      // Requirements
                      TextFormField(
                        controller: _reqEsController,
                        decoration: const InputDecoration(
                          labelText: 'Requisitos (Español)',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reqEnController,
                        decoration: const InputDecoration(
                          labelText: 'Requirements (English)',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Source
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: 250,
                            child: TextFormField(
                              controller: _sourceUrlController,
                              decoration: const InputDecoration(
                                labelText: 'URL Fuente',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            child: TextFormField(
                              controller: _sourceNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre Fuente',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Public/Private
                      SwitchListTile(
                        title: Text(
                          lang == 'es' ? 'Convocatoria pública' : 'Public call',
                        ),
                        value: _isPublic,
                        onChanged: (value) {
                          setState(() => _isPublic = value);
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
                                  lang == 'es' ? 'Guardar' : 'Save',
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
    );
  }
}
