import 'latlng.dart';

class Location {
  final LatLng latlng;

  final double accuracy;
  final DateTime time;

  Location({
    required this.latlng,
    required this.accuracy,
    required this.time,
  });

  @override
  String toString() => 'LatLng: $latlng, Accuracy: $accuracy, Time: $time';

//  factory LatLng.fromMap(Map<String, double> dataMap) {
//    return LatLng(dataMap['latitude'], dataMap['longitude']);
//  }
}
