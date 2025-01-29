import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:test/test.dart';

/// Asserts that the beginning point of the original line matches the beginning
/// point of the simplified line, and that the end point of the original line
/// matches the end point of the simplified line.
///
/// @param line original line
/// @param simplifiedLine simplified line
void assertEndPoints(List<LatLng> line, List<LatLng> simplifiedLine) {
  expect(simplifiedLine.first, equals(line.first));
  expect(simplifiedLine.last, equals(line.last));
}

/// Asserts that the simplified line is composed of points from the original
/// line.
///
/// @param line original line
/// @param simplifiedLine simplified line
void assertSimplifiedPointsFromLine(List<LatLng> line, List<LatLng> simplifiedLine) {
  expect(simplifiedLine.any((point) => line.contains(point)), equals(true));
}

/// Asserts that the length of the simplified line is always equal to or less
/// than the length of the original line, if simplification has eliminated any
/// points from the original line
///
/// @param line original line
/// @param simplifiedLine simplified line
void assertLineLength(List<LatLng> line, List<LatLng> simplifiedLine) {
  if (line.length == simplifiedLine.length) {
    // If no points were eliminated, then the length of both lines should be the
    // same
    expect(SphericalUtil.computeLength(simplifiedLine) - SphericalUtil.computeLength(line), closeTo(0.0, 0.0));
  } else {
    expect(simplifiedLine.length, lessThan(line.length));
    expect(SphericalUtil.computeLength(simplifiedLine), lessThan(SphericalUtil.computeLength(line)));
  }
}

List<LatLng> makeList(List<num> coords) {
  final size = coords.length ~/ 2;

  final list = <LatLng>[];
  for (var i = 0; i < size; ++i) {
    list.add(LatLng(coords[i + i].toDouble(), coords[i + i + 1].toDouble()));
  }
  return list;
}

void containsCase(List<LatLng> poly, List<LatLng> yes, List<LatLng> no) {
  for (final point in yes) {
    expect(PolygonUtil.containsLocation(point, poly, true), equals(true));
    expect(PolygonUtil.containsLocation(point, poly, false), equals(true));
  }
  for (final point in no) {
    expect(PolygonUtil.containsLocation(point, poly, true), equals(false));
    expect(PolygonUtil.containsLocation(point, poly, false), equals(false));
  }
}

void onEdgeCaseWithGeodesic(bool geodesic, List<LatLng> poly, List<LatLng> yes, List<LatLng> no) {
  for (final point in yes) {
    expect(PolygonUtil.isLocationOnEdge(point, poly, geodesic), equals(true));
    expect(PolygonUtil.isLocationOnPath(point, poly, geodesic), equals(true));
  }
  for (final point in no) {
    expect(PolygonUtil.isLocationOnEdge(point, poly, geodesic), equals(false));
    expect(PolygonUtil.isLocationOnPath(point, poly, geodesic), equals(false));
  }
}

void onEdgeCase(List<LatLng> poly, List<LatLng> yes, List<LatLng> no) {
  onEdgeCaseWithGeodesic(true, poly, yes, no);
  onEdgeCaseWithGeodesic(false, poly, yes, no);
}

void locationIndexCaseWithGeodesic(bool geodesic, List<LatLng> poly, LatLng point, int idx) {
  expect(PolygonUtil.locationIndexOnPath(point, poly, geodesic), idx);
}

void locationIndexCase(List<LatLng> poly, LatLng point, int idx) {
  locationIndexCaseWithGeodesic(true, poly, point, idx);
  locationIndexCaseWithGeodesic(false, poly, point, idx);
}

void main() {
  // The vertices of an octahedron, for testing
  final polygon = [LatLng(10, 10), LatLng(10, 20), LatLng(20, 20), LatLng(20, 10), LatLng(10, 10)];

  const encodedPolyline = '_cqeFf~cjVf@p@fA}AtAoB`ArAx@hA`GbIvDiFv@gAh@t@X\\|@z@`@Z\\Xf@Vf@VpA\\tATJ@NBBkC';

  setUp(() {});

  test('containsLocation for empty polygon', () {
    expect(PolygonUtil.containsLocation(LatLng(1, 1), [], false), equals(false));
  });

  test('containsLocation without point', () {
    expect(PolygonUtil.containsLocation(LatLng(99, 99), polygon, true), equals(false));
  });

  test('containsLocation with point', () {
    expect(PolygonUtil.containsLocation(LatLng(10, 10), polygon, true), equals(true));

    expect(PolygonUtil.containsLocation(LatLng(15, 15), polygon, true), equals(true));
  });

  test('encode/decode polygon', () {
    final polygonDecoded = PolygonUtil.decode(encodedPolyline);

    expect(polygonDecoded.length, equals(21));
    expect(polygonDecoded.last.latitude, closeTo(37.76953, 1e-6));
    expect(polygonDecoded.last.longitude, closeTo(-122.41488, 1e-6));

    expect(PolygonUtil.encode(polygonDecoded), equals(encodedPolyline));
  });

  test('simplify polygon', () {
    const polygonLine =
        'elfjD~a}uNOnFN~Em@fJv@tEMhGDjDe@hG^nF??@lA?n@IvAC`Ay@A{@DwCA{CF_EC{CEi@PBTFDJBJ?V?n@?D@?A@?@?F?F?LAf@?n@@`@@T@~@FpA?fA?p@?r@?vAH`@OR@^ETFJCLD?JA^?J?P?fAC`B@d@?b@A\\@`@Ad@@\\?`@?f@?V?H?DD@DDBBDBD?D?B?B@B@@@B@B@B@D?D?JAF@H@FCLADBDBDCFAN?b@Af@@x@@';

    final line = PolygonUtil.decode(polygonLine);
    expect(line.length, equals(95));

    final data = [
      [5, 20],
      [10, 14],
      [15, 10],
      [20, 8],
      [50, 6],
      [500, 3],
      [1000, 2]
    ];

    for (final element in data) {
      final simplifiedLine = PolygonUtil.simplify(line, element.first);
      expect(simplifiedLine.length, equals(element.last));

      assertEndPoints(line, simplifiedLine);
      assertSimplifiedPointsFromLine(line, simplifiedLine);
      assertLineLength(line, simplifiedLine);
    }
  });

  test('simplify polygon - triangle', () {
    final triangle = <LatLng>[];
    triangle.add(LatLng(28.06025, -82.41030));
    triangle.add(LatLng(28.06129, -82.40945));
    triangle.add(LatLng(28.06206, -82.40917));
    triangle.add(LatLng(28.06125, -82.40850));
    triangle.add(LatLng(28.06035, -82.40834));
    triangle.add(LatLng(28.06038, -82.40924));
    expect(PolygonUtil.isClosedPolygon(triangle), equals(false));

    final simplifiedTriangle88 = PolygonUtil.simplify(triangle, 88);
    expect(simplifiedTriangle88.length, equals(4));

    assertEndPoints(triangle, simplifiedTriangle88);
    assertSimplifiedPointsFromLine(triangle, simplifiedTriangle88);
    assertLineLength(triangle, simplifiedTriangle88);

    // Close the triangle
    triangle.add(LatLng(triangle.first.latitude, triangle.first.longitude));
    expect(PolygonUtil.isClosedPolygon(triangle), equals(true));

    final simplifiedClosedTriangle88 = PolygonUtil.simplify(triangle, 88);
    expect(simplifiedClosedTriangle88.length, equals(4));

    assertEndPoints(triangle, simplifiedClosedTriangle88);
    assertSimplifiedPointsFromLine(triangle, simplifiedClosedTriangle88);
    assertLineLength(triangle, simplifiedClosedTriangle88);
  });

  test('simplify polygon - oval', () {
    const polygonOval =
        '}wgjDxw_vNuAd@}AN{A]w@_Au@kAUaA?{@Ke@@_@C]D[FULWFOLSNMTOVOXO\\I\\CX?VJXJTDTNXTVVLVJ`@FXA\\AVLZBTATBZ@ZAT?\\?VFT@XGZ';

    final oval = PolygonUtil.decode(polygonOval);
    expect(PolygonUtil.isClosedPolygon(oval), equals(false));

    final simplifiedOval10 = PolygonUtil.simplify(oval, 10);
    expect(simplifiedOval10.length, equals(13));

    assertEndPoints(oval, simplifiedOval10);
    assertSimplifiedPointsFromLine(oval, simplifiedOval10);
    assertLineLength(oval, simplifiedOval10);

    // Close the triangle
    oval.add(LatLng(oval.first.latitude, oval.first.longitude));
    expect(PolygonUtil.isClosedPolygon(oval), equals(true));

    final simplifiedClosedOval = PolygonUtil.simplify(oval, 10);
    expect(simplifiedClosedOval.length, equals(13));

    assertEndPoints(oval, simplifiedClosedOval);
    assertSimplifiedPointsFromLine(oval, simplifiedClosedOval);
    assertLineLength(oval, simplifiedClosedOval);
  });

  test('on edge', () {
    // Empty
    onEdgeCase([], [], [LatLng(0, 0)]);

    const small = 5e-7; // About 5cm on equator, half the default tolerance.
    const big = 2e-6; // About 10cm on equator, double the default tolerance.

    // Endpoints
    onEdgeCase(makeList([1, 2]), makeList([1, 2]), makeList([3, 5]));
    onEdgeCase(makeList([1, 2, 3, 5]), makeList([1, 2, 3, 5]), makeList([0, 0]));

    // On equator.
    onEdgeCase(makeList([0, 90, 0, 180]), makeList([0, 90 - small, 0, 90 + small, 0 - small, 90, 0, 135, small, 135]),
        makeList([0, 90 - big, 0, 0, 0, -90, big, 135]));

    // Ends on same latitude.
    onEdgeCase(
        makeList([-45, -180, -45, -small]),
        makeList([-45, 180 + small, -45, 180 - small, -45 - small, 180 - small, -45, 0]),
        makeList([-45, big, -45, 180 - big, -45 + big, -90, -45, 90]));

    // Meridian.
    onEdgeCase(makeList([-10, 30, 45, 30]), makeList([10, 30 - small, 20, 30 + small, -10 - small, 30 + small]),
        makeList([-10 - big, 30, 10, -150, 0, 30 - big]));

    // Slanted close to meridian, close to North pole.
    onEdgeCase(
        makeList([0, 0, 90 - small, 0 + big]),
        makeList([1, 0 + small, 2, 0 - small, 90 - small, -90, 90 - small, 10]),
        makeList([-big, 0, 90 - big, 180, 10, big]));

    // Arc > 120 deg.
    onEdgeCase(makeList([0, 0, 0, 179.999]), makeList([0, 90, 0, small, 0, 179, small, 90]),
        makeList([0, -90, small, -100, 0, 180, 0, -big, 90, 0, -90, 180]));

    onEdgeCase(
        makeList([10, 5, 30, 15]),
        makeList([10 + 2 * big, 5 + big, 10 + big, 5 + big / 2, 30 - 2 * big, 15 - big]),
        makeList([20, 10, 10 - big, 5 - big / 2, 30 + 2 * big, 15 + big, 10 + 2 * big, 5, 10, 5 + big]));

    onEdgeCase(
        makeList([90 - small, 0, 0, 180 - small / 2]),
        makeList([big, -180 + small / 2, big, 180 - small / 4, big, 180 - small]),
        makeList([-big, -180 + small / 2, -big, 180, -big, 180 - small]));

    // Reaching close to North pole.
    onEdgeCaseWithGeodesic(true, makeList([80, 0, 80, 180 - small]),
        makeList([90 - small, -90, 90, -135, 80 - small, 0, 80 + small, 0]), makeList([80, 90, 79, big]));

    onEdgeCaseWithGeodesic(false, makeList([80, 0, 80, 180 - small]), makeList([80 - small, 0, 80 + small, 0, 80, 90]),
        makeList([79, big, 90 - small, -90, 90, -135]));
  });

  test('location index', () {
    locationIndexCase(makeList([]), LatLng(0, 0), -1);

    // One point.
    locationIndexCase(makeList([1, 2]), LatLng(1, 2), 0);
    locationIndexCase(makeList([1, 2]), LatLng(3, 5), -1);

    // Two points.
    locationIndexCase(makeList([1, 2, 3, 5]), LatLng(1, 2), 0);
    locationIndexCase(makeList([1, 2, 3, 5]), LatLng(3, 5), 0);
    locationIndexCase(makeList([1, 2, 3, 5]), LatLng(4, 6), -1);

    // Three points.
    locationIndexCase(makeList([0, 80, 0, 90, 0, 100]), LatLng(0, 80), 0);
    locationIndexCase(makeList([0, 80, 0, 90, 0, 100]), LatLng(0, 85), 0);
    locationIndexCase(makeList([0, 80, 0, 90, 0, 100]), LatLng(0, 90), 0);
    locationIndexCase(makeList([0, 80, 0, 90, 0, 100]), LatLng(0, 95), 1);
    locationIndexCase(makeList([0, 80, 0, 90, 0, 100]), LatLng(0, 100), 1);
    locationIndexCase(makeList([0, 80, 0, 90, 0, 100]), LatLng(0, 110), -1);
  });

  test('contains', () {
    // Empty.
    containsCase(makeList([]), makeList([]), makeList([0, 0]));

    // One point.
    containsCase(makeList([1, 2]), makeList([1, 2]), makeList([0, 0]));

    // Two points.
    containsCase(makeList([1, 2, 3, 5]), makeList([1, 2, 3, 5]), makeList([0, 0, 40, 4]));

    // Some arbitrary triangle.
    containsCase(makeList([0.0, 0.0, 10.0, 12.0, 20.0, 5.0]), makeList([10.0, 12.0, 10, 11, 19, 5]),
        makeList([0, 1, 11, 12, 30, 5, 0, -180, 0, 90]));

    // Around North Pole.
    containsCase(makeList([89, 0, 89, 120, 89, -120]), makeList([90, 0, 90, 180, 90, -90]), makeList([-90, 0, 0, 0]));

    // Around South Pole.
    containsCase(makeList([-89, 0, -89, 120, -89, -120]), makeList([90, 0, 90, 180, 90, -90, 0, 0]),
        makeList([-90, 0, -90, 90]));

    // Over/under segment on meridian and equator.
    containsCase(
        makeList([5, 10, 10, 10, 0, 20, 0, -10]), makeList([2.5, 10, 1, 0]), makeList([15, 10, 0, -15, 0, 25, -1, 0]));
  });

  test('contains issue-4-1', () {
    final polygon = makeList([
      55.4695522,
      25.3937088,
      55.4680877,
      25.3945885,
      55.4669666,
      25.3952887,
      55.4651588,
      25.3955238,
      55.4634045,
      25.3957539,
      55.461688,
      25.395926,
      55.4603147,
      25.396064,
      55.4590219,
      25.3962459,
      55.4580186,
      25.396384,
      55.4564952,
      25.3967619,
      55.4557013,
      25.397467,
      55.4548966,
      25.3981769,
      55.4546231,
      25.3986979,
      55.4543602,
      25.3991751,
      55.4540169,
      25.3991849,
      55.4538935,
      25.3997689,
      55.4537487,
      25.4004544,
      55.4535448,
      25.4012299,
      55.4526758,
      25.4010844,
      55.4519248,
      25.4040403,
      55.4517852,
      25.4040112,
      55.4487705,
      25.4027515,
      55.4485558,
      25.4026156,
      55.4480168,
      25.4021663,
      55.4498431,
      25.4003286,
      55.4510986,
      25.3985452,
      55.4533194,
      25.3953276,
      55.454607,
      25.393263,
      55.4548966,
      25.3928947,
      55.4551541,
      25.3923422,
      55.4552613,
      25.3913827,
      55.4551005,
      25.3903843,
      55.4553687,
      25.3899676,
      55.4563611,
      25.389815,
      55.4573321,
      25.3897108,
      55.4584693,
      25.3895291,
      55.4590433,
      25.3894467,
      55.4602503,
      25.3892553,
      55.4609638,
      25.3891559,
      55.4621171,
      25.3889694,
      55.4635441,
      25.3890759,
      55.4651105,
      25.3893376,
      55.4662719,
      25.3897823,
      55.4674708,
      25.3902487,
      55.4683774,
      25.3906583,
      55.4692679,
      25.3910217,
      55.4708289,
      25.3916445,
      55.4719017,
      25.3917995
    ]);

    expect(PolygonUtil.containsLocation(LatLng(55.455251, 25.392898), polygon, true), equals(true));

    expect(PolygonUtil.containsLocation(LatLng(55.454473, 25.394104), polygon, true), equals(true));

    expect(PolygonUtil.containsLocation(LatLng(25.392898, 55.455251), polygon, true), equals(false));

    expect(PolygonUtil.containsLocation(LatLng(25.394104, 55.454473), polygon, true), equals(false));
  });

  test('contains issue-4-2', () {
    final polygon = makeList([
      25.3937088,
      55.4695522,
      25.3945885,
      55.4680877,
      25.3952887,
      55.4669666,
      25.3955238,
      55.4651588,
      25.3957539,
      55.4634045,
      25.395926,
      55.461688,
      25.396064,
      55.4603147,
      25.3962459,
      55.4590219,
      25.396384,
      55.4580186,
      25.3967619,
      55.4564952,
      25.397467,
      55.4557013,
      25.3981769,
      55.4548966,
      25.3986979,
      55.4546231,
      25.3991751,
      55.4543602,
      25.3991849,
      55.4540169,
      25.3997689,
      55.4538935,
      25.4004544,
      55.4537487,
      25.4012299,
      55.4535448,
      25.4010844,
      55.4526758,
      25.4040403,
      55.4519248,
      25.4040112,
      55.4517852,
      25.4027515,
      55.4487705,
      25.4026156,
      55.4485558,
      25.4021663,
      55.4480168,
      25.4003286,
      55.4498431,
      25.3985452,
      55.4510986,
      25.3953276,
      55.4533194,
      25.393263,
      55.454607,
      25.3928947,
      55.4548966,
      25.3923422,
      55.4551541,
      25.3913827,
      55.4552613,
      25.3903843,
      55.4551005,
      25.3899676,
      55.4553687,
      25.389815,
      55.4563611,
      25.3897108,
      55.4573321,
      25.3895291,
      55.4584693,
      25.3894467,
      55.4590433,
      25.3892553,
      55.4602503,
      25.3891559,
      55.4609638,
      25.3889694,
      55.4621171,
      25.3890759,
      55.4635441,
      25.3893376,
      55.4651105,
      25.3897823,
      55.4662719,
      25.3902487,
      55.4674708,
      25.3906583,
      55.4683774,
      25.3910217,
      55.4692679,
      25.3916445,
      55.4708289,
      25.3917995,
      55.4719017,
      25.3937088,
      55.4695522
    ]);

    expect(PolygonUtil.containsLocation(LatLng(55.455251, 25.392898), polygon, true), equals(false));

    expect(PolygonUtil.containsLocation(LatLng(25.392898, 55.455251), polygon, true), equals(true));

    expect(PolygonUtil.containsLocation(LatLng(55.454473, 25.394104), polygon, true), equals(false));

    expect(PolygonUtil.containsLocation(LatLng(25.394104, 55.454473), polygon, true), equals(true));
  });
}
