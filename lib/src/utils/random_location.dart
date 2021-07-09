import 'dart:math';

import 'package:location/location.dart';

/// NOTE: I took this code from stackoverflow: https://stackoverflow.com/a/66547986/9913914
///
/// I modified it a bit because the initial code requires additional plugin :)
LocationData? getRandomLocation(LocationData? point, int radius) {
  if (point == null) {
    return null;
  }
  //This is to generate 10 random points
  double x0 = point.latitude ?? 0;
  double y0 = point.longitude ?? 0;

  Random random = new Random();

  // Convert radius from meters to degrees
  double radiusInDegrees = radius / 111000;

  double u = random.nextDouble();
  double v = random.nextDouble();
  double w = radiusInDegrees * sqrt(u);
  double t = 2 * pi * v;
  double x = w * cos(t);
  double y = w * sin(t) * 1.75;

  // Adjust the x-coordinate for the shrinking of the east-west distances
  double newX = x / sin(y0);

  double foundLatitude = newX + x0;
  double foundLongitude = y + y0;
  LocationData randomLatLng = new LocationData.fromMap({
    "latitude": foundLatitude,
    "longitude": foundLongitude,
    "altitude": 2,
  });
  return randomLatLng;
}
