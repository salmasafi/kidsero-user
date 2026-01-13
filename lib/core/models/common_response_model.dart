class CommonResponseModel {
  final bool success;
  final String? message;

  CommonResponseModel({
    required this.success,
    this.message,
  });

  factory CommonResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return CommonResponseModel(
      success: json['success'] ?? false,
      message: data != null ? data['message'] : null,
    );
  }
}
