import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:maps_toolkit/src/polygon_util.dart';
import 'package:test/test.dart';

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
}
