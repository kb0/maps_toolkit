class Earth {
  /// radius for using in calculation (equatorial radius)
  static num radius = 6378137.0;

  /// mean radius (R1), International Union of Geodesy and Geophysics, m.
  /// WGS-84 ellipsoid, mean radius of semi-axes (R1)
  static const num meanRadius = 6371009.0;

  /// equatorial radius, International Union of Geodesy and Geophysics, m.
  /// WGS-84 ellipsoid, semi-major axis (a)
  static const num equatorialRadius = 6378137.0;

  /// WGS-84 ellipsoid, semi-minor axis (b)
  static const double polarRadius = 6356752.3;
}