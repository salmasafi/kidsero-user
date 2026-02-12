/// Enum representing the type of payment (one-time or installment)
enum PaymentType {
  onetime,
  installment;

  /// Create PaymentType from string value
  factory PaymentType.fromString(String? value) {
    if (value == null || value.isEmpty) {
      return PaymentType.onetime; // Default to onetime if null or empty
    }
    
    switch (value.toLowerCase()) {
      case 'onetime':
        return PaymentType.onetime;
      case 'installment':
        return PaymentType.installment;
      default:
        return PaymentType.onetime; // Default to onetime for invalid values
    }
  }

  /// Convert PaymentType to JSON string
  String toJson() {
    return name;
  }
}
