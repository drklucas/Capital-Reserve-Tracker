import '../constants/app_constants.dart';

/// Input validation utilities
class Validators {
  // Prevent instantiation
  Validators._();

  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final trimmed = value.trim();

    if (trimmed.length > AppConstants.maxEmailLength) {
      return 'Email is too long';
    }

    if (!AppConstants.emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password is too long';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Optional: Check for special characters
    // if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
    //   return 'Password must contain at least one special character';
    // }

    return null;
  }

  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < AppConstants.minNameLength) {
      return 'Name must be at least ${AppConstants.minNameLength} characters';
    }

    if (trimmed.length > AppConstants.maxNameLength) {
      return 'Name is too long';
    }

    if (!AppConstants.nameRegex.hasMatch(trimmed)) {
      return 'Please enter a valid name';
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }

    final trimmed = value.trim();

    if (trimmed.length < 10) {
      return 'Phone number is too short';
    }

    if (trimmed.length > 15) {
      return 'Phone number is too long';
    }

    if (!AppConstants.phoneRegex.hasMatch(trimmed)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate amount
  static String? validateAmount(String? value, {
    double? min,
    double? max,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'Amount is required' : null;
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount < 0) {
      return 'Amount cannot be negative';
    }

    if (min != null && amount < min) {
      return 'Amount must be at least ${AppConstants.currencySymbol}$min';
    }

    if (max != null && amount > max) {
      return 'Amount cannot exceed ${AppConstants.currencySymbol}$max';
    }

    return null;
  }

  /// Validate goal amount
  static String? validateGoalAmount(String? value) {
    return validateAmount(
      value,
      min: AppConstants.minGoalAmount,
      max: AppConstants.maxGoalAmount,
    );
  }

  /// Validate transaction amount
  static String? validateTransactionAmount(String? value) {
    return validateAmount(
      value,
      min: AppConstants.minTransactionAmount,
      max: AppConstants.maxTransactionAmount,
    );
  }

  /// Validate date
  static String? validateDate(DateTime? date, {
    DateTime? minDate,
    DateTime? maxDate,
    bool isFutureAllowed = true,
    bool isPastAllowed = true,
  }) {
    if (date == null) {
      return 'Date is required';
    }

    final now = DateTime.now();

    if (!isFutureAllowed && date.isAfter(now)) {
      return 'Date cannot be in the future';
    }

    if (!isPastAllowed && date.isBefore(now)) {
      return 'Date cannot be in the past';
    }

    if (minDate != null && date.isBefore(minDate)) {
      return 'Date is too early';
    }

    if (maxDate != null && date.isAfter(maxDate)) {
      return 'Date is too late';
    }

    return null;
  }

  /// Validate goal target date
  static String? validateGoalTargetDate(DateTime? date) {
    if (date == null) {
      return 'Target date is required';
    }

    final now = DateTime.now();
    final minDate = now.add(const Duration(days: AppConstants.minGoalDurationDays));
    final maxDate = now.add(const Duration(days: AppConstants.maxGoalDurationYears * 365));

    if (date.isBefore(minDate)) {
      return 'Target date must be at least ${AppConstants.minGoalDurationDays} days from now';
    }

    if (date.isAfter(maxDate)) {
      return 'Target date cannot be more than ${AppConstants.maxGoalDurationYears} years from now';
    }

    return null;
  }

  /// Validate text length
  static String? validateTextLength(
    String? value, {
    int? minLength,
    int? maxLength,
    String fieldName = 'Field',
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required ? '$fieldName is required' : null;
    }

    final trimmed = value.trim();

    if (minLength != null && trimmed.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (maxLength != null && trimmed.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }

    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlPattern = RegExp(
      r'^(https?|ftp):\/\/([\w-]+\.)+[\w-]+(\/[\w- .\/?%&=]*)?$',
      caseSensitive: false,
    );

    if (!urlPattern.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validate percentage
  static String? validatePercentage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Percentage is required';
    }

    final percentage = double.tryParse(value);
    if (percentage == null) {
      return 'Please enter a valid percentage';
    }

    if (percentage < 0 || percentage > 100) {
      return 'Percentage must be between 0 and 100';
    }

    return null;
  }

  /// Check if email is valid
  static bool isValidEmail(String email) {
    return AppConstants.emailRegex.hasMatch(email);
  }

  /// Check if password is strong
  static bool isStrongPassword(String password) {
    return password.length >= AppConstants.minPasswordLength &&
           password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[a-z]')) &&
           password.contains(RegExp(r'[0-9]'));
  }

  /// Sanitize input by removing potentially harmful characters
  static String sanitizeInput(String input) {
    // Remove HTML tags
    final withoutHtml = input.replaceAll(RegExp(r'<[^>]*>'), '');

    // Remove script tags specifically (extra safety)
    final withoutScript = withoutHtml.replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '');

    // Trim whitespace
    return withoutScript.trim();
  }

  /// Validate credit card number (basic Luhn algorithm)
  static bool isValidCreditCard(String cardNumber) {
    // Remove spaces and dashes
    final cleaned = cardNumber.replaceAll(RegExp(r'[\s-]'), '');

    // Check if it's all digits
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return false;
    }

    // Check length (most cards are 13-19 digits)
    if (cleaned.length < 13 || cleaned.length > 19) {
      return false;
    }

    // Luhn algorithm
    int sum = 0;
    bool alternate = false;

    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// Mask sensitive data
  static String maskEmail(String email) {
    if (!isValidEmail(email)) return email;

    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 3) {
      return '***@$domain';
    }

    final visibleChars = username.substring(0, 3);
    final maskedChars = '*' * (username.length - 3);

    return '$visibleChars$maskedChars@$domain';
  }

  /// Mask phone number
  static String maskPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.length < 10) return phone;

    final lastFour = cleaned.substring(cleaned.length - 4);
    final masked = '*' * (cleaned.length - 4);

    return '$masked$lastFour';
  }
}