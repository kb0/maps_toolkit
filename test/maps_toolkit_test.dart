import 'dart:math';

import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:maps_toolkit/src/math_util.dart';
import 'package:test/test.dart';

void expectLatLngApproxEquals(LatLng actual, LatLng expected) {
  expect(actual.latitude, closeTo(expected.latitude, 1e-6));

  if (expected.longitude == -180.0) {
    expected.longitude = 180.0;
  }

  num cosLat = cos(MathUtil.toRadians(actual.latitude));
  expect(cosLat * actual.longitude, closeTo(cosLat * expected.longitude, 1e-6));
}

void main() {
  group('SphericalUtilTest', () {
    // The vertices of an octahedron, for testing
    final LatLng up = LatLng(90, 0);
    final LatLng down = LatLng(-90, 0);
    final LatLng front = LatLng(0, 0);
    final LatLng right = LatLng(0, 90);
    final LatLng back = LatLng(0, 180);
    final LatLng left = LatLng(0, -90);

    setUp(() {});

    test('testAngles', () {
      // Same vertex
      expect(SphericalUtil.computeAngleBetween(up, up), closeTo(0, 1e-6));
      expect(SphericalUtil.computeAngleBetween(down, down), closeTo(0, 1e-6));
      expect(SphericalUtil.computeAngleBetween(left, left), closeTo(0, 1e-6));
      expect(SphericalUtil.computeAngleBetween(right, right), closeTo(0, 1e-6));
      expect(SphericalUtil.computeAngleBetween(front, front), closeTo(0, 1e-6));
      expect(SphericalUtil.computeAngleBetween(back, back), closeTo(0, 1e-6));

      // Adjacent vertices
      expect(SphericalUtil.computeAngleBetween(up, front), closeTo(pi / 2, 1e-6));
      expect(SphericalUtil.computeAngleBetween(up, right), closeTo(pi / 2, 1e-6));
      expect(SphericalUtil.computeAngleBetween(up, back), closeTo(pi / 2, 1e-6));
      expect(SphericalUtil.computeAngleBetween(up, left), closeTo(pi / 2, 1e-6));

      expect(SphericalUtil.computeAngleBetween(down, front), closeTo(pi / 2, 1e-6));
      expect(SphericalUtil.computeAngleBetween(down, right), closeTo(pi / 2, 1e-6));
      expect(SphericalUtil.computeAngleBetween(down, back), closeTo(pi / 2, 1e-6));
      expect(SphericalUtil.computeAngleBetween(down, left), closeTo(pi / 2, 1e-6));

      expect(SphericalUtil.computeAngleBetween(back, up), closeTo(pi / 2, 1e-6));
      expect(SphericalUtil.computeAngleBetween(back, right), closeTo(pi / 2, 1e-6));
      expect(SphericalUtil.computeAngleBetween(back, down), closeTo(pi / 2, 1e-6));
      expect(SphericalUtil.computeAngleBetween(back, left), closeTo(pi / 2, 1e-6));

      // Opposite vertices
      expect(SphericalUtil.computeAngleBetween(up, down), closeTo(pi, 1e-6));
      expect(SphericalUtil.computeAngleBetween(front, back), closeTo(pi, 1e-6));
      expect(SphericalUtil.computeAngleBetween(left, right), closeTo(pi, 1e-6));
    });

    test('testDistances', () {
      expect(SphericalUtil.computeDistanceBetween(up, down), closeTo(pi * SphericalUtil.earthRadius, 1e-6));
    });

    test('testHeadings', () {
      // Opposing vertices for which there is a result
      expect(SphericalUtil.computeHeading(up, down), closeTo(-180, 1e-6));
      expect(SphericalUtil.computeHeading(down, up), closeTo(0, 1e-6));

      // Adjacent vertices for which there is a result
      expect(SphericalUtil.computeHeading(front, up), closeTo(0, 1e-6));
      expect(SphericalUtil.computeHeading(right, up), closeTo(0, 1e-6));
      expect(SphericalUtil.computeHeading(back, up), closeTo(0, 1e-6));
      expect(SphericalUtil.computeHeading(down, up), closeTo(0, 1e-6));

      expect(SphericalUtil.computeHeading(front, down), closeTo(-180, 1e-6));
      expect(SphericalUtil.computeHeading(right, down), closeTo(-180, 1e-6));
      expect(SphericalUtil.computeHeading(back, down), closeTo(-180, 1e-6));
      expect(SphericalUtil.computeHeading(left, down), closeTo(-180, 1e-6));

      expect(SphericalUtil.computeHeading(right, front), closeTo(-90, 1e-6));
      expect(SphericalUtil.computeHeading(left, front), closeTo(90, 1e-6));

      expect(SphericalUtil.computeHeading(front, right), closeTo(90, 1e-6));
      expect(SphericalUtil.computeHeading(back, right), closeTo(-90, 1e-6));
    });

    test('testComputeOffset', () {
// From front
      expectLatLngApproxEquals(front, SphericalUtil.computeOffset(front, 0, 0));
      expectLatLngApproxEquals(up, SphericalUtil.computeOffset(front, pi * SphericalUtil.earthRadius / 2, 0));
      expectLatLngApproxEquals(down, SphericalUtil.computeOffset(front, pi * SphericalUtil.earthRadius / 2, 180));
      expectLatLngApproxEquals(left, SphericalUtil.computeOffset(front, pi * SphericalUtil.earthRadius / 2, -90));
      expectLatLngApproxEquals(right, SphericalUtil.computeOffset(front, pi * SphericalUtil.earthRadius / 2, 90));
      expectLatLngApproxEquals(back, SphericalUtil.computeOffset(front, pi * SphericalUtil.earthRadius, 0));
      expectLatLngApproxEquals(back, SphericalUtil.computeOffset(front, pi * SphericalUtil.earthRadius, 90));

      // From left
      expectLatLngApproxEquals(left, SphericalUtil.computeOffset(left, 0, 0));
      expectLatLngApproxEquals(up, SphericalUtil.computeOffset(left, pi * SphericalUtil.earthRadius / 2, 0));
      expectLatLngApproxEquals(down, SphericalUtil.computeOffset(left, pi * SphericalUtil.earthRadius / 2, 180));
      expectLatLngApproxEquals(front, SphericalUtil.computeOffset(left, pi * SphericalUtil.earthRadius / 2, 90));
      expectLatLngApproxEquals(back, SphericalUtil.computeOffset(left, pi * SphericalUtil.earthRadius / 2, -90));
      expectLatLngApproxEquals(right, SphericalUtil.computeOffset(left, pi * SphericalUtil.earthRadius, 0));
      expectLatLngApproxEquals(right, SphericalUtil.computeOffset(left, pi * SphericalUtil.earthRadius, 90));

      // NOTE(appleton): Heading is undefined at the poles, so we do not test
      // from up/down.
    });

    test('testComputeOffsetOrigin', () {
      expectLatLngApproxEquals(front, SphericalUtil.computeOffsetOrigin(front, 0, 0));

      expectLatLngApproxEquals(
          front, SphericalUtil.computeOffsetOrigin(LatLng(0, 45), pi * SphericalUtil.earthRadius / 4, 90));
      expectLatLngApproxEquals(
          front, SphericalUtil.computeOffsetOrigin(LatLng(0, -45), pi * SphericalUtil.earthRadius / 4, -90));
      expectLatLngApproxEquals(
          front, SphericalUtil.computeOffsetOrigin(LatLng(45, 0), pi * SphericalUtil.earthRadius / 4, 0));
      expectLatLngApproxEquals(
          front, SphericalUtil.computeOffsetOrigin(LatLng(-45, 0), pi * SphericalUtil.earthRadius / 4, 180));

      // Situations with no solution, should return null.

      // First 'over' the pole.
      expect(null, SphericalUtil.computeOffsetOrigin(LatLng(80, 0), pi * SphericalUtil.earthRadius / 4, 180));
      // Second a distance that doesn't fit on the earth.
      expect(null, SphericalUtil.computeOffsetOrigin(LatLng(80, 0), pi * SphericalUtil.earthRadius / 4, 90));
    });

    test('testComputeOffsetAndBackToOrigin', () {
      LatLng start = LatLng(40, 40);
      num distance = 1e5;
      num heading = 15;
      LatLng end;

      // Some semi-random values to demonstrate going forward and backward yields
      // the same location.
      end = SphericalUtil.computeOffset(start, distance, heading);
      expectLatLngApproxEquals(start, SphericalUtil.computeOffsetOrigin(end, distance, heading));

      heading = -37;
      end = SphericalUtil.computeOffset(start, distance, heading);
      expectLatLngApproxEquals(start, SphericalUtil.computeOffsetOrigin(end, distance, heading));

      distance = 3.8e+7;
      end = SphericalUtil.computeOffset(start, distance, heading);
      expectLatLngApproxEquals(start, SphericalUtil.computeOffsetOrigin(end, distance, heading));

      start = LatLng(-21, -73);
      end = SphericalUtil.computeOffset(start, distance, heading);
      expectLatLngApproxEquals(start, SphericalUtil.computeOffsetOrigin(end, distance, heading));

      // computeOffsetOrigin with multiple solutions, all we care about is that
      // going from there yields the requested result.
      //
      // First, for this particular situation the latitude is completely arbitrary.
      start = SphericalUtil.computeOffsetOrigin(LatLng(0, 90), pi * SphericalUtil.earthRadius / 2, 90);
      expectLatLngApproxEquals(
          LatLng(0, 90), SphericalUtil.computeOffset(start, pi * SphericalUtil.earthRadius / 2, 90));

      // Second, for this particular situation the longitude is completely
      // arbitrary.
      start = SphericalUtil.computeOffsetOrigin(LatLng(90, 0), pi * SphericalUtil.earthRadius / 4, 0);
      expectLatLngApproxEquals(
          LatLng(90, 0), SphericalUtil.computeOffset(start, pi * SphericalUtil.earthRadius / 4, 0));
    });

    test('testInterpolate', () {
// Same point
      expectLatLngApproxEquals(up, SphericalUtil.interpolate(up, up, 1 / 2.0));
      expectLatLngApproxEquals(down, SphericalUtil.interpolate(down, down, 1 / 2.0));
      expectLatLngApproxEquals(left, SphericalUtil.interpolate(left, left, 1 / 2.0));

      // Between front and up
      expectLatLngApproxEquals(LatLng(1, 0), SphericalUtil.interpolate(front, up, 1 / 90.0));
      expectLatLngApproxEquals(LatLng(1, 0), SphericalUtil.interpolate(up, front, 89 / 90.0));
      expectLatLngApproxEquals(LatLng(89, 0), SphericalUtil.interpolate(front, up, 89 / 90.0));
      expectLatLngApproxEquals(LatLng(89, 0), SphericalUtil.interpolate(up, front, 1 / 90.0));

      // Between front and down
      expectLatLngApproxEquals(LatLng(-1, 0), SphericalUtil.interpolate(front, down, 1 / 90.0));
      expectLatLngApproxEquals(LatLng(-1, 0), SphericalUtil.interpolate(down, front, 89 / 90.0));
      expectLatLngApproxEquals(LatLng(-89, 0), SphericalUtil.interpolate(front, down, 89 / 90.0));
      expectLatLngApproxEquals(LatLng(-89, 0), SphericalUtil.interpolate(down, front, 1 / 90.0));

      // Between left and back
      expectLatLngApproxEquals(LatLng(0, -91), SphericalUtil.interpolate(left, back, 1 / 90.0));
      expectLatLngApproxEquals(LatLng(0, -91), SphericalUtil.interpolate(back, left, 89 / 90.0));
      expectLatLngApproxEquals(LatLng(0, -179), SphericalUtil.interpolate(left, back, 89 / 90.0));
      expectLatLngApproxEquals(LatLng(0, -179), SphericalUtil.interpolate(back, left, 1 / 90.0));

      // geodesic crosses pole
      expectLatLngApproxEquals(up, SphericalUtil.interpolate(LatLng(45, 0), LatLng(45, 180), 1 / 2.0));
      expectLatLngApproxEquals(down, SphericalUtil.interpolate(LatLng(-45, 0), LatLng(-45, 180), 1 / 2.0));

      // boundary values for fraction, between left and back
      expectLatLngApproxEquals(left, SphericalUtil.interpolate(left, back, 0));
      expectLatLngApproxEquals(back, SphericalUtil.interpolate(left, back, 1.0));

      // two nearby points, separated by ~4m, for which the Slerp algorithm is not stable and we
      // have to fall back to linear interpolation.
      expectLatLngApproxEquals(LatLng(-37.756872, 175.325252),
          SphericalUtil.interpolate(LatLng(-37.756891, 175.325262), LatLng(-37.756853, 175.325242), 0.5));
    });

    test('testComputeLength', () {
      List<LatLng> latLngs;

      expect(SphericalUtil.computeLength([]), closeTo(0, 1e-6));
      expect(SphericalUtil.computeLength([LatLng(0, 0)]), closeTo(0, 1e-6));

      latLngs = [LatLng(0, 0), LatLng(0.1, 0.1)];
      expect(SphericalUtil.computeLength(latLngs),
          closeTo(MathUtil.toRadians(0.1) * sqrt(2) * SphericalUtil.earthRadius, 1));

      latLngs = [LatLng(0, 0), LatLng(90, 0), LatLng(0, 90)];
      expect(SphericalUtil.computeLength(latLngs), closeTo(pi * SphericalUtil.earthRadius, 1e-6));
    });

    test('testIsCCW', () {
      // One face of the octahedron
      expect(1, isCCW(right, up, front));
      expect(1, isCCW(up, front, right));
      expect(1, isCCW(front, right, up));
      expect(-1, isCCW(front, up, right));
      expect(-1, isCCW(up, right, front));
      expect(-1, isCCW(right, front, up));
    });

    test('testComputeTriangleArea', () {
      expect(computeTriangleArea(right, up, front),
          closeTo(SphericalUtil.earthRadius * SphericalUtil.earthRadius * pi / 2, 1e-2));
      expect(computeTriangleArea(front, up, right),
          closeTo(SphericalUtil.earthRadius * SphericalUtil.earthRadius * pi / 2, 1e-2));

      // computeArea returns area of zero on small polys
      num area =
          computeTriangleArea(LatLng(0, 0), LatLng(0, MathUtil.toDegrees(1E-6)), LatLng(MathUtil.toDegrees(1E-6), 0));
      num expectedArea = SphericalUtil.earthRadius * SphericalUtil.earthRadius * 1E-12 / 2;

      expect(area, closeTo(expectedArea, 1e-8));
    });

    test('testComputeSignedTriangleArea', () {
      expect(
          computeSignedTriangleArea(LatLng(0, 0), LatLng(0, 0.1), LatLng(0.1, 0.1)),
          closeTo(
              SphericalUtil.earthRadius *
                  SphericalUtil.earthRadius *
                  MathUtil.toRadians(0.1) *
                  MathUtil.toRadians(0.1) /
                  2,
              1e2));

      expect(computeSignedTriangleArea(right, up, front),
          closeTo(SphericalUtil.earthRadius * SphericalUtil.earthRadius * pi / 2, 1e-2));

      expect(computeSignedTriangleArea(front, up, right),
          closeTo(SphericalUtil.earthRadius * SphericalUtil.earthRadius * -pi / 2, 1e-2));
    });

    test('testComputeArea', () {
      expect(SphericalUtil.computeArea([right, up, front, down, right]),
          closeTo(pi * SphericalUtil.earthRadius * SphericalUtil.earthRadius, .4));

      expect(SphericalUtil.computeArea([right, down, front, up, right]),
          closeTo(pi * SphericalUtil.earthRadius * SphericalUtil.earthRadius, .4));
    });

    test('testComputeSignedArea', () {
      List<LatLng> path = [right, up, front, down, right];
      List<LatLng> pathReversed = [right, down, front, up, right];

      expect(-SphericalUtil.computeSignedArea(path), SphericalUtil.computeSignedArea(pathReversed));
    });
  });
}

num computeSignedTriangleArea(LatLng a, LatLng b, LatLng c) => SphericalUtil.computeSignedArea([a, b, c]);

num computeTriangleArea(LatLng a, LatLng b, LatLng c) => computeSignedTriangleArea(a, b, c).abs();

int isCCW(LatLng a, LatLng b, LatLng c) => computeSignedTriangleArea(a, b, c) > 0 ? 1 : -1;
