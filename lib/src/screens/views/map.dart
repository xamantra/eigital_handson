import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../cubits/cubits.dart';
import '../../cubits/index.dart';
import '../../utils/index.dart';

class MapScreenView extends StatefulWidget {
  const MapScreenView({Key? key}) : super(key: key);

  @override
  _MapScreenViewState createState() => _MapScreenViewState();
}

class _MapScreenViewState extends State<MapScreenView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mapCubit(context).initMap();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapCubitState>(
      bloc: mapCubit(context),
      builder: (context, snapshot) {
        final userLocation = snapshot.userLocation;
        final distance = snapshot.targetRouteDistance;
        final duration = snapshot.targetRouteDuration;
        if (snapshot.loading) {
          return Center(
            child: SizedBox(
              height: 64,
              width: 64,
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(userLocation?.latitude ?? 0, userLocation?.longitude ?? 0),
                  zoom: CAMERA_ZOOM,
                  bearing: CAMERA_BEARING,
                  tilt: CAMERA_TILT,
                ),
                myLocationEnabled: true,
                compassEnabled: true,
                tiltGesturesEnabled: false,
                markers: snapshot.markers,
                polylines: snapshot.polylines,
                mapType: MapType.normal,
                onMapCreated: (controller) {
                  mapCubit(context).activateMap(controller);
                },
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
              ),
            ),
            Column(
              children: [
                snapshot.randomPlaceName.isEmpty
                    ? SizedBox()
                    : Container(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.randomPlaceName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${distance < 1000 ? distance : (distance / 1000).toStringAsFixed(2)}${distance < 1000 ? "M" : "Km"}',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  ' - ${(duration / 60).toStringAsFixed(1)} minutes',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Text('GO TO RANDOM'),
                      onPressed: () {
                        mapCubit(context).newRandomLocation();
                      },
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      child: Text('OPEN RANDOM'),
                      onPressed: () {
                        mapCubit(context).openRandom();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
