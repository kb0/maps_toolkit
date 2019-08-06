class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);

  factory LatLng.fromMap(Map<String, double> dataMap) {
    return LatLng(dataMap['latitude'], dataMap['longitude']);
  }
}
