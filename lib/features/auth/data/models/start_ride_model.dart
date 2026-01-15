import 'package:equatable/equatable.dart';

class StartRideResponse extends Equatable {
  final bool success;
  final StartRideData data;

  const StartRideResponse({
    required this.success,
    required this.data,
  });

  factory StartRideResponse.fromJson(Map<String, dynamic> json) {
    return StartRideResponse(
      success: json['success'] ?? false,
      data: StartRideData.fromJson(json['data'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [success, data];
}

class StartRideData extends Equatable {
  final String message;
  final String occurrenceId;
  final String startedAt;

  const StartRideData({
    required this.message,
    required this.occurrenceId,
    required this.startedAt,
  });

  factory StartRideData.fromJson(Map<String, dynamic> json) {
    return StartRideData(
      message: json['message'] ?? '',
      occurrenceId: json['occurrenceId'] ?? '',
      startedAt: json['startedAt'] ?? '',
    );
  }

  @override
  List<Object?> get props => [message, occurrenceId, startedAt];
}

class StartRideRequest extends Equatable {
  final String lat;
  final String lng;

  const StartRideRequest({
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  @override
  List<Object?> get props => [lat, lng];
}
