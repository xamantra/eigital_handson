import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
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
  // final Set<Marker> markers;
  // final Set<Polyline> polylines;

  // final BitmapDescriptor? sourceIcon;
  // final BitmapDescriptor? destinationIcon;

  final bool loading;
  final bool initialized;

  MapCubitState({
    this.userLocation,
    this.controller,
    this.randomLocation,
    this.loading = false,
    this.initialized = false,
    // this.sourceIcon,
    // this.destinationIcon,
    // this.markers = const {},
    // this.polylines = const {},
  });

  factory MapCubitState.init() => MapCubitState();

  MapCubitState copyWith({
    LocationData? userLocation,
    LocationData? randomLocation,
    GoogleMapController? controller,
    bool? loading,
    bool? initialized,
    // Set<Marker>? markers,
    // Set<Polyline>? polylines,
    // BitmapDescriptor? sourceIcon,
    // BitmapDescriptor? destinationIcon,
  }) {
    return MapCubitState(
      userLocation: userLocation ?? this.userLocation,
      randomLocation: randomLocation ?? this.randomLocation,
      controller: controller ?? this.controller,
      loading: loading ?? this.loading,
      initialized: initialized ?? this.initialized,
      // markers: markers ?? this.markers,
      // polylines: polylines ?? this.polylines,
      // sourceIcon: sourceIcon ?? this.sourceIcon,
      // destinationIcon: destinationIcon ?? this.destinationIcon,
    );
  }
}

class MapCubit extends Cubit<MapCubitState> {
  MapCubit() : super(MapCubitState.init());

  final Completer<GoogleMapController> completer = Completer();
  // final PolylinePoints polylinePoints = PolylinePoints();
  // final String googleAPIKey = 'AIzaSyBZD9yjdNSjbZRCrBrh_Zou3DCQjyR5RH4';

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
    emit(state.copyWith(loading: false));

    location.onLocationChanged.listen((location) {
      _updateUserLocation(location);
    });

    updateCamera();
  }

  void activateMap(GoogleMapController controller) {
    completer.complete(controller);
  }

  void updateCamera() {
    if (state.controller != null) {
      if (state.randomLocation != null) {
        state.controller?.moveCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(state.userLocation?.latitude ?? 0, state.userLocation?.longitude ?? 0),
              southwest: LatLng(state.randomLocation?.latitude ?? 0, state.randomLocation?.longitude ?? 0),
            ),
            4,
          ),
        );
      } else {
        state.controller?.moveCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(state.userLocation?.latitude ?? 0, state.userLocation?.longitude ?? 0),
            20,
          ),
        );
      }
    }
  }

  // Future<void> initMarkers() async {
  //   emit(
  //     state.copyWith(
  //       sourceIcon: await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png'),
  //       destinationIcon: await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/destination_map_marker.png'),
  //     ),
  //   );
  // }

  void _updateUserLocation(LocationData location) {
    emit(
      state.copyWith(
        userLocation: location,
      ),
    );
  }

  // void newRandomLocation() async {
  //   final random = await getRandomPlace();
  //   emit(
  //     state.copyWith(
  //       randomLocation: LocationData.fromMap({
  //         'latitude': random.latitude,
  //         'longitude': random.longitude,
  //       }),
  //     ),
  //   );
  //   // setMapPins();
  //   // setPolylines();
  //   updateCamera();
  // }

  Future<NearbyPlaceItem> getRandomPlace() async {
    final places = await getNearbyPlaces(10);
    return (places.data..shuffle()).first;
  }

  Future<NearbyPlacesResponse> getNearbyPlaces(int kilometerRadius) async {
    try {
      var url = Uri.parse('https://us1.locationiq.com/v1/nearby.php?key=pk.bd6c1133d93ecc68cd9fa8b565a5e504&lat=7.091095&lon=125.607328&radius=${kilometerRadius * 1000}&limit=50');
      var response = await http.get(url);
      return NearbyPlacesResponse.fromRawJson(response.body);
    } catch (e, trace) {
      print(trace);
      return NearbyPlacesResponse(data: []);
    }
  }

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
        origin: Coords(
          state.userLocation?.latitude ?? 0,
          state.userLocation?.longitude ?? 0,
        ),
        destination: Coords(
          random.latitude,
          random.longitude,
        ),
      );
    }
    emit(state.copyWith(loading: false));
  }

  // void setMapPins() {
  //   Set<Marker> markers = {};
  //   markers.add(
  //     Marker(
  //       markerId: MarkerId('My location'),
  //       position: LatLng(
  //         state.userLocation?.latitude ?? 0,
  //         state.userLocation?.longitude ?? 0,
  //       ),
  //       icon: state.sourceIcon!,
  //     ),
  //   );
  //   markers.add(
  //     Marker(
  //       markerId: MarkerId('Random Location'),
  //       position: LatLng(
  //         state.randomLocation?.latitude ?? 0,
  //         state.randomLocation?.longitude ?? 0,
  //       ),
  //       icon: state.destinationIcon!,
  //     ),
  //   );
  //   emit(state.copyWith(markers: markers));
  // }

  // setPolylines() async {
  //   final result = await polylinePoints.getRouteBetweenCoordinates(
  //     googleAPIKey,
  //     PointLatLng(
  //       state.userLocation?.latitude ?? 0,
  //       state.userLocation?.longitude ?? 0,
  //     ),
  //     PointLatLng(
  //       state.randomLocation?.latitude ?? 0,
  //       state.randomLocation?.longitude ?? 0,
  //     ),
  //     travelMode: TravelMode.walking,
  //   );
  //   final points = result.points;
  //   var polylineCoordinates = <LatLng>[];
  //   if (points.isNotEmpty) {
  //     // loop through all PointLatLng points and convert them
  //     // to a list of LatLng, required by the Polyline
  //     points.forEach((PointLatLng point) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     });
  //   }
  //   // create a Polyline instance
  //   // with an id, an RGB color and the list of LatLng pairs
  //   Polyline polyline = Polyline(
  //     polylineId: PolylineId('poly'),
  //     color: Color.fromARGB(255, 40, 122, 198),
  //     points: polylineCoordinates,
  //   );

  //   // add the constructed polyline as a set of points
  //   // to the polyline set, which will eventually
  //   // end up showing up on the map
  //   var polylines = <Polyline>{};
  //   polylines.add(polyline);

  //   emit(state.copyWith(polylines: polylines));
  // }
}
