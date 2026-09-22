class Validators {
  Validators._();

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a name.';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }

    return null;
  }

  static String? email(String? value, {bool strict = true}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an email.';
    }

    if (strict) {
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

      if (!emailRegex.hasMatch(value.trim())) {
        return 'Please enter a valid email.';
      }
    } else if (!value.contains('@')) {
      return 'Enter a valid email';
    }

    return null;
  }

  static String? password(String? value, {bool required = true, int? minLength}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Please enter a password.';
    }

    if (value != null && value.isNotEmpty && minLength != null && value.length < minLength) {
      return 'Password must be at least $minLength characters.';
    }

    return null;
  }
}
