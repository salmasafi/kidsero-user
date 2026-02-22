
String formatPrice(num amount) {
  if (amount == amount.roundToDouble()) {
    return '${amount.toInt()} EGP';
  }
  return '${amount.toStringAsFixed(2)} EGP';
}