## 3.1.0

* Switch default earth radius from mean radius (WGS-84 ellipsoid) into equatorial radius (WGS-84 ellipsoid),
  for compatibility it's possible to setup mean radius `Earth.radius = Earth.meanRadius`

## 3.0.0

* Update Dart DSK version to 3.0.0+
* Fix PolygonUtil.decode on JavaScript (https://github.com/Dammyololade/flutter_polyline_points/issues/40#issuecomment-751765055)

## 2.0.1

* Update Dart DSK version up to 2.17.0
* Add LatLng.toString, Location.toString

## 2.0.0

* BREAKING CHANGE: This version requires Dart SDK 2.12.0 or later (null safety).

## 1.1.0+2

- fix PolygonUtils.simplify

## 1.1.0+1

- fix PolygonUtils import 

## 1.1.0

- add PolygonUtils (port from android-maps-utils) 

## 1.0.1+3

- fix issues with deps (move pedantic into dev_dependencies) 

## 1.0.1+2

- fix lint issues 

## 1.0.1+1

- Fix typos


## 1.0.1

- Documentation update


## 1.0.0

- Initial version
- Add SphericalUtil (port from android-maps-utils) 
