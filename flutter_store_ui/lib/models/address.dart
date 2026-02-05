class Address {
  final int id;
  final String name;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final double latitude;
  final double longitude;

  Address({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.isDefault,
    required this.latitude,
    required this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      name: json['name'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'], // ✅ FIX
      country: json['country'],
      isDefault: json['is_default'] ?? false, // ✅ FIX
      latitude: (json['lat'] ?? 0).toDouble(), // ✅ FIX
      longitude: (json['lng'] ?? 0).toDouble(), // ✅ FIX
    );
  }

}
