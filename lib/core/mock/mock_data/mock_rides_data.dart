import 'mock_children_data.dart';

/// Mock rides data for testing
class MockRidesData {
  static String _generateId(String prefix, int index) =>
      'mock-${prefix}-${index.toString().padLeft(3, '0')}';

  static final _today = DateTime.now();
  static final _todayStr =
      '${_today.year}-${_today.month.toString().padLeft(2, '0')}-${_today.day.toString().padLeft(2, '0')}';

  /// Mock today rides for a child
  static Map<String, dynamic> getChildTodayRides(String childId) {
    final child = MockChildrenData.children.firstWhere(
      (c) => c.id == childId,
      orElse: () => MockChildrenData.children.first,
    );

    final org = child.organization!;

    return {
      'success': true,
      'data': {
        'child': {
          'id': child.id,
          'name': child.name,
          'avatar': child.photoUrl,
          'grade': child.grade ?? '',
          'classroom': child.classroom ?? '',
          'organization': {
            'id': org.id,
            'name': org.name,
            'logo': org.logo,
          },
        },
        'type': 'today',
        'date': _todayStr,
        'morning': [
          {
            'occurrenceId': _generateId('occ', 1),
            'date': _todayStr,
            'status': 'completed',
            'startedAt': '${_todayStr}T07:15:00Z',
            'completedAt': '${_todayStr}T07:45:00Z',
            'busLocation': null,
            'ride': {
              'id': _generateId('ride', 1),
              'name': 'Morning Pickup',
              'type': 'pickup',
            },
            'studentStatus': {
              'id': _generateId('ss', 1),
              'status': 'picked_up',
              'pickedUpAt': '${_todayStr}T07:30:00Z',
              'droppedOffAt': null,
              'pickupTime': '07:30 AM',
              'excuseReason': null,
            },
            'bus': {
              'id': _generateId('bus', 1),
              'busNumber': 'BUS-101',
              'plateNumber': 'ABC-1234',
            },
            'driver': {
              'id': _generateId('driver', 1),
              'name': 'Karim Abdullah',
              'phone': '+201234567891',
              'avatar': null,
            },
            'pickupPoint': {
              'id': _generateId('pickup', 1),
              'name': 'Home - Main Gate',
              'address': '123 Street Name, District, Cairo',
              'lat': '30.0444',
              'lng': '31.2357',
            },
          },
        ],
        'afternoon': [
          {
            'occurrenceId': _generateId('occ', 2),
            'date': _todayStr,
            'status': 'scheduled',
            'startedAt': null,
            'completedAt': null,
            'busLocation': null,
            'ride': {
              'id': _generateId('ride', 2),
              'name': 'Afternoon Return',
              'type': 'dropoff',
            },
            'studentStatus': {
              'id': _generateId('ss', 2),
              'status': 'pending',
              'pickedUpAt': null,
              'droppedOffAt': null,
              'pickupTime': '03:00 PM',
              'excuseReason': null,
            },
            'bus': {
              'id': _generateId('bus', 1),
              'busNumber': 'BUS-101',
              'plateNumber': 'ABC-1234',
            },
            'driver': {
              'id': _generateId('driver', 1),
              'name': 'Karim Abdullah',
              'phone': '+201234567891',
              'avatar': null,
            },
            'pickupPoint': {
              'id': _generateId('pickup', 2),
              'name': 'School Main Gate',
              'address': 'School Street, District, Cairo',
              'lat': '30.0450',
              'lng': '31.2360',
            },
          },
        ],
        'total': 2,
      },
    };
  }

  /// Mock history rides for a child
  static Map<String, dynamic> getChildHistoryRides(String childId) {
    final child = MockChildrenData.children.firstWhere(
      (c) => c.id == childId,
      orElse: () => MockChildrenData.children.first,
    );

    final org = child.organization!;
    final yesterday = _today.subtract(const Duration(days: 1));
    final yesterdayStr =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    return {
      'success': true,
      'data': {
        'child': {
          'id': child.id,
          'name': child.name,
          'avatar': child.photoUrl,
          'grade': child.grade ?? '',
          'classroom': child.classroom ?? '',
          'organization': {
            'id': org.id,
            'name': org.name,
            'logo': org.logo,
          },
        },
        'type': 'history',
        'date': yesterdayStr,
        'rides': [
          {
            'occurrenceId': _generateId('occ', 3),
            'date': yesterdayStr,
            'status': 'completed',
            'startedAt': '${yesterdayStr}T07:15:00Z',
            'completedAt': '${yesterdayStr}T07:45:00Z',
            'busLocation': null,
            'ride': {
              'id': _generateId('ride', 1),
              'name': 'Morning Pickup',
              'type': 'pickup',
            },
            'studentStatus': {
              'id': _generateId('ss', 3),
              'status': 'picked_up',
              'pickedUpAt': '${yesterdayStr}T07:30:00Z',
              'droppedOffAt': null,
              'pickupTime': '07:30 AM',
              'excuseReason': null,
            },
            'bus': {
              'id': _generateId('bus', 1),
              'busNumber': 'BUS-101',
              'plateNumber': 'ABC-1234',
            },
            'driver': {
              'id': _generateId('driver', 1),
              'name': 'Karim Abdullah',
              'phone': '+201234567891',
              'avatar': null,
            },
            'pickupPoint': {
              'id': _generateId('pickup', 1),
              'name': 'Home - Main Gate',
              'address': '123 Street Name, District, Cairo',
              'lat': '30.0444',
              'lng': '31.2357',
            },
          },
          {
            'occurrenceId': _generateId('occ', 4),
            'date': yesterdayStr,
            'status': 'completed',
            'startedAt': '${yesterdayStr}T14:45:00Z',
            'completedAt': '${yesterdayStr}T15:15:00Z',
            'busLocation': null,
            'ride': {
              'id': _generateId('ride', 2),
              'name': 'Afternoon Return',
              'type': 'dropoff',
            },
            'studentStatus': {
              'id': _generateId('ss', 4),
              'status': 'dropped_off',
              'pickedUpAt': '${yesterdayStr}T15:00:00Z',
              'droppedOffAt': '${yesterdayStr}T15:15:00Z',
              'pickupTime': '03:00 PM',
              'excuseReason': null,
            },
            'bus': {
              'id': _generateId('bus', 1),
              'busNumber': 'BUS-101',
              'plateNumber': 'ABC-1234',
            },
            'driver': {
              'id': _generateId('driver', 1),
              'name': 'Karim Abdullah',
              'phone': '+201234567891',
              'avatar': null,
            },
            'pickupPoint': {
              'id': _generateId('pickup', 2),
              'name': 'School Main Gate',
              'address': 'School Street, District, Cairo',
              'lat': '30.0450',
              'lng': '31.2360',
            },
          },
        ],
        'pagination': {
          'current': 1,
          'total': 5,
          'hasMore': true,
        },
      },
    };
  }

  /// Mock active rides (in-progress)
  static Map<String, dynamic> get activeRides => {
        'success': true,
        'data': {
          'activeRides': [
            {
              'occurrenceId': _generateId('occ', 5),
              'childId': MockChildrenData.children[0].id,
              'childName': MockChildrenData.children[0].name,
              'rideName': 'Afternoon Return',
              'status': 'in_progress',
              'startedAt': '${_todayStr}T14:30:00Z',
              'busLocation': {
                'lat': '30.0450',
                'lng': '31.2360',
                'updatedAt': '${_todayStr}T14:35:00Z',
              },
              'driver': {
                'id': _generateId('driver', 1),
                'name': 'Karim Abdullah',
                'phone': '+201234567891',
              },
              'estimatedArrival': '15:00',
            },
          ],
          'count': 1,
        },
      };

  /// Mock upcoming rides
  static Map<String, dynamic> get upcomingRides {
    final tomorrow = _today.add(const Duration(days: 1));
    final tomorrowStr =
        '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
    final dayAfter = _today.add(const Duration(days: 2));
    final dayAfterStr =
        '${dayAfter.year}-${dayAfter.month.toString().padLeft(2, '0')}-${dayAfter.day.toString().padLeft(2, '0')}';

    return {
      'success': true,
      'data': {
        'upcomingRides': [
          {
            'date': tomorrowStr,
            'dayName': 'Tomorrow',
            'rides': [
              {
                'occurrenceId': _generateId('occ', 6),
                'ride': {
                  'id': _generateId('ride', 1),
                  'name': 'Morning Pickup',
                  'type': 'pickup',
                },
                'child': {
                  'id': MockChildrenData.children[0].id,
                  'name': MockChildrenData.children[0].name,
                  'avatar': MockChildrenData.children[0].photoUrl,
                  'grade': MockChildrenData.children[0].grade ?? '',
                  'classroom': MockChildrenData.children[0].classroom ?? '',
                  'organization': {
                    'id': MockChildrenData.children[0].organization!.id,
                    'name': MockChildrenData.children[0].organization!.name,
                    'logo': MockChildrenData.children[0].organization!.logo,
                  },
                },
                'pickupTime': '07:30 AM',
                'pickupPointName': 'Home - Main Gate',
              },
              {
                'occurrenceId': _generateId('occ', 7),
                'ride': {
                  'id': _generateId('ride', 2),
                  'name': 'Afternoon Return',
                  'type': 'dropoff',
                },
                'child': {
                  'id': MockChildrenData.children[0].id,
                  'name': MockChildrenData.children[0].name,
                  'avatar': MockChildrenData.children[0].photoUrl,
                  'grade': MockChildrenData.children[0].grade ?? '',
                  'classroom': MockChildrenData.children[0].classroom ?? '',
                  'organization': {
                    'id': MockChildrenData.children[0].organization!.id,
                    'name': MockChildrenData.children[0].organization!.name,
                    'logo': MockChildrenData.children[0].organization!.logo,
                  },
                },
                'pickupTime': '03:00 PM',
                'pickupPointName': 'School Main Gate',
              },
            ],
          },
          {
            'date': dayAfterStr,
            'dayName': 'Day After',
            'rides': [
              {
                'occurrenceId': _generateId('occ', 8),
                'ride': {
                  'id': _generateId('ride', 1),
                  'name': 'Morning Pickup',
                  'type': 'pickup',
                },
                'child': {
                  'id': MockChildrenData.children[1].id,
                  'name': MockChildrenData.children[1].name,
                  'avatar': MockChildrenData.children[1].photoUrl,
                  'grade': MockChildrenData.children[1].grade ?? '',
                  'classroom': MockChildrenData.children[1].classroom ?? '',
                  'organization': {
                    'id': MockChildrenData.children[1].organization!.id,
                    'name': MockChildrenData.children[1].organization!.name,
                    'logo': MockChildrenData.children[1].organization!.logo,
                  },
                },
                'pickupTime': '07:45 AM',
                'pickupPointName': 'Home - Main Gate',
              },
            ],
          },
        ],
        'totalDays': 2,
        'totalRides': 3,
      },
    };
  }

  /// Mock ride summary for a child
  static Map<String, dynamic> getChildRideSummary(String childId) {
    final child = MockChildrenData.children.firstWhere(
      (c) => c.id == childId,
      orElse: () => MockChildrenData.children.first,
    );

    return {
      'success': true,
      'data': {
        'child': {
          'id': child.id,
          'name': child.name,
          'avatar': child.photoUrl,
          'organization': child.organization!.name,
        },
        'period': {
          'month': _today.month,
          'year': _today.year,
          'monthName': _getMonthName(_today.month),
        },
        'summary': {
          'total': 42,
          'morning': 21,
          'afternoon': 21,
          'byStatus': {
            'completed': 38,
            'absent': 2,
            'excused': 1,
            'pending': 1,
          },
          'attendanceRate': 90,
        },
      },
    };
  }

  /// Mock ride tracking data
  static Map<String, dynamic> getRideTracking(String occurrenceId) {
    return {
      'success': true,
      'error': null,
      'data': {
        'occurrence': {
          'id': occurrenceId,
          'date': _todayStr,
          'status': 'in_progress',
          'startedAt': '${_todayStr}T14:30:00Z',
          'completedAt': null,
        },
        'ride': {
          'id': _generateId('ride', 2),
          'name': 'Afternoon Return',
          'type': 'dropoff',
        },
        'bus': {
          'id': _generateId('bus', 1),
          'busNumber': 'BUS-101',
          'plateNumber': 'ABC-1234',
          'currentLocation': {
            'lat': '30.0450',
            'lng': '31.2360',
            'updatedAt': '${_todayStr}T14:35:00Z',
          },
        },
        'driver': {
          'id': _generateId('driver', 1),
          'name': 'Karim Abdullah',
          'phone': '+201234567891',
          'avatar': null,
        },
        'route': {
          'id': _generateId('route', 1),
          'name': 'Main Route - District 1',
          'stops': [
            {
              'id': _generateId('stop', 1),
              'name': 'School',
              'address': 'School Street, District',
              'lat': '30.0460',
              'lng': '31.2370',
              'stopOrder': 1,
            },
            {
              'id': _generateId('stop', 2),
              'name': 'Stop 1 - Street Corner',
              'address': 'Corner Street, District',
              'lat': '30.0455',
              'lng': '31.2365',
              'stopOrder': 2,
            },
            {
              'id': _generateId('stop', 3),
              'name': 'Home - Main Gate',
              'address': '123 Street Name, District',
              'lat': '30.0444',
              'lng': '31.2357',
              'stopOrder': 3,
            },
          ],
        },
        'children': [
          {
            'id': _generateId('tc', 1),
            'status': 'pending',
            'pickedUpAt': null,
            'droppedOffAt': null,
            'pickupTime': '03:00 PM',
            'excuseReason': null,
            'child': {
              'id': MockChildrenData.children[0].id,
              'name': MockChildrenData.children[0].name,
              'avatar': MockChildrenData.children[0].photoUrl,
              'grade': MockChildrenData.children[0].grade ?? '',
              'classroom': MockChildrenData.children[0].classroom ?? '',
              'organization': {
                'id': MockChildrenData.children[0].organization!.id,
                'name': MockChildrenData.children[0].organization!.name,
                'logo': MockChildrenData.children[0].organization!.logo,
              },
            },
            'pickupPoint': {
              'id': _generateId('pickup', 1),
              'name': 'Home - Main Gate',
              'address': '123 Street Name, District, Cairo',
              'lat': '30.0444',
              'lng': '31.2357',
            },
          },
        ],
      },
    };
  }

  /// Mock report absence response
  static Map<String, dynamic> reportAbsence(String occurrenceId, String reason) => {
        'success': true,
        'message': 'Absence reported successfully',
        'data': {
          'occurrenceId': occurrenceId,
          'reason': reason,
          'reportedAt': DateTime.now().toIso8601String(),
        },
      };

  static String _getMonthName(int month) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
