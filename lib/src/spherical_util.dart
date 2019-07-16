import 'dart:math';

import 'latlng.dart';
import 'math_util.dart';

/// Port of SphericalUtil from android-maps-utils (https://github.com/googlemaps/android-maps-utils)
class SphericalUtil {
  static const num earthRadius = 6371009.0;

  /// Returns the heading from one LatLng to another LatLng. Headings are
  /// expressed in degrees clockwise from North within the range [-180,180).
  /// @return The heading in degrees clockwise from north.
  static num computeHeading(LatLng from, LatLng to) {
    // http://williams.best.vwh.net/avform.htm#Crs
    num fromLat = MathUtil.toRadians(from.latitude);
    num fromLng = MathUtil.toRadians(from.longitude);
    num toLat = MathUtil.toRadians(to.latitude);
    num toLng = MathUtil.toRadians(to.longitude);
    num dLng = toLng - fromLng;
    num heading = atan2(sin(dLng) * cos(toLat), cos(fromLat) * sin(toLat) - sin(fromLat) * cos(toLat) * cos(dLng));

    return MathUtil.wrap(MathUtil.toDegrees(heading), -180, 180);
  }

  /// Returns the LatLng resulting from moving a distance from an origin
  /// in the specified heading (expressed in degrees clockwise from north).
  /// @param from     The LatLng from which to start.
  /// @param distance The distance to travel.
  /// @param heading  The heading in degrees clockwise from north.
  static LatLng computeOffset(LatLng from, num distance, num heading) {
    distance /= earthRadius;
    heading = MathUtil.toRadians(heading);
    // http://williams.best.vwh.net/avform.htm#LL
    num fromLat = MathUtil.toRadians(from.latitude);
    num fromLng = MathUtil.toRadians(from.longitude);
    num cosDistance = cos(distance);
    num sinDistance = sin(distance);
    num sinFromLat = sin(fromLat);
    num cosFromLat = cos(fromLat);
    num sinLat = cosDistance * sinFromLat + sinDistance * cosFromLat * cos(heading);
    num dLng = atan2(sinDistance * cosFromLat * sin(heading), cosDistance - sinFromLat * sinLat);

    return LatLng(MathUtil.toDegrees(asin(sinLat)), MathUtil.toDegrees(fromLng + dLng));
  }

  /// Returns the location of origin when provided with a LatLng destination,
  /// meters travelled and original heading. Headings are expressed in degrees
  /// clockwise from North. This function returns null when no solution is
  /// available.
  /// @param to       The destination LatLng.
  /// @param distance The distance travelled, in meters.
  /// @param heading  The heading in degrees clockwise from north.
  static LatLng computeOffsetOrigin(LatLng to, num distance, num heading) {
    heading = MathUtil.toRadians(heading);
    distance /= earthRadius;
    // http://lists.maptools.org/pipermail/proj/2008-October/003939.html
    num n1 = cos(distance);
    num n2 = sin(distance) * cos(heading);
    num n3 = sin(distance) * sin(heading);
    num n4 = sin(MathUtil.toRadians(to.latitude));
    // There are two solutions for b. b = n2 * n4 +/- sqrt(), one solution results
    // in the latitude outside the [-90, 90] range. We first try one solution and
    // back off to the other if we are outside that range.
    num n12 = n1 * n1;
    num discriminant = n2 * n2 * n12 + n12 * n12 - n12 * n4 * n4;
    if (discriminant < 0) {
      // No real solution which would make sense in LatLng-space.
      return null;
    }
    num b = n2 * n4 + sqrt(discriminant);
    b /= n1 * n1 + n2 * n2;
    num a = (n4 - n2 * b) / n1;
    num fromLatRadians = atan2(a, b);
    if (fromLatRadians < -pi / 2 || fromLatRadians > pi / 2) {
      b = n2 * n4 - sqrt(discriminant);
      b /= n1 * n1 + n2 * n2;
      fromLatRadians = atan2(a, b);
    }
    if (fromLatRadians < -pi / 2 || fromLatRadians > pi / 2) {
      // No solution which would make sense in LatLng-space.
      return null;
    }
    num fromLngRadians =
        MathUtil.toRadians(to.longitude) - atan2(n3, n1 * cos(fromLatRadians) - n2 * sin(fromLatRadians));
    return LatLng(MathUtil.toDegrees(fromLatRadians), MathUtil.toDegrees(fromLngRadians));
  }

  /// Returns the LatLng which lies the given fraction of the way between the
  /// origin LatLng and the destination LatLng.
  /// @param from     The LatLng from which to start.
  /// @param to       The LatLng toward which to travel.
  /// @param fraction A fraction of the distance to travel.
  /// @return The interpolated LatLng.
  static LatLng interpolate(LatLng from, LatLng to, num fraction) {
    // http://en.wikipedia.org/wiki/Slerp
    num fromLat = MathUtil.toRadians(from.latitude);
    num fromLng = MathUtil.toRadians(from.longitude);
    num toLat = MathUtil.toRadians(to.latitude);
    num toLng = MathUtil.toRadians(to.longitude);
    num cosFromLat = cos(fromLat);
    num cosToLat = cos(toLat);

    // Computes Spherical interpolation coefficients.
    num angle = computeAngleBetween(from, to);
    num sinAngle = sin(angle);
    if (sinAngle < 1E-6) {
      return LatLng(from.latitude + fraction * (to.latitude - from.latitude),
          from.longitude + fraction * (to.longitude - from.longitude));
    }
    num a = sin((1 - fraction) * angle) / sinAngle;
    num b = sin(fraction * angle) / sinAngle;

    // Converts from polar to vector and interpolate.
    num x = a * cosFromLat * cos(fromLng) + b * cosToLat * cos(toLng);
    num y = a * cosFromLat * sin(fromLng) + b * cosToLat * sin(toLng);
    num z = a * sin(fromLat) + b * sin(toLat);

    // Converts interpolated vector back to polar.
    num lat = atan2(z, sqrt(x * x + y * y));
    num lng = atan2(y, x);

    return LatLng(MathUtil.toDegrees(lat), MathUtil.toDegrees(lng));
  }

  /// Returns distance on the unit sphere; the arguments are in radians.
  static num distanceRadians(num lat1, num lng1, num lat2, num lng2) {
    return MathUtil.arcHav(MathUtil.havDistance(lat1, lat2, lng1 - lng2));
  }

  /// Returns the angle between two LatLngs, in radians. This is the same as the distance
  /// on the unit sphere.
  static num computeAngleBetween(LatLng from, LatLng to) {
    return distanceRadians(MathUtil.toRadians(from.latitude), MathUtil.toRadians(from.longitude),
        MathUtil.toRadians(to.latitude), MathUtil.toRadians(to.longitude));
  }

  /// Returns the distance between two LatLngs, in meters.
  static num computeDistanceBetween(LatLng from, LatLng to) {
    return computeAngleBetween(from, to) * earthRadius;
  }

  /// Returns the length of the given path, in meters, on Earth.
  static num computeLength(List<LatLng> path) {
    if (path.length < 2) {
      return 0;
    }

    LatLng prev = path.first;
    num prevLat = MathUtil.toRadians(prev.latitude);
    num prevLng = MathUtil.toRadians(prev.longitude);

    num length = path.fold(0.0, (value, point) {
      num lat = MathUtil.toRadians(point.latitude);
      num lng = MathUtil.toRadians(point.longitude);
      value += distanceRadians(prevLat, prevLng, lat, lng);
      prevLat = lat;
      prevLng = lng;

      return value;
    });

    return length * earthRadius;
  }

  /// Returns the area of a closed path on Earth.
  /// @param path A closed path.
  /// @return The path's area in square meters.
  static num computeArea(List<LatLng> path) {
    return computeSignedArea(path).abs();
  }

  /// Returns the signed area of a closed path on Earth. The sign of the area may be used to
  /// determine the orientation of the path.
  /// "inside" is the surface that does not contain the South Pole.
  /// @param path A closed path.
  /// @return The loop's area in square meters.
  static num computeSignedArea(List<LatLng> path) {
    return _computeSignedArea(path, earthRadius);
  }

  /// Returns the signed area of a closed path on a sphere of given radius.
  /// The computed area uses the same units as the radius squared.
  /// Used by SphericalUtilTest.
  static num _computeSignedArea(List<LatLng> path, num radius) {
    if (path.length < 3) {
      return 0;
    }

    LatLng prev = path.last;
    num prevTanLat = tan((pi / 2 - MathUtil.toRadians(prev.latitude)) / 2);
    num prevLng = MathUtil.toRadians(prev.longitude);

    // For each edge, accumulate the signed area of the triangle formed by the North Pole
    // and that edge ("polar triangle").
    num total = path.fold(0.0, (value, point) {
      num tanLat = tan((pi / 2 - MathUtil.toRadians(point.latitude)) / 2);
      num lng = MathUtil.toRadians(point.longitude);
      value += _polarTriangleArea(tanLat, lng, prevTanLat, prevLng);
      prevTanLat = tanLat;
      prevLng = lng;

      return value;
    });

    return total * (radius * radius);
  }

  /// Returns the signed area of a triangle which has North Pole as a vertex.
  /// Formula derived from "Area of a spherical triangle given two edges and the included angle"
  /// as per "Spherical Trigonometry" by Todhunter, page 71, section 103, point 2.
  /// See http://books.google.com/books?id=3uBHAAAAIAAJ&pg=PA71
  /// The arguments named "tan" are tan((pi/2 - latitude)/2).
  static num _polarTriangleArea(num tan1, num lng1, num tan2, num lng2) {
    num deltaLng = lng1 - lng2;
    num t = tan1 * tan2;
    return 2 * atan2(t * sin(deltaLng), 1 + t * cos(deltaLng));
  }
}
