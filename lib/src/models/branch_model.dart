import 'package:ayahhebat/src/models/zone_model.dart';

class Branch {
  final int id;
  final String name;
  final Zone? zone;

  Branch({required this.id, required this.name, this.zone});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(id: json['id'], name: json['name']);
  }
}