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
}
