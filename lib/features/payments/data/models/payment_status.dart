/// Enum representing the status of a payment
enum PaymentStatus {
  pending,
  completed,
  rejected;

  /// Create PaymentStatus from string value
  factory PaymentStatus.fromString(String? value) {
    if (value == null || value.isEmpty) {
      return PaymentStatus.pending; // Default to pending if null or empty
    }
    
    switch (value.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'completed':
        return PaymentStatus.completed;
      case 'rejected':
        return PaymentStatus.rejected;
      default:
        return PaymentStatus.pending; // Default to pending for invalid values
    }
  }

  /// Convert PaymentStatus to JSON string
  String toJson() {
    return name;
  }
}
