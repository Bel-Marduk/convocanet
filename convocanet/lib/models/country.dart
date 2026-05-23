class Country {
  final String id;
  final String nameEs;
  final String nameEn;
  final String code;

  Country({
    required this.id,
    required this.nameEs,
    required this.nameEn,
    required this.code,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as String,
      nameEs: json['name_es'] as String,
      nameEn: json['name_en'] as String,
      code: json['code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_es': nameEs,
      'name_en': nameEn,
      'code': code,
    };
  }

  String name(String lang) => lang == 'es' ? nameEs : nameEn;
}
