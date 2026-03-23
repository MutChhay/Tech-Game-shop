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
    try {
      return Address(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'Unknown',
        street: json['street'] ?? '',
        city: json['city'] ?? '',
        state: json['state'] ?? '',
        postalCode: json['postal_code'] ?? '',
        country: json['country'] ?? '',
        isDefault: json['is_default'] == 1 || json['is_default'] == true,
        latitude: json['lat'] == null
            ? 0.0
            : double.parse(json['lat'].toString()),
        longitude: json['lng'] == null
            ? 0.0
            : double.parse(json['lng'].toString()),
      );
    } catch (e) {
      print('❌ Error parsing address: $json, Error: $e');
      rethrow;
    }
  }
}
