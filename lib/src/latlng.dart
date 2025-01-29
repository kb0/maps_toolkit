class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  factory LatLng.fromMap(Map<String, dynamic> dataMap) =>
      LatLng(dataMap['latitude'], dataMap['longitude']);

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude
  };

  factory LatLng.fromCoords(Map<String, dynamic> json)  =>
      LatLng(json['coordinates'][1], json['coordinates'][0]);

  Map<String, dynamic> toCoordsJson() => {
    'coordinates': [longitude, latitude]
  };

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is LatLng) {
      return other.latitude == latitude && other.longitude == longitude;
    }

    return false;
  }

  @override
  int get hashCode =>
      _combine(_combine(0, latitude.hashCode), longitude.hashCode);

  int _combine(int hash, int value) {
    hash = 0x1fffffff & (hash + value);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  @override
  String toString() => 'Lat: $latitude, Lng: $longitude';
}
