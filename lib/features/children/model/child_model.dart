class ChildResponse {
  final List<Child> children;

  ChildResponse({required this.children});

  factory ChildResponse.fromJson(Map<String, dynamic> json) {
    // Navigating data -> children
    var list = json['data']['children'] as List;
    List<Child> childrenList = list.map((i) => Child.fromJson(i)).toList();
    return ChildResponse(children: childrenList);
  }
}

class Child {
  final String id;
  final String name;
  final String? avatar;
  final String? grade;
  final String? classroom;
  final String code;
  final String status;
  final Organization? organization;
  final Wallet? wallet;

  Child({
    required this.id,
    required this.name,
    this.avatar,
    this.grade,
    this.classroom,
    required this.code,
    required this.status,
    this.organization,
    this.wallet,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      avatar: json['avatar'],
      grade: json['grade'],
      classroom: json['classroom'],
      code: json['code'] ?? '',
      status: json['status'] ?? 'inactive',
      organization: json['organization'] != null
          ? Organization.fromJson(json['organization'])
          : null,
      wallet: json['wallet'] != null ? Wallet.fromJson(json['wallet']) : null,
    );
  }
}

class Organization {
  final String name;
  final String? logo;

  Organization({required this.name, this.logo});

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      name: json['name'] ?? '',
      logo: json['logo'],
    );
  }
}

class Wallet {
  final num balance;

  Wallet({required this.balance});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(balance: json['balance'] ?? 0);
  }
}
