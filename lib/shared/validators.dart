/// shared/validators.dart
///
/// Simple email, phone and password validator utilities for Flutter/Dart projects.
library;

// shared/validator_type.dart
enum ValidatorType { none, email, phone, password }

class Validators {
  // A reasonably permissive, widely used email validation regex.
  // It covers most valid email addresses without trying to fully implement RFC5322.
  static final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
    r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
    r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    caseSensitive: false,
  );

  /// Returns true if [email] is a non-null, non-empty string that matches the email pattern.
  static bool isValidEmail(String? email) {
    if (email == null) return false;
    final trimmed = email.trim();
    if (trimmed.isEmpty) return false;
    return _emailRegExp.hasMatch(trimmed);
  }

  /// Typical validator function for Flutter FormField validators.
  ///
  /// Returns null when valid, otherwise returns an error message.
  /// Optional custom error messages can be provided.
  static String? emailValidator(
    String? value, {
    String emptyMessage = 'Please enter an email address',
    String invalidMessage = 'Please enter a valid email address',
  }) {
    if (value == null || value.trim().isEmpty) return emptyMessage;
    return isValidEmail(value) ? null : invalidMessage;
  }

  /// Returns true if [phone] is a non-null, non-empty string that looks like a phone number.
  ///
  /// This is a permissive validator:
  /// - Strips non-digit characters and ensures there are between [minDigits] and [maxDigits] digits.
  /// - Allows characters commonly used in phone numbers: digits, spaces, parentheses, hyphens, dots and a leading plus.
  static bool isValidPhone(String? phone,
      {int minDigits = 7, int maxDigits = 15}) {
    if (phone == null) return false;
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return false;

    // Count digits only
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length < minDigits || digits.length > maxDigits) return false;

    // Allow only a sensible set of characters
    final allowed = RegExp(r'^[+\d\s().-]+$');
    return allowed.hasMatch(trimmed);
  }

  /// Typical validator function for Flutter FormField validators for phone numbers.
  ///
  /// Returns null when valid, otherwise returns an error message.
  static String? phoneValidator(
    String? value, {
    String emptyMessage = 'Please enter a phone number',
    String invalidMessage = 'Please enter a valid phone number',
    int minDigits = 7,
    int maxDigits = 15,
  }) {
    if (value == null || value.trim().isEmpty) return emptyMessage;
    return isValidPhone(value, minDigits: minDigits, maxDigits: maxDigits)
        ? null
        : invalidMessage;
  }

  /// Returns true if [password] meets the provided policy.
  ///
  /// Default policy:
  /// - Minimum length: 8
  /// - Require uppercase: true
  /// - Require lowercase: true
  /// - Require digit: true
  /// - Require special character: false (use common punctuation if enabled)
  static bool isValidPassword(
    String? password, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireDigit = true,
    bool requireSpecial = false,
  }) {
    if (password == null) return false;
    final trimmed = password.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.length < minLength) return false;

    if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(trimmed)) return false;
    if (requireLowercase && !RegExp(r'[a-z]').hasMatch(trimmed)) return false;
    if (requireDigit && !RegExp(r'\d').hasMatch(trimmed)) return false;

    if (requireSpecial) {
      // Common set of special characters used in passwords.
      final special = RegExp(r"""[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\\/;'`~]""");
      if (!special.hasMatch(trimmed)) return false;
    }

    return true;
  }

  /// Typical validator function for Flutter FormField validators for passwords.
  ///
  /// Checks password against a configurable policy and returns null when valid,
  /// otherwise returns the first failing error message.
  static String? passwordValidator(
    String? value, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireDigit = true,
    bool requireSpecial = false,
    String emptyMessage = 'Please enter a password',
    String tooShortMessage = 'Password is too short',
    String missingUppercaseMessage =
        'Password must contain an uppercase letter',
    String missingLowercaseMessage = 'Password must contain a lowercase letter',
    String missingDigitMessage = 'Password must contain a digit',
    String missingSpecialMessage = 'Password must contain a special character',
  }) {
    if (value == null || value.trim().isEmpty) return emptyMessage;
    final trimmed = value.trim();
    if (trimmed.length < minLength) return tooShortMessage;
    if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(trimmed)) {
      return missingUppercaseMessage;
    }
    if (requireLowercase && !RegExp(r'[a-z]').hasMatch(trimmed)) {
      return missingLowercaseMessage;
    }
    if (requireDigit && !RegExp(r'\d').hasMatch(trimmed)) {
      return missingDigitMessage;
    }
    if (requireSpecial) {
      final special = RegExp(r"""[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\\/;\'`~]""");
      if (!special.hasMatch(trimmed)) return missingSpecialMessage;
    }
    return null;
  }
}
