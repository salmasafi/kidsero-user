class PlanModel {
  final String id;
  final String name;
  final num price;
  final num minSubscriptionFeesPay;
  final num subscriptionFees;

  PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.minSubscriptionFeesPay,
    required this.subscriptionFees,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      minSubscriptionFeesPay: json['minSubscriptionFeesPay'] ?? 0,
      subscriptionFees: json['subscriptionFees'] ?? 0,
    );
  }
}
