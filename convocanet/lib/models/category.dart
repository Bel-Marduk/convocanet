class Category {
  final String id;
  final String nameEs;
  final String nameEn;
  final String slug;
  final String? icon;
  final String? color;

  Category({
    required this.id,
    required this.nameEs,
    required this.nameEn,
    required this.slug,
    this.icon,
    this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      nameEs: json['name_es'] as String,
      nameEn: json['name_en'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_es': nameEs,
      'name_en': nameEn,
      'slug': slug,
      'icon': icon,
      'color': color,
    };
  }

  String name(String lang) => lang == 'es' ? nameEs : nameEn;
}
