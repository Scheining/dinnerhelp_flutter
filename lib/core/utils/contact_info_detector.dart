class ContactInfoDetector {
  static final RegExp _emailPattern = RegExp(
    r'\b[A-Za-z0-9._%+-]+[@＠][A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
    caseSensitive: false,
  );

  static final RegExp _phonePattern = RegExp(
    r'(?:'
    r'(?:\+?45)?[\s.-]?[0-9]{2}[\s.-]?[0-9]{2}[\s.-]?[0-9]{2}[\s.-]?[0-9]{2}|' // Danish phone
    r'(?:\+?1)?[\s.-]?\(?[0-9]{3}\)?[\s.-]?[0-9]{3}[\s.-]?[0-9]{4}|' // US phone
    r'(?:\+?[0-9]{1,3})?[\s.-]?[0-9]{6,14}' // International
    r')',
  );

  static final RegExp _socialMediaPattern = RegExp(
    r'(?:'
    r'(?:@|(?:instagram|insta|ig|facebook|fb|twitter|snap|snapchat|tiktok|linkedin|whatsapp)(?:\.com)?/?:?\s*/?@?)[a-zA-Z0-9._-]+|'
    r'(?:instagram|insta|ig|facebook|fb|twitter|snap|snapchat|tiktok|linkedin)\.com/[a-zA-Z0-9._-]+'
    r')',
    caseSensitive: false,
  );

  static final List<String> _suspiciousKeywords = [
    'email', 'e-mail', 'mail', 'gmail', 'hotmail', 'outlook',
    'telefon', 'phone', 'nummer', 'number', 'mobil', 'mobile',
    'whatsapp', 'messenger', 'telegram', 'signal',
    'kontakt', 'contact', 'ring', 'call', 'skriv til', 'write to',
    'find mig', 'find me', 'følg mig', 'follow me',
  ];

  static ContactInfoValidation validate(String text) {
    final lowerText = text.toLowerCase();
    final issues = <String>[];
    
    // Check for email addresses
    if (_emailPattern.hasMatch(text)) {
      issues.add('Email adresser er ikke tilladt');
    }
    
    // Check for phone numbers
    if (_phonePattern.hasMatch(text)) {
      issues.add('Telefonnumre er ikke tilladt');
    }
    
    // Check for social media handles
    if (_socialMediaPattern.hasMatch(text)) {
      issues.add('Social media profiler er ikke tilladt');
    }
    
    // Check for suspicious keywords that might indicate sharing contact info
    bool hasSuspiciousContent = false;
    for (final keyword in _suspiciousKeywords) {
      if (lowerText.contains(keyword)) {
        hasSuspiciousContent = true;
        break;
      }
    }
    
    if (hasSuspiciousContent && issues.isEmpty) {
      // Only flag as warning if no direct contact info was found
      return ContactInfoValidation(
        isValid: true,
        hasWarning: true,
        issues: ['Din besked ser ud til at indeholde kontaktoplysninger'],
      );
    }
    
    return ContactInfoValidation(
      isValid: issues.isEmpty,
      hasWarning: false,
      issues: issues,
    );
  }

  static String sanitizeMessage(String text) {
    // Remove emails
    String sanitized = text.replaceAll(_emailPattern, '[email fjernet]');
    
    // Remove phone numbers
    sanitized = sanitized.replaceAll(_phonePattern, '[telefonnummer fjernet]');
    
    // Remove social media handles
    sanitized = sanitized.replaceAll(_socialMediaPattern, '[social media fjernet]');
    
    return sanitized;
  }
}

class ContactInfoValidation {
  final bool isValid;
  final bool hasWarning;
  final List<String> issues;

  ContactInfoValidation({
    required this.isValid,
    required this.hasWarning,
    required this.issues,
  });
}