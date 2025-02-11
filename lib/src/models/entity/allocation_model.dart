class Allocation {
  final int id;
  final String name;
  final String code;

  Allocation({
    required this.id,
    required this.name,
    required this.code,
  });

  factory Allocation.fromJson(Map<String, dynamic> json) {
    return Allocation(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}
