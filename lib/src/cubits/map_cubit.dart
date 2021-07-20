import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart';

import '../models/index.dart';
import '../models/routes.dart';
import '../services/index.dart';

class MapCubitState {
  final LocationData? userLocation;
  final LocationData? randomLocation;

  final Route? targetRoute;
  final NearbyPlaceItem? randomPlace;

  final GoogleMapController? controller;
  final Set<Marker> markers;
  final Set<Polyline> polylines;

  final BitmapDescriptor? sourceIcon;
  final BitmapDescriptor? destinationIcon;

  final bool loading;

  final double distanceRemaining;

  double get targetRouteDistance => targetRoute?.distance ?? 0.0;
  double get targetRouteDuration => targetRoute?.duration ?? 0.0;
  String get randomPlaceName => randomPlace?.displayName ?? '';

  MapCubitState({
    this.userLocation,
    this.controller,
    this.randomLocation,
    this.targetRoute,
    this.randomPlace,
    required this.loading,
    required this.distanceRemaining,
    this.sourceIcon,
    this.destinationIcon,
    required this.markers,
    required this.polylines,
  });

  factory MapCubitState.init() => MapCubitState(
        loading: true,
        markers: {},
        polylines: {},
        distanceRemaining: 0.0,
      );

  MapCubitState copyWith({
    LocationData? userLocation,
    LocationData? randomLocation,
    Route? targetRoute,
    NearbyPlaceItem? randomPlace,
    GoogleMapController? controller,
    bool? loading,
    double? distanceRemaining,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    BitmapDescriptor? sourceIcon,
    BitmapDescriptor? destinationIcon,
  }) {
    return MapCubitState(
      userLocation: userLocation ?? this.userLocation,
      randomLocation: randomLocation ?? this.randomLocation,
      targetRoute: targetRoute ?? this.targetRoute,
      randomPlace: randomPlace ?? this.randomPlace,
      controller: controller ?? this.controller,
      loading: loading ?? this.loading,
      distanceRemaining: distanceRemaining ?? this.distanceRemaining,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      sourceIcon: sourceIcon ?? this.sourceIcon,
      destinationIcon: destinationIcon ?? this.destinationIcon,
    );
  }
}

class MapCubit extends Cubit<MapCubitState> {
  MapCubit() : super(MapCubitState.init());

  final api = ApiService();
  final Completer<GoogleMapController> completer = Completer();
  final PolylinePoints polylinePoints = PolylinePoints();

  MapBoxNavigation? _directions;
  MapBoxNavigation get directions => _directions!;

  double get long => state.userLocation?.longitude ?? 0.0;
  double get lat => state.userLocation?.latitude ?? 0.0;

  void initMap() async {
    emit(state.copyWith(loading: true));
    Location location = new Location();
    _directions = MapBoxNavigation(onRouteEvent: onRouteEvent);

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

    emit(state.copyWith(loading: false));
  }

  void activateMap(GoogleMapController controller) {
    if (completer.isCompleted) return;
    completer.complete(controller);
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

  Future<void> newRandomLocation() async {
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
    emit(state.copyWith(loading: false, randomPlace: random));
  }

  Future<NearbyPlaceItem> getRandomPlace() async {
    final places = await api.getNearbyPlaces(10, long, lat); // 10 KM radius.
    return (places.data..shuffle()).first; // pick random
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

  List<LatLng> getCoordinates(RoutesResponse response) {
    if (response.routes.isEmpty) {
      return [];
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
    return polylineCoordinates;
  }

  Future<void> setPolylines() async {
    final response = await api.getRoutes(state.userLocation, state.randomLocation);
    var polylineCoordinates = getCoordinates(response);
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

    emit(state.copyWith(polylines: polylines, targetRoute: response.routes[0]));
  }

  MapBoxOptions mapBoxOptions() {
    return MapBoxOptions(
      initialLatitude: lat,
      initialLongitude: long,
      zoom: 13.0,
      tilt: 0.0,
      bearing: 0.0,
      enableRefresh: false,
      alternatives: true,
      voiceInstructionsEnabled: true,
      bannerInstructionsEnabled: true,
      allowsUTurnAtWayPoints: true,
      mode: MapBoxNavigationMode.drivingWithTraffic,
      // mapStyleUrlDay: "https://url_to_day_style",
      // mapStyleUrlNight: "https://url_to_night_style",
      units: VoiceUnits.imperial,
      simulateRoute: true,
      language: "en",
    );
  }

  Future<void> onRouteEvent(e) async {
    final distanceRemaining = await directions.distanceRemaining;
    // _durationRemaining = await _directions.durationRemaining;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        // var progressEvent = e.data as RouteProgressEvent;
        // _arrived = progressEvent.arrived;
        // if (progressEvent.currentStepInstruction != null) _instruction = progressEvent.currentStepInstruction;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        // _routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        // _routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        // _isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        // _arrived = true;
        // if (!_isMultipleStop) {
        //   await Future.delayed(Duration(seconds: 3));
        //   await _controller.finishNavigation();
        // } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        // _routeBuilt = false;
        // _isNavigating = false;
        break;
      default:
        break;
    }
    //refresh UI
    emit(state.copyWith(distanceRemaining: distanceRemaining));
  }

  Future<List<WayPoint>> getWayPoints() async {
    final response = await api.getRoutes(state.userLocation, state.randomLocation);
    var polylineCoordinates = getCoordinates(response);
    return polylineCoordinates
        .map(
          (e) => WayPoint(name: '${e.latitude}', latitude: e.latitude, longitude: e.longitude),
        )
        .toList();
  }
}
