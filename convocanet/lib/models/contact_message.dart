class ContactMessage {
  final String? id;
  final String name;
  final String email;
  final String? organization;
  final String message;
  final bool read;
  final DateTime? createdAt;

  ContactMessage({
    this.id,
    required this.name,
    required this.email,
    this.organization,
    required this.message,
    this.read = false,
    this.createdAt,
  });

  factory ContactMessage.fromJson(Map<String, dynamic> json) {
    return ContactMessage(
      id: json['id'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      organization: json['organization'] as String?,
      message: json['message'] as String,
      read: json['read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'organization': organization,
      'message': message,
    };
  }
}
