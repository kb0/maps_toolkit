library maps_toolkit.test.all_test;

import 'package:test/test.dart';

import 'maps_toolkit_test.dart' as maps_toolkit_test;
import 'polygon_util_test.dart' as polygon_util_test;

void main() {
  group('tests for spherical utils', maps_toolkit_test.main);
  group('tests for polygons', polygon_util_test.main);
}
