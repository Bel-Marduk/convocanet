class Convocatoria {
  final String id;
  final String titleEs;
  final String titleEn;
  final String descriptionEs;
  final String descriptionEn;
  final String? requirementsEs;
  final String? requirementsEn;
  final String? categoryId;
  final String? categoryNameEs;
  final String? categoryNameEn;
  final String? categorySlug;
  final String? categoryIcon;
  final String? categoryColor;
  final double? amountUsd;
  final double? amountLocal;
  final String currency;
  final DateTime? deadline;
  final String? regionEs;
  final String? regionEn;
  final String? sourceUrl;
  final String? sourceName;
  final String status; // 'active', 'permanent', 'expired', 'draft'
  final bool isPublic;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Convocatoria({
    required this.id,
    required this.titleEs,
    required this.titleEn,
    required this.descriptionEs,
    required this.descriptionEn,
    this.requirementsEs,
    this.requirementsEn,
    this.categoryId,
    this.categoryNameEs,
    this.categoryNameEn,
    this.categorySlug,
    this.categoryIcon,
    this.categoryColor,
    this.amountUsd,
    this.amountLocal,
    this.currency = 'USD',
    this.deadline,
    this.regionEs,
    this.regionEn,
    this.sourceUrl,
    this.sourceName,
    this.status = 'active',
    this.isPublic = true,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Convocatoria.fromJson(Map<String, dynamic> json) {
    return Convocatoria(
      id: json['id'] as String,
      titleEs: json['title_es'] as String,
      titleEn: json['title_en'] as String,
      descriptionEs: json['description_es'] as String,
      descriptionEn: json['description_en'] as String,
      requirementsEs: json['requirements_es'] as String?,
      requirementsEn: json['requirements_en'] as String?,
      categoryId: json['category_id'] as String?,
      categoryNameEs: json['categories']?['name_es'] as String?,
      categoryNameEn: json['categories']?['name_en'] as String?,
      categorySlug: json['categories']?['slug'] as String?,
      categoryIcon: json['categories']?['icon'] as String?,
      categoryColor: json['categories']?['color'] as String?,
      amountUsd: (json['amount_usd'] as num?)?.toDouble(),
      amountLocal: (json['amount_local'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      regionEs: json['region_es'] as String?,
      regionEn: json['region_en'] as String?,
      sourceUrl: json['source_url'] as String?,
      sourceName: json['source_name'] as String?,
      status: json['status'] as String? ?? 'active',
      isPublic: json['is_public'] as bool? ?? true,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_es': titleEs,
      'title_en': titleEn,
      'description_es': descriptionEs,
      'description_en': descriptionEn,
      'requirements_es': requirementsEs,
      'requirements_en': requirementsEn,
      'category_id': categoryId,
      'amount_usd': amountUsd,
      'amount_local': amountLocal,
      'currency': currency,
      'deadline': deadline?.toIso8601String().split('T')[0],
      'region_es': regionEs,
      'region_en': regionEn,
      'source_url': sourceUrl,
      'source_name': sourceName,
      'status': status,
      'is_public': isPublic,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String title(String lang) => lang == 'es' ? titleEs : titleEn;
  String description(String lang) => lang == 'es' ? descriptionEs : descriptionEn;
  String? requirements(String lang) => lang == 'es' ? requirementsEs : requirementsEn;
  String? categoryName(String lang) => lang == 'es' ? categoryNameEs : categoryNameEn;
  String? region(String lang) => lang == 'es' ? regionEs : regionEn;

  List<String> countries(String lang) {
    final r = region(lang);
    if (r == null || r.isEmpty) return [];
    return r.split(',').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
  }

  String get formattedAmount {
    final displayAmount = amountLocal ?? amountUsd;
    if (displayAmount == null) return 'N/A';
    final symbol = _currencySymbol(currency);
    return '$symbol${displayAmount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )} $currency';
  }

  static String _currencySymbol(String code) {
    switch (code) {
      case 'MXN': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'CAD': return 'C\$';
      case 'BRL': return 'R\$';
      case 'ARS': return 'AR\$';
      case 'COP': return 'COL\$';
      case 'CLP': return 'CL\$';
      case 'PEN': return 'S/';
      case 'GTQ': return 'Q';
      case 'CRC': return '₡';
      case 'PAB': return 'B/.';
      case 'BOB': return 'Bs';
      case 'PYG': return '₲';
      case 'UYU': return '\$U';
      case 'VES': return 'Bs.S';
      case 'HNL': return 'L';
      case 'NIO': return 'C\$';
      case 'DOP': return 'RD\$';
      case 'CUP': return '₱';
      case 'HTG': return 'G';
      case 'JMD': return 'J\$';
      case 'TTD': return 'TT\$';
      default: return '\$';
    }
  }

  bool get isActive => status == 'active';
  bool get isPermanent => status == 'permanent';
  bool get isExpired => status == 'expired';
  bool get isOpen => isActive || isPermanent;

  String statusLabel(String lang) {
    switch (status) {
      case 'active':
        return lang == 'es' ? 'Activa' : 'Active';
      case 'permanent':
        return lang == 'es' ? 'Permanente' : 'Permanent';
      case 'expired':
        return lang == 'es' ? 'Vencida' : 'Expired';
      case 'draft':
        return lang == 'es' ? 'Borrador' : 'Draft';
      default:
        return status;
    }
  }
}
