A library for area, distance, heading measurements.

## Usage

A simple usage example:

```dart
import 'package:maps_toolkit/maps_toolkit.dart';

main() {
  val distanceBetweenPoints = SphericalUtil.computeDistanceBetween(
    LatLng(51.5073509, -0.1277583),
    LatLng(48.856614, 2.3522219)
  );
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/kb0/maps_toolkit/issues
