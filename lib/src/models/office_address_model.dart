class OfficeAddress {
  final int id;
  final String name;
  final String address;

  OfficeAddress({
    required this.id,
    required this.name,
    required this.address,
  });

  factory OfficeAddress.fromJson(Map<String, dynamic> json) {
    return OfficeAddress(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
    };
  }

  OfficeAddress copyWith({
    int? id,
    String? name,
    String? address,
  }) {
    return OfficeAddress(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }

  @override
  String toString() {
    return 'id: $id, name $name, address: $address';
  }
}
