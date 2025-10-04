class PharmacyModel {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final double? latitude;
  final double? longitude;
  final String operatingHours;
  final bool isOpen;
  final double? distance;

  PharmacyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    this.latitude,
    this.longitude,
    required this.operatingHours,
    required this.isOpen,
    this.distance,
  });

  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    return PharmacyModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      operatingHours: json['operatingHours'] ?? '09:00-18:00',
      isOpen: json['isOpen'] ?? false,
      distance: json['distance']?.toDouble(),
    );
  }

  String get displayDistance {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toInt()}m';
    }
    return '${distance!.toStringAsFixed(1)}km';
  }
}
