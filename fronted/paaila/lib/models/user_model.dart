class User {
  final String id;
  final String firstName;
  final String? secondName;
  final String email;
  final String? socketId;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.firstName,
    this.secondName,
    required this.email,
    this.socketId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert JSON to User
  factory User.fromJson(Map<String, dynamic> json) {
    // Handle fullName structure from API
    final fullName = json['fullName'] as Map<String, dynamic>?;
    final firstName =
        fullName?['firstName'] as String? ?? json['firstName'] as String? ?? '';
    final secondName =
        fullName?['secondName'] as String? ?? json['secondName'] as String?;

    return User(
      id: json['_id'] as String,
      firstName: firstName,
      secondName: secondName,
      email: json['email'] as String,
      socketId: json['socketId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': {
        'firstName': firstName,
        if (secondName != null) 'secondName': secondName,
      },
      'email': email,
      'socketId': socketId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Get full name
  String get fullName =>
      secondName != null ? '$firstName $secondName' : firstName;

  // Copy with method for updating user data
  User copyWith({
    String? id,
    String? firstName,
    String? secondName,
    String? email,
    String? socketId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      email: email ?? this.email,
      socketId: socketId ?? this.socketId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
