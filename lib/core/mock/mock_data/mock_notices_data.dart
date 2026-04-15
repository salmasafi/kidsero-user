import 'package:kidsero_parent/features/notice/data/models/note_model.dart';

import 'mock_children_data.dart';

/// Mock notices/notes data for testing
class MockNoticesData {
  static String _generateId(String prefix, int index) =>
      'mock-${prefix}-${index.toString().padLeft(3, '0')}';

  static final _now = DateTime.now();

  /// Mock organizations for notes
  static List<NoteOrganization> get noteOrganizations => [
        NoteOrganization(
          name: 'Sunshine International School',
          logo: '/images/schools/sunshine.png',
        ),
        NoteOrganization(
          name: 'Al-Manahij Modern School',
          logo: '/images/schools/manahij.png',
        ),
        NoteOrganization(
          name: 'Al-Ittihad National School',
          logo: '/images/schools/ittihad.png',
        ),
      ];

  /// Mock notes list
  static List<NoteModel> get notes => [
        NoteModel(
          id: _generateId('note', 1),
          title: 'School Closed - National Holiday',
          description: 'The school will be closed tomorrow due to the national holiday. All transportation services are suspended. Have a wonderful celebration!',
          date: _now.add(const Duration(days: 1)),
          type: 'holiday',
          cancelRides: true,
          status: 'active',
          organizationId: MockChildrenData.organizations[0].id,
          organization: noteOrganizations[0],
          dayName: 'Tomorrow',
          createdAt: _now.subtract(const Duration(days: 2)),
          daysUntil: 1,
        ),
        NoteModel(
          id: _generateId('note', 2),
          title: 'Parent-Teacher Meeting Schedule',
          description: 'Parent-teacher meetings will be held next week. Please check your email for your scheduled time slot. Transportation will run on normal schedule.',
          date: _now.add(const Duration(days: 7)),
          type: 'meeting',
          cancelRides: false,
          status: 'active',
          organizationId: MockChildrenData.organizations[0].id,
          organization: noteOrganizations[0],
          dayName: 'Next Week',
          createdAt: _now.subtract(const Duration(days: 3)),
          daysUntil: 7,
        ),
        NoteModel(
          id: _generateId('note', 3),
          title: 'Sports Day Event',
          description: 'Annual Sports Day is coming up! Students should wear their sports uniforms. Parents are welcome to attend. Buses will depart 1 hour later than usual.',
          date: _now.add(const Duration(days: 5)),
          type: 'event',
          cancelRides: false,
          status: 'active',
          organizationId: MockChildrenData.organizations[1].id,
          organization: noteOrganizations[1],
          dayName: 'In 5 Days',
          createdAt: _now.subtract(const Duration(days: 5)),
          daysUntil: 5,
        ),
        NoteModel(
          id: _generateId('note', 4),
          title: 'Early Dismissal - Staff Training',
          description: 'School will dismiss at 12:00 PM this Wednesday for staff training. Morning pickup runs normally, afternoon pickup moved to 12:15 PM.',
          date: _now.add(const Duration(days: 2)),
          type: 'schedule_change',
          cancelRides: false,
          status: 'active',
          organizationId: MockChildrenData.organizations[0].id,
          organization: noteOrganizations[0],
          dayName: 'Wednesday',
          createdAt: _now.subtract(const Duration(days: 1)),
          daysUntil: 2,
        ),
        NoteModel(
          id: _generateId('note', 5),
          title: 'Winter Break Announcement',
          description: 'Winter break starts December 20th. School resumes January 5th. No transportation services during the break period.',
          date: DateTime(_now.year, 12, 20),
          type: 'holiday',
          cancelRides: true,
          status: 'active',
          organizationId: MockChildrenData.organizations[2].id,
          organization: noteOrganizations[2],
          dayName: 'December 20',
          createdAt: _now.subtract(const Duration(days: 10)),
          daysUntil: DateTime(_now.year, 12, 20).difference(_now).inDays,
        ),
        NoteModel(
          id: _generateId('note', 6),
          title: 'New Safety Protocol',
          description: 'Updated safety protocols are now in effect. Please ensure your child has their ID card visible when boarding the bus. Thank you for your cooperation.',
          date: null,
          type: 'announcement',
          cancelRides: false,
          status: 'active',
          organizationId: MockChildrenData.organizations[0].id,
          organization: noteOrganizations[0],
          dayName: null,
          createdAt: _now.subtract(const Duration(days: 1)),
          daysUntil: null,
        ),
        NoteModel(
          id: _generateId('note', 7),
          title: 'Field Trip - Zoo Visit',
          description: 'Grade 3 students will visit the zoo next Thursday. Permission slips must be signed by Monday. Special transportation arrangements will be communicated separately.',
          date: _now.add(const Duration(days: 8)),
          type: 'event',
          cancelRides: false,
          status: 'active',
          organizationId: MockChildrenData.organizations[1].id,
          organization: noteOrganizations[1],
          dayName: 'Next Thursday',
          createdAt: _now.subtract(const Duration(days: 4)),
          daysUntil: 8,
        ),
        NoteModel(
          id: _generateId('note', 8),
          title: 'Payment Reminder',
          description: 'Monthly transportation fees are due by the 5th of next month. Please ensure timely payment to avoid service interruption.',
          date: _now.add(const Duration(days: 10)),
          type: 'reminder',
          cancelRides: false,
          status: 'active',
          organizationId: MockChildrenData.organizations[0].id,
          organization: noteOrganizations[0],
          dayName: 'Due Soon',
          createdAt: _now.subtract(const Duration(days: 1)),
          daysUntil: 10,
        ),
      ];

  /// Mock all notes response
  static Map<String, dynamic> get allNotesResponse => {
        'success': true,
        'data': {
          'notes': notes.map((n) => n.toJson()).toList(),
          'total': notes.length,
        },
      };

  /// Mock upcoming notes response
  static Map<String, dynamic> get upcomingNotesResponse => {
        'success': true,
        'data': {
          'notes': notes
              .where((n) => n.date != null && n.date!.isAfter(_now))
              .take(5)
              .map((n) => n.toJson())
              .toList(),
          'total': notes.where((n) => n.date != null && n.date!.isAfter(_now)).length,
        },
      };

  /// Mock note by ID response
  static Map<String, dynamic> getNoteById(String id) {
    final note = notes.firstWhere(
      (n) => n.id == id,
      orElse: () => notes.first,
    );

    return {
      'success': true,
      'data': {
        'note': note.toJson(),
      },
    };
  }
}
