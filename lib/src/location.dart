import 'latlng.dart';

class Location {
  final LatLng latlng;

  final double accuracy;
  final DateTime time;

  Location({this.latlng, this.accuracy, this.time});

//  factory LatLng.fromMap(Map<String, double> dataMap) {
//    return LatLng(dataMap['latitude'], dataMap['longitude']);
//  }
}
