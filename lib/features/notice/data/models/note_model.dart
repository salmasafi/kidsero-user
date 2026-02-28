import 'package:equatable/equatable.dart';

class NoteOrganization extends Equatable {
  final String? name;
  final String? logo;

  const NoteOrganization({this.name, this.logo});

  factory NoteOrganization.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NoteOrganization();
    return NoteOrganization(
      name: json['name'] as String?,
      logo: json['logo'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'logo': logo,
      };

  @override
  List<Object?> get props => [name, logo];
}

class NoteModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime? date;
  final String type;
  final bool cancelRides;
  final String? status;
  final String? organizationId;
  final NoteOrganization organization;
  final String? dayName;
  final DateTime? createdAt;
  final int? daysUntil;

  const NoteModel({
    required this.id,
    required this.title,
    this.description,
    this.date,
    required this.type,
    required this.cancelRides,
    this.status,
    this.organizationId,
    this.organization = const NoteOrganization(),
    this.dayName,
    this.createdAt,
    this.daysUntil,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description'] as String?,
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      type: json['type']?.toString() ?? 'other',
      cancelRides: json['cancelRides'] == true,
      status: json['status'] as String?,
      organizationId: json['organizationId']?.toString(),
      organization: NoteOrganization.fromJson(
        json['organization'] as Map<String, dynamic>?,
      ),
      dayName: json['dayName'] as String?,
      createdAt:
          json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      daysUntil: json['daysUntil'] is int
          ? json['daysUntil'] as int
          : int.tryParse(json['daysUntil']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date?.toIso8601String(),
        'type': type,
        'cancelRides': cancelRides,
        'status': status,
        'organizationId': organizationId,
        'organization': organization.toJson(),
        'dayName': dayName,
        'createdAt': createdAt?.toIso8601String(),
        'daysUntil': daysUntil,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        date,
        type,
        cancelRides,
        status,
        organizationId,
        organization,
        dayName,
        createdAt,
        daysUntil,
      ];
}

class UpcomingNotesResponse {
  final List<NoteModel> notes;
  final int total;

  const UpcomingNotesResponse({required this.notes, required this.total});

  factory UpcomingNotesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final notesList = data?['notes'] as List<dynamic>?;
    return UpcomingNotesResponse(
      notes: notesList != null
          ? notesList.map((e) => NoteModel.fromJson(e)).toList()
          : const [],
      total: data?['total'] is int
          ? data!['total'] as int
          : int.tryParse(data?['total']?.toString() ?? '') ?? 0,
    );
  }
}
