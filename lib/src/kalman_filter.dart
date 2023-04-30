import 'dart:math';

// import 'latlng.dart';
import 'package:latlong2/latlong.dart';

import 'location.dart';
import 'spherical_util.dart';

class KalmanFilter {
  static Location apply(
      Location location, Location? lastLocation, double constant) {
    final accuracy = max(location.accuracy, 1);
    var variance = accuracy * accuracy;

    if (lastLocation != null) {
      final timestampInc = location.time.microsecondsSinceEpoch -
          lastLocation.time.microsecondsSinceEpoch;

      if (timestampInc > 0) {
        // We can tune the velocity and particularly the coefficient at the end
        final speed = SphericalUtil.computeDistanceBetween(
                location.latlng, lastLocation.latlng) /
            timestampInc *
            constant;

        variance += timestampInc * speed * speed / 1000;
      }

      final k = variance / (variance + accuracy * accuracy);

      // variance = (1 - k) * result.variance;
      return Location(
          latlng: LatLng(
              k * (location.latlng.latitude - lastLocation.latlng.latitude),
              k * (location.latlng.longitude - lastLocation.latlng.longitude)),
          accuracy: location.accuracy,
          time: location.time);
    }

    return location;
  }
}
