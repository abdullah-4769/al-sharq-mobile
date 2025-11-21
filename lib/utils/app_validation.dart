class AppValidators {
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }

    // Check minimum length
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }

    // Check maximum length
    if (value.trim().length > 50) {
      return 'Name cannot exceed 50 characters';
    }

    // Check if name contains only letters, spaces, hyphens, and apostrophes
    final nameRegex = RegExp(r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Name can only contain letters, spaces, hyphens (-), and apostrophes (\')';
    }

    // Check for consecutive special characters
    if (RegExp(r"[',. -]{2,}").hasMatch(value)) {
      return 'Name cannot contain consecutive special characters';
    }

    // Check if name starts with a letter
    if (!RegExp(r'^[a-zA-Z]').hasMatch(value.trim())) {
      return 'Name must start with a letter';
    }

    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    // Basic email format validation
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$'
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address (e.g., name@example.com)';
    }

    // Check for common email providers and valid domain structure
    final domainRegex = RegExp(
        r'@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$'
    );

    if (!domainRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email domain';
    }

    // Check for consecutive dots
    if (value.contains('..')) {
      return 'Email cannot contain consecutive dots';
    }

    // Check length
    if (value.length > 254) {
      return 'Email address is too long';
    }

    return null;
  }

  // Password validation with strength requirements
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    // Check minimum length
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check maximum length
    if (value.length > 128) {
      return 'Password cannot exceed 128 characters';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter (A-Z)';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter (a-z)';
    }

    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number (0-9)';
    }

    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character (!@#\$%^&* etc.)';
    }

    // Check for common weak patterns
    if (RegExp(r'(.)\1{2,}').hasMatch(value)) {
      return 'Password cannot contain 3 or more identical characters in a row';
    }

    // Check for sequential numbers
    if (RegExp(r'(012|123|234|345|456|567|678|789|890)').hasMatch(value)) {
      return 'Password cannot contain sequential numbers';
    }

    // Check for common passwords (basic check)
    final commonPasswords = [
      'password', '12345678', 'qwerty', 'admin', 'welcome'
    ];
    if (commonPasswords.contains(value.toLowerCase())) {
      return 'This password is too common. Please choose a stronger one';
    }

    return null;
  }

  // Simple password validation (for login or less strict scenarios)
  static String? validateSimplePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match. Please make sure both passwords are identical';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters except +
    final cleanedValue = value.replaceAll(RegExp(r'[^\d+]'), '');

    // Check for valid international phone number format
    final phoneRegex = RegExp(r'^(\+\d{1,3})?[\d\s\-\(\)]{8,15}$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number (e.g., +1234567890 or 1234567890)';
    }

    // Check minimum length (digits only)
    final digitsOnly = cleanedValue.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 8) {
      return 'Phone number is too short. Minimum 8 digits required';
    }

    if (digitsOnly.length > 15) {
      return 'Phone number is too long. Maximum 15 digits allowed';
    }

    // Check if it starts with a valid country code (if international format)
    if (value.startsWith('+')) {
      final countryCode = value.split('+')[1].split(RegExp(r'[\s\-\(\)]'))[0];
      if (countryCode.isEmpty || !RegExp(r'^\d{1,3}$').hasMatch(countryCode)) {
        return 'Please enter a valid country code';
      }
    }

    return null;
  }

  // Optional field validation
  static String? validateOptional(String? value, {int maxLength = 255}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional fields can be empty
    }

    if (value.length > maxLength) {
      return 'Text cannot exceed $maxLength characters';
    }

    return null;
  }


  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
        r'^(https?:\/\/)?' // http:// or https://
        r'((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|' // domain name
        r'((\d{1,3}\.){3}\d{1,3}))' // OR ip (v4) address
        r'(\:\d+)?(\/[-a-z\d%_.~+]*)*' // port and path
        r'(\?[;&a-z\d%_.~+=-]*)?' // query string
        r'(\#[-a-z\d_]*)?$', // fragment locator
        caseSensitive: false
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL (e.g., https://example.com)';
    }

    return null;
  }
}