class KuttabBranch {
  final int id;
  final String name;

  KuttabBranch({
    required this.id,
    required this.name,
  });

  factory KuttabBranch.fromJson(Map<String, dynamic> json) {
    return KuttabBranch(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  KuttabBranch copyWith({
    int? id,
    String? name,
  }) {
    return KuttabBranch(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() {
    return 'KuttabBranch(id: $id, name: $name)';
  }
}
