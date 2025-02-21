class Employee {
  final String id;
  final String name;
  final String email;
  final String role;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
