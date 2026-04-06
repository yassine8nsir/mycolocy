/// Reusable form field validators — used across Login, Register, etc.
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Minimum 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Add at least one uppercase letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Add at least one number';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone is required';
    final regex = RegExp(r'^\+?[0-9]{8,15}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid phone number';
    return null;
  }
}
