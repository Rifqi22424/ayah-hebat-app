import 'kuttab_branch_model.dart';

class KuttabZone {
  final int id;
  final String name;
  final List<KuttabBranch> branches;

  KuttabZone({
    required this.id,
    required this.name,
    required this.branches,
  });

  factory KuttabZone.fromJson(Map<String, dynamic> json) {
    return KuttabZone(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      branches: (json['branches'] as List<dynamic>?)
              ?.map((b) => KuttabBranch.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'branches': branches.map((b) => b.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'KuttabZone(id: $id, name: $name, branches: ${branches.length})';
  }
}
