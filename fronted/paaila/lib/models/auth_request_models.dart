class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  // Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class SignUpRequest {
  final String firstName;
  final String secondName;
  final String email;
  final String password;

  SignUpRequest({
    required this.firstName,
    required this.secondName,
    required this.email,
    required this.password,
  });

  // Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'secondName': secondName,
      'email': email,
      'password': password,
    };
  }

  // Validate request
  String? validate() {
    if (firstName.isEmpty) {
      return 'First name is required';
    }
    if (secondName.isEmpty) {
      return 'Last name is required';
    }
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!_isValidEmail(email)) {
      return 'Please enter a valid email';
    }
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }
}
