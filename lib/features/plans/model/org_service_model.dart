class OrgService {
  final String id;
  final String serviceName;
  final String serviceDescription;
  final num baseServicePrice;
  final bool useZonePricing;
  final num studentZoneCost;
  final num finalPrice;

  OrgService({
    required this.id,
    required this.serviceName,
    required this.serviceDescription,
    required this.baseServicePrice,
    required this.useZonePricing,
    required this.studentZoneCost,
    required this.finalPrice,
  });

  factory OrgService.fromJson(Map<String, dynamic> json) {
    return OrgService(
      id: json['id'] ?? '',
      serviceName: json['serviceName'] ?? '',
      serviceDescription: json['serviceDescription'] ?? '',
      baseServicePrice: json['baseServicePrice'] ?? 0,
      useZonePricing: json['useZonePricing'] ?? false,
      studentZoneCost: json['studentZoneCost'] ?? 0,
      finalPrice: json['finalPrice'] ?? 0,
    );
  }
}

class OrgServiceResponse {
  final bool success;
  final String message;
  final List<OrgService> services;

  OrgServiceResponse({
    required this.success,
    required this.message,
    required this.services,
  });

  factory OrgServiceResponse.fromJson(Map<String, dynamic> json) {
    return OrgServiceResponse(
      success: json['success'] ?? false,
      message: json['data']['message'] ?? '',
      services:
          (json['data']['orgServices'] as List<dynamic>?)
              ?.map((e) => OrgService.fromJson(e))
              .toList() ??
          [],
    );
  }
}
