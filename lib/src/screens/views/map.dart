import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../cubits/cubits.dart';
import '../../cubits/index.dart';

class MapScreenView extends StatelessWidget {
  const MapScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapCubitState>(
      bloc: mapCubit(context),
      builder: (context, snapshot) {
        final userLocation = snapshot.userLocation;
        return Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(userLocation?.latitude ?? 0, userLocation?.longitude ?? 0),
                  zoom: 14.4746,
                ),
                
              ),
            ),
            ElevatedButton(
              child: Text('GO TO RANDOM'),
              onPressed: () {
                mapCubit(context).newRandomLocation();
              },
            ),
          ],
        );
      },
    );
  }
}
