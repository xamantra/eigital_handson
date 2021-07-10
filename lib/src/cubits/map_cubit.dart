import 'dart:async';

import 'package:eigital_handson/src/models/routes.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart';

import '../models/index.dart';

class MapCubitState {
  final LocationData? userLocation;
  final LocationData? randomLocation;

  final GoogleMapController? controller;
  final Set<Marker> markers;
  final Set<Polyline> polylines;

  final BitmapDescriptor? sourceIcon;
  final BitmapDescriptor? destinationIcon;

  final bool loading;
  final bool initialized;

  MapCubitState({
    this.userLocation,
    this.controller,
    this.randomLocation,
    required this.loading,
    this.initialized = false,
    this.sourceIcon,
    this.destinationIcon,
    this.markers = const {},
    this.polylines = const {},
  });

  factory MapCubitState.init() => MapCubitState(loading: true);

  MapCubitState copyWith({
    LocationData? userLocation,
    LocationData? randomLocation,
    GoogleMapController? controller,
    bool? loading,
    bool? initialized,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    BitmapDescriptor? sourceIcon,
    BitmapDescriptor? destinationIcon,
  }) {
    return MapCubitState(
      userLocation: userLocation ?? this.userLocation,
      randomLocation: randomLocation ?? this.randomLocation,
      controller: controller ?? this.controller,
      loading: loading ?? this.loading,
      initialized: initialized ?? this.initialized,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      sourceIcon: sourceIcon ?? this.sourceIcon,
      destinationIcon: destinationIcon ?? this.destinationIcon,
    );
  }
}

class MapCubit extends Cubit<MapCubitState> {
  MapCubit() : super(MapCubitState.init());

  final Completer<GoogleMapController> completer = Completer();
  final PolylinePoints polylinePoints = PolylinePoints();

  double get long => state.userLocation?.longitude ?? 0.0;
  double get lat => state.userLocation?.latitude ?? 0.0;

  void initMap() async {
    if (state.initialized) {
      return;
    }
    emit(state.copyWith(loading: true, initialized: true));
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    } else {
      await location.requestPermission();
    }

    _locationData = await location.getLocation();
    _updateUserLocation(_locationData);

    location.onLocationChanged.listen((location) {
      _updateUserLocation(location);
    });

    await updateCamera();
    emit(state.copyWith(loading: false));
  }

  void activateMap(GoogleMapController controller) {
    completer.complete(controller);
  }

  Future<void> updateCamera() async {
    if (state.controller != null) {
      if (state.randomLocation != null) {
        await state.controller?.moveCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(lat, long),
              southwest: LatLng(state.randomLocation?.latitude ?? 0, state.randomLocation?.longitude ?? 0),
            ),
            4,
          ),
        );
      } else {
        await state.controller?.moveCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, long), 20),
        );
      }
    }
  }

  Future<void> initMarkers() async {
    emit(
      state.copyWith(
        sourceIcon: await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png'),
        destinationIcon: await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/destination_map_marker.png'),
      ),
    );
  }

  void _updateUserLocation(LocationData location) {
    emit(
      state.copyWith(
        userLocation: location,
      ),
    );
  }

  void newRandomLocation() async {
    emit(state.copyWith(loading: true));
    final random = await getRandomPlace();
    emit(
      state.copyWith(
        randomLocation: LocationData.fromMap({
          'latitude': random.latitude,
          'longitude': random.longitude,
        }),
      ),
    );
    setMapPins();
    await setPolylines();
    emit(state.copyWith(loading: false));
    await updateCamera();
  }

  Future<NearbyPlaceItem> getRandomPlace() async {
    final places = await getNearbyPlaces(10, long, lat); // 10 KM radius.
    return (places.data..shuffle()).first; // pick random
  }

  /// Fetches 50 nearby places within N Kilometer radius.
  Future<NearbyPlacesResponse> getNearbyPlaces(
    int kilometerRadius,
    double long,
    double lat,
  ) async {
    try {
      var url = Uri.parse('https://us1.locationiq.com/v1/nearby.php?key=pk.bd6c1133d93ecc68cd9fa8b565a5e504&lat=$lat&lon=$long&radius=${kilometerRadius * 1000}&limit=50');
      var response = await http.get(url);
      return NearbyPlacesResponse.fromRawJson(response.body);
    } catch (e, trace) {
      print(trace);
      return NearbyPlacesResponse(data: []);
    }
  }

  Future<RoutesResponse> getRoutes(LocationData? from, LocationData? to) async {
    try {
      var url = Uri.parse('https://us1.locationiq.com/v1/directions/driving/${from?.longitude},${from?.latitude};${to?.longitude},${to?.latitude}?key=pk.bd6c1133d93ecc68cd9fa8b565a5e504');
      var response = await http.get(url);
      return RoutesResponse.fromRawJson(response.body);
    } catch (e, trace) {
      print(trace);
      return RoutesResponse(code: '', routes: [], waypoints: []);
    }
  }

  /// After picking a random place, launch the map app with routes for navigation.
  Future<void> openRandom() async {
    emit(state.copyWith(loading: true));
    final availableMaps = await MapLauncher.installedMaps;
    if (availableMaps.isNotEmpty) {
      final random = await getRandomPlace();
      final googleFilter = (AvailableMap x) => x.mapName.toLowerCase().contains('google');
      final hasGoogleMap = availableMaps.any(googleFilter);

      AvailableMap? map;
      if (hasGoogleMap) {
        map = availableMaps.firstWhere(googleFilter);
      } else {
        map = availableMaps.first;
      }
      await map.showDirections(
        origin: Coords(lat, long),
        destination: Coords(
          random.latitude,
          random.longitude,
        ),
      );
    }
    emit(state.copyWith(loading: false));
  }

  void setMapPins() {
    Set<Marker> markers = {};
    markers.add(
      Marker(
        markerId: MarkerId('My location'),
        position: LatLng(lat, long),
        icon: state.sourceIcon!,
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('Random Location'),
        position: LatLng(
          state.randomLocation?.latitude ?? 0,
          state.randomLocation?.longitude ?? 0,
        ),
        icon: state.destinationIcon!,
      ),
    );
    emit(state.copyWith(markers: markers));
  }

  Future<void> setPolylines() async {
    final response = await getRoutes(state.userLocation, state.randomLocation);
    if (response.routes.isEmpty) {
      return;
    }
    final result = polylinePoints.decodePolyline(response.routes[0].geometry);
    var polylineCoordinates = <LatLng>[];
    if (result.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    // create a Polyline instance
    // with an id, an RGB color and the list of LatLng pairs
    Polyline polyline = Polyline(
      polylineId: PolylineId('poly'),
      color: Color.fromARGB(255, 40, 122, 198),
      points: polylineCoordinates,
    );

    // add the constructed polyline as a set of points
    // to the polyline set, which will eventually
    // end up showing up on the map
    var polylines = <Polyline>{};
    polylines.add(polyline);

    emit(state.copyWith(polylines: polylines));
  }
}
