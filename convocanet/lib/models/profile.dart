class Profile {
  final String id;
  final String fullName;
  final String? organization;
  final String? phone;
  final String? country;
  final List<String> interests;
  final String role; // 'user' or 'admin'
  final bool whatsappEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.fullName,
    this.organization,
    this.phone,
    this.country,
    this.interests = const [],
    this.role = 'user',
    this.whatsappEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      organization: json['organization'] as String?,
      phone: json['phone'] as String?,
      country: json['country'] as String?,
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      role: json['role'] as String? ?? 'user',
      whatsappEnabled: json['whatsapp_enabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'organization': organization,
      'phone': phone,
      'country': country,
      'interests': interests,
      'role': role,
      'whatsapp_enabled': whatsappEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';

  Profile copyWith({
    String? fullName,
    String? organization,
    String? phone,
    String? country,
    List<String>? interests,
    bool? whatsappEnabled,
  }) {
    return Profile(
      id: id,
      fullName: fullName ?? this.fullName,
      organization: organization ?? this.organization,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      interests: interests ?? this.interests,
      role: role,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
