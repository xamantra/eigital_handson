import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

import '../utils/index.dart';

class MapCubitState {
  final LocationData? userLocation;
  final LocationData? randomLocation;
  final bool loading;

  MapCubitState({
    this.userLocation,
    this.randomLocation,
    this.loading = false,
  });

  factory MapCubitState.init() => MapCubitState();

  MapCubitState copyWith({
    LocationData? userLocation,
    LocationData? randomLocation,
    bool? loading,
  }) {
    return MapCubitState(
      userLocation: userLocation ?? this.userLocation,
      loading: loading ?? this.loading,
    );
  }
}

class MapCubit extends Cubit<MapCubitState> {
  MapCubit() : super(MapCubitState.init());

  void initMap() async {
    emit(state.copyWith(loading: true));
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
    }

    _locationData = await location.getLocation();
    _updateUserLocation(_locationData);
    emit(state.copyWith(loading: false));

    location.onLocationChanged.listen((location) {
      _updateUserLocation(location);
    });
  }

  void _updateUserLocation(LocationData location) {
    emit(
      state.copyWith(
        userLocation: location,
      ),
    );
  }

  void newRandomLocation() {
    emit(
      state.copyWith(
        randomLocation: getRandomLocation(state.userLocation, 10 * 1000),
      ),
    );
  }
}
