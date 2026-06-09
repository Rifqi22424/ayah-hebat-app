import 'package:ayahhebat/src/models/branch_model.dart';

class Zone {
  final int id;
  final String name;
  final List<Branch>? branches;

  Zone({required this.id, required this.name, this.branches});

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(id: json['id'], name: json['name'], branches: json['branches'] != null ? (json['branches'] as List).map((b) => Branch.fromJson(b)).toList() : null);
  }
}