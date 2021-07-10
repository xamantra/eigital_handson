import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:webfeed/webfeed.dart';

import '../models/index.dart';
import '../models/routes.dart';

class ApiService {
  final apiKey = 'pk.bd6c1133d93ecc68cd9fa8b565a5e504';

  /// Fetches 50 nearby places within N Kilometer radius.
  Future<NearbyPlacesResponse> getNearbyPlaces(
    int kilometerRadius,
    double long,
    double lat,
  ) async {
    try {
      var url = Uri.parse('https://us1.locationiq.com/v1/nearby.php?key=$apiKey&lat=$lat&lon=$long&radius=${kilometerRadius * 1000}&limit=50');
      var response = await http.get(url);
      return NearbyPlacesResponse.fromRawJson(response.body);
    } catch (e, trace) {
      print(trace);
      return NearbyPlacesResponse(data: []);
    }
  }

  /// Get route data between two points. The geometry of the route will be decoded as polyline data.
  Future<RoutesResponse> getRoutes(LocationData? from, LocationData? to) async {
    try {
      var url = Uri.parse('https://us1.locationiq.com/v1/directions/driving/${from?.longitude},${from?.latitude};${to?.longitude},${to?.latitude}?key=$apiKey');
      var response = await http.get(url);
      return RoutesResponse.fromRawJson(response.body);
    } catch (e, trace) {
      print(trace);
      return RoutesResponse(code: '', routes: [], waypoints: []);
    }
  }

  /// Fetches rss feed from BBC News
  Future<RssFeed> getRss() async {
    var url = Uri.parse('http://feeds.bbci.co.uk/news/world/rss.xml');
    var response = await http.get(url);
    return RssFeed.parse(response.body);
  }
}
