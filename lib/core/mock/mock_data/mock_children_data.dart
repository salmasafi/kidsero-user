import 'package:kidsero_parent/features/children/model/child_model.dart';
import 'package:kidsero_parent/features/rides/models/api_models.dart';

/// Mock children data for testing
class MockChildrenData {
  /// Generate a unique ID
  static String _generateId(String prefix, int index) => 
      'mock-${prefix}-${index.toString().padLeft(3, '0')}';

  /// Mock organizations
  static List<Organization> get organizations => [
        Organization(
          id: _generateId('org', 1),
          name: 'Sunshine International School',
          logo: null,
        ),
        Organization(
          id: _generateId('org', 2),
          name: 'Al-Manahij Modern School',
          logo: null,
        ),
        Organization(
          id: _generateId('org', 3),
          name: 'Al-Ittihad National School',
          logo: null,
        ),
      ];

  /// Mock children list
  static List<Child> get children => [
        Child(
          id: _generateId('child', 1),
          name: 'Omar Ahmed',
          code: 'CHD-2024-001',
          grade: 'Grade 5',
          classroom: '5-A',
          schoolName: 'Sunshine International School',
          photoUrl: null,
          status: 'active',
          createdAt: '2024-01-15T10:30:00Z',
          updatedAt: '2024-03-20T14:22:00Z',
          organization: organizations[0],
        ),
        Child(
          id: _generateId('child', 2),
          name: 'Laila Ahmed',
          code: 'CHD-2024-002',
          grade: 'Grade 2',
          classroom: '2-B',
          schoolName: 'Sunshine International School',
          photoUrl: null,
          status: 'active',
          createdAt: '2024-01-15T10:35:00Z',
          updatedAt: '2024-03-20T14:25:00Z',
          organization: organizations[0],
        ),
        Child(
          id: _generateId('child', 3),
          name: 'Youssef Hassan',
          code: 'CHD-2024-003',
          grade: 'Grade 7',
          classroom: '7-C',
          schoolName: 'Al-Manahij Modern School',
          photoUrl: null,
          status: 'active',
          createdAt: '2024-02-01T09:00:00Z',
          updatedAt: '2024-03-18T11:30:00Z',
          organization: organizations[1],
        ),
        Child(
          id: _generateId('child', 4),
          name: 'Noor Hassan',
          code: 'CHD-2024-004',
          grade: 'Kindergarten',
          classroom: 'KG-1',
          schoolName: 'Al-Ittihad National School',
          photoUrl: null,
          status: 'active',
          createdAt: '2024-02-10T08:30:00Z',
          updatedAt: '2024-03-19T09:15:00Z',
          organization: organizations[2],
        ),
      ];

  /// Mock child response
  static Map<String, dynamic> get childResponse => {
        'success': true,
        'data': children.map((c) => {
          'id': c.id,
          'name': c.name,
          'code': c.code,
          'grade': c.grade,
          'classroom': c.classroom,
          'schoolName': c.schoolName,
          'avatar': c.photoUrl,
          'status': c.status,
          'createdAt': c.createdAt,
          'updatedAt': c.updatedAt,
          'organization': c.organization != null ? {
            'id': c.organization!.id,
            'name': c.organization!.name,
            'logo': c.organization!.logo,
          } : null,
        }).toList(),
      };

  /// Mock add child response
  static Map<String, dynamic> addChildResponse(String code) => {
        'success': true,
        'message': 'Child added successfully',
        'data': {
          'id': _generateId('child', 5),
          'name': 'New Student',
          'code': code,
          'grade': 'Grade 3',
          'classroom': '3-A',
          'schoolName': 'New School',
          'avatar': null,
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      };

  /// Mock children with rides (for rides feature)
  static List<ChildWithRides> get childrenWithRides {
    final orgs = organizations;
    final childs = children;
    
    return [
      ChildWithRides(
        id: childs[0].id,
        name: childs[0].name,
        avatar: childs[0].photoUrl,
        grade: childs[0].grade ?? '',
        classroom: childs[0].classroom ?? '',
        code: childs[0].code,
        organization: OrganizationInfo(
          id: orgs[0].id,
          name: orgs[0].name,
          logo: orgs[0].logo,
        ),
        rides: _generateMockRidesForChild(childs[0].id, 'Morning Pickup'),
      ),
      ChildWithRides(
        id: childs[1].id,
        name: childs[1].name,
        avatar: childs[1].photoUrl,
        grade: childs[1].grade ?? '',
        classroom: childs[1].classroom ?? '',
        code: childs[1].code,
        organization: OrganizationInfo(
          id: orgs[0].id,
          name: orgs[0].name,
          logo: orgs[0].logo,
        ),
        rides: _generateMockRidesForChild(childs[1].id, 'Afternoon Drop'),
      ),
      ChildWithRides(
        id: childs[2].id,
        name: childs[2].name,
        avatar: childs[2].photoUrl,
        grade: childs[2].grade ?? '',
        classroom: childs[2].classroom ?? '',
        code: childs[2].code,
        organization: OrganizationInfo(
          id: orgs[1].id,
          name: orgs[1].name,
          logo: orgs[1].logo,
        ),
        rides: _generateMockRidesForChild(childs[2].id, 'Full Day Service'),
      ),
      ChildWithRides(
        id: childs[3].id,
        name: childs[3].name,
        avatar: childs[3].photoUrl,
        grade: childs[3].grade ?? '',
        classroom: childs[3].classroom ?? '',
        code: childs[3].code,
        organization: OrganizationInfo(
          id: orgs[2].id,
          name: orgs[2].name,
          logo: orgs[2].logo,
        ),
        rides: _generateMockRidesForChild(childs[3].id, 'Morning Pickup'),
      ),
    ];
  }

  /// Generate mock rides for a child
  static List<ChildRide> _generateMockRidesForChild(String childId, String rideName) {
    return [
      ChildRide(
        id: _generateId('ride', 1),
        name: rideName,
        type: 'pickup',
        frequency: 'daily',
        pickupTime: '07:30 AM',
        pickupPoint: PickupPoint(
          id: _generateId('pickup', 1),
          name: 'Home - Main Gate',
          address: '123 Street Name, District, City',
          lat: '30.0444',
          lng: '31.2357',
        ),
        bus: BusInfo(
          id: _generateId('bus', 1),
          busNumber: 'BUS-101',
          plateNumber: 'ABC-1234',
        ),
        driver: DriverInfo(
          id: _generateId('driver', 1),
          name: 'Karim Abdullah',
          phone: '+201234567891',
          avatar: null,
        ),
      ),
      ChildRide(
        id: _generateId('ride', 2),
        name: 'Afternoon Return',
        type: 'dropoff',
        frequency: 'daily',
        pickupTime: '03:00 PM',
        pickupPoint: PickupPoint(
          id: _generateId('pickup', 2),
          name: 'School Main Gate',
          address: 'School Street, District, City',
          lat: '30.0450',
          lng: '31.2360',
        ),
        bus: BusInfo(
          id: _generateId('bus', 1),
          busNumber: 'BUS-101',
          plateNumber: 'ABC-1234',
        ),
        driver: DriverInfo(
          id: _generateId('driver', 1),
          name: 'Karim Abdullah',
          phone: '+201234567891',
          avatar: null,
        ),
      ),
    ];
  }

  /// Mock children with rides response
  static Map<String, dynamic> get childrenWithRidesResponse => {
        'success': true,
        'data': {
          'children': childrenWithRides.map((c) => c.toJson()).toList(),
          'byOrganization': [
            {
              'organization': {
                'id': organizations[0].id,
                'name': organizations[0].name,
                'logo': organizations[0].logo,
              },
              'children': childrenWithRides
                  .where((c) => c.organization.id == organizations[0].id)
                  .map((c) => c.toJson())
                  .toList(),
            },
            {
              'organization': {
                'id': organizations[1].id,
                'name': organizations[1].name,
                'logo': organizations[1].logo,
              },
              'children': childrenWithRides
                  .where((c) => c.organization.id == organizations[1].id)
                  .map((c) => c.toJson())
                  .toList(),
            },
            {
              'organization': {
                'id': organizations[2].id,
                'name': organizations[2].name,
                'logo': organizations[2].logo,
              },
              'children': childrenWithRides
                  .where((c) => c.organization.id == organizations[2].id)
                  .map((c) => c.toJson())
                  .toList(),
            },
          ],
          'totalChildren': children.length,
        },
      };
}
