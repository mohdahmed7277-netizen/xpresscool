enum StaffRole { admin, staff }

class Staff {
  final String id;
  final String name;
  final String username;
  final String pinHash; // hashed PIN, never store plain text
  final StaffRole role;
  final DateTime createdAt;

  Staff({
    required this.id,
    required this.name,
    required this.username,
    required this.pinHash,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'pinHash': pinHash,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      id: map['id'] as String,
      name: map['name'] as String,
      username: map['username'] as String,
      pinHash: map['pinHash'] as String,
      role: (map['role'] as String) == 'admin' ? StaffRole.admin : StaffRole.staff,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
