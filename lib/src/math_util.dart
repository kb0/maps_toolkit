import 'dart:math';

class MathUtil {
  static num toRadians(num degrees) => degrees / 180.0 * pi;

  static num toDegrees(num rad) => rad * (180.0 / pi);

  /// Restrict x to the range [low, high].
  static num clamp(num x, num low, num high) {
    return x < low ? low : (x > high ? high : x);
  }

  /// Wraps the given value into the inclusive-exclusive interval between min and max.
  /// @param n   The value to wrap.
  /// @param min The minimum.
  /// @param max The maximum.
  static num wrap(num n, num min, num max) {
    return (n >= min && n < max) ? n : (mod(n - min, max - min) + min);
  }

  /// Returns the non-negative remainder of x / m.
  /// @param x The operand.
  /// @param m The modulus.
  static num mod(num x, num m) {
    return ((x % m) + m) % m;
  }

  /// Returns mercator Y corresponding to latitude.
  /// See http://en.wikipedia.org/wiki/Mercator_projection .
  static num mercator(num lat) {
    return log(tan(lat * 0.5 + pi / 4));
  }

  /// Returns latitude from mercator Y.
  static num inverseMercator(num y) {
    return 2 * atan(exp(y)) - pi / 2;
  }

  /// Returns haversine(angle-in-radians).
  /// hav(x) == (1 - cos(x)) / 2 == sin(x / 2)^2.
  static num hav(num x) {
    num sinHalf = sin(x * 0.5);
    return sinHalf * sinHalf;
  }

  /// Computes inverse haversine. Has good numerical stability around 0.
  /// arcHav(x) == acos(1 - 2 * x) == 2 * asin(sqrt(x)).
  /// The argument must be in [0, 1], and the result is positive.
  static num arcHav(num x) {
    return 2 * asin(sqrt(x));
  }

  // Given h==hav(x), returns sin(abs(x)).
  static num sinFromHav(num h) {
    return 2 * sqrt(h * (1 - h));
  }

  // Returns hav(asin(x)).
  static num havFromSin(num x) {
    num x2 = x * x;
    return x2 / (1 + sqrt(1 - x2)) * .5;
  }

  // Returns sin(arcHav(x) + arcHav(y)).
  static num sinSumFromHav(num x, num y) {
    num a = sqrt(x * (1 - x));
    num b = sqrt(y * (1 - y));
    return 2 * (a + b - 2 * (a * y + b * x));
  }

  /// Returns hav() of distance from (lat1, lng1) to (lat2, lng2) on the unit sphere.
  static num havDistance(num lat1, num lat2, num dLng) {
    return hav(lat1 - lat2) + hav(dLng) * cos(lat1) * cos(lat2);
  }
}
