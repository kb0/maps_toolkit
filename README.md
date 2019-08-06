#maps_toolkit
A library for area, distance, heading measurements.

## Getting Started

In your dart/flutter project add the dependency:

```
 dependencies:
   ...
   maps_toolkit: ^1.0.1+1
```

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

## List of functions

* `SphericalUtil.computeArea` - calculate the area of a closed path on Earth.
* `SphericalUtil.computeDistanceBetween` - calculate the distance between two points, in meters.
* `SphericalUtil.computeHeading` - calculate the heading from one point to another point.
* `SphericalUtil.computeLength` - calculate the length of the given path, in meters, on Earth.
* `SphericalUtil.computeOffset` - calculate the point resulting from moving a distance from an origin in the specified heading (expressed in degrees clockwise from north).
* `SphericalUtil.computeOffsetOrigin` - calculate the location of origin when provided with a point destination, meters travelled and original heading.
* `SphericalUtil.computeSignedArea` - calculate the signed area of a closed path on Earth.
* `SphericalUtil.interpolate` - calculate the point which lies the given fraction of the way between the origin and the destination.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/kb0/maps_toolkit/issues
