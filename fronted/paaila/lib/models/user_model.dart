class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? bio;
  final DateTime createdAt;
  final bool isEmailVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.bio,
    required this.createdAt,
    this.isEmailVerified = false,
  });

  // Convert JSON to User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImage: json['profileImage'] as String?,
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
    };
  }

  // Copy with method for updating user data
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    String? bio,
    DateTime? createdAt,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
