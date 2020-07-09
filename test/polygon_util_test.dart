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
void assertSimplifiedPointsFromLine(
    List<LatLng> line, List<LatLng> simplifiedLine) {
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
    expect(
        SphericalUtil.computeLength(simplifiedLine) -
            SphericalUtil.computeLength(line),
        closeTo(0.0, 0.0));
  } else {
    expect(simplifiedLine.length, lessThan(line.length));
    expect(SphericalUtil.computeLength(simplifiedLine),
        lessThan(SphericalUtil.computeLength(line)));
  }
}

List<LatLng> makeList([List<num> coords]) {
  final size = coords.length ~/ 2;

  final list = <LatLng>[];
  for (var i = 0; i < size; ++i) {
    list.add(LatLng(coords[i + i].toDouble(), coords[i + i + 1].toDouble()));
  }
  return list;
}

void onEdgeCaseWithGeodesic(
    bool geodesic, List<LatLng> poly, List<LatLng> yes, List<LatLng> no) {
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

void locationIndexCaseWithGeodesic(
    bool geodesic, List<LatLng> poly, LatLng point, int idx) {
  expect(PolygonUtil.locationIndexOnPath(point, poly, geodesic), idx);
}

void locationIndexCase(List<LatLng> poly, LatLng point, int idx) {
  locationIndexCaseWithGeodesic(true, poly, point, idx);
  locationIndexCaseWithGeodesic(false, poly, point, idx);
}

void main() {
  // The vertices of an octahedron, for testing
  final polygon = [
    LatLng(10, 10),
    LatLng(10, 20),
    LatLng(20, 20),
    LatLng(20, 10),
    LatLng(10, 10)
  ];

  const encodedPolyline =
      '_cqeFf~cjVf@p@fA}AtAoB`ArAx@hA`GbIvDiFv@gAh@t@X\\|@z@`@Z\\Xf@Vf@VpA\\tATJ@NBBkC';

  setUp(() {});

  test('containsLocation for empty polygon', () {
    expect(
        PolygonUtil.containsLocation(LatLng(1, 1), [], false), equals(false));
  });

  test('containsLocation without point', () {
    expect(PolygonUtil.containsLocation(LatLng(99, 99), polygon, true),
        equals(false));
  });

  test('containsLocation with point', () {
    expect(PolygonUtil.containsLocation(LatLng(10, 10), polygon, true),
        equals(true));

    expect(PolygonUtil.containsLocation(LatLng(15, 15), polygon, true),
        equals(true));
  });

  test('encode/decode polygon', () {
    final polygonDecoded = PolygonUtil.decode(encodedPolyline);

    expect(polygonDecoded.length, equals(21));
    expect(polygonDecoded.last.latitude, closeTo(37.76953, 1e-6));
    expect(polygonDecoded.last.longitude, closeTo(-122.41488, 1e-6));

    expect(PolygonUtil.encode(polygonDecoded), equals(encodedPolyline));
  });

  test('simplify polygon', () {
    const POLYGON_LINE =
        'elfjD~a}uNOnFN~Em@fJv@tEMhGDjDe@hG^nF??@lA?n@IvAC`Ay@A{@DwCA{CF_EC{CEi@PBTFDJBJ?V?n@?D@?A@?@?F?F?LAf@?n@@`@@T@~@FpA?fA?p@?r@?vAH`@OR@^ETFJCLD?JA^?J?P?fAC`B@d@?b@A\\@`@Ad@@\\?`@?f@?V?H?DD@DDBBDBD?D?B?B@B@@@B@B@B@D?D?JAF@H@FCLADBDBDCFAN?b@Af@@x@@';

    final line = PolygonUtil.decode(POLYGON_LINE);
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
    const POLYGON_OVAL =
        '}wgjDxw_vNuAd@}AN{A]w@_Au@kAUaA?{@Ke@@_@C]D[FULWFOLSNMTOVOXO\\I\\CX?VJXJTDTNXTVVLVJ`@FXA\\AVLZBTATBZ@ZAT?\\?VFT@XGZ';

    final oval = PolygonUtil.decode(POLYGON_OVAL);
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
    onEdgeCase(
        makeList([1, 2, 3, 5]), makeList([1, 2, 3, 5]), makeList([0, 0]));

    // On equator.
    onEdgeCase(
        makeList([0, 90, 0, 180]),
        makeList(
            [0, 90 - small, 0, 90 + small, 0 - small, 90, 0, 135, small, 135]),
        makeList([0, 90 - big, 0, 0, 0, -90, big, 135]));

    // Ends on same latitude.
    onEdgeCase(
        makeList([-45, -180, -45, -small]),
        makeList([
          -45,
          180 + small,
          -45,
          180 - small,
          -45 - small,
          180 - small,
          -45,
          0
        ]),
        makeList([-45, big, -45, 180 - big, -45 + big, -90, -45, 90]));

    // Meridian.
    onEdgeCase(
        makeList([-10, 30, 45, 30]),
        makeList([10, 30 - small, 20, 30 + small, -10 - small, 30 + small]),
        makeList([-10 - big, 30, 10, -150, 0, 30 - big]));

    // Slanted close to meridian, close to North pole.
    onEdgeCase(
        makeList([0, 0, 90 - small, 0 + big]),
        makeList([1, 0 + small, 2, 0 - small, 90 - small, -90, 90 - small, 10]),
        makeList([-big, 0, 90 - big, 180, 10, big]));

    // Arc > 120 deg.
    onEdgeCase(
        makeList([0, 0, 0, 179.999]),
        makeList([0, 90, 0, small, 0, 179, small, 90]),
        makeList([0, -90, small, -100, 0, 180, 0, -big, 90, 0, -90, 180]));

    onEdgeCase(
        makeList([10, 5, 30, 15]),
        makeList([
          10 + 2 * big,
          5 + big,
          10 + big,
          5 + big / 2,
          30 - 2 * big,
          15 - big
        ]),
        makeList([
          20,
          10,
          10 - big,
          5 - big / 2,
          30 + 2 * big,
          15 + big,
          10 + 2 * big,
          5,
          10,
          5 + big
        ]));

    onEdgeCase(
        makeList([90 - small, 0, 0, 180 - small / 2]),
        makeList(
            [big, -180 + small / 2, big, 180 - small / 4, big, 180 - small]),
        makeList([-big, -180 + small / 2, -big, 180, -big, 180 - small]));

    // Reaching close to North pole.
    onEdgeCaseWithGeodesic(
        true,
        makeList([80, 0, 80, 180 - small]),
        makeList([90 - small, -90, 90, -135, 80 - small, 0, 80 + small, 0]),
        makeList([80, 90, 79, big]));

    onEdgeCaseWithGeodesic(
        false,
        makeList([80, 0, 80, 180 - small]),
        makeList([80 - small, 0, 80 + small, 0, 80, 90]),
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
}
