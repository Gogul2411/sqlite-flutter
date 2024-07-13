import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kt_telematic/features/location/view_model/location_viewmodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  Completer<GoogleMapController> googlecontroller = Completer();
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var locationVM = Provider.of<LocationViewModel>(context, listen: true);
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (controller) {
          googlecontroller.complete(controller);
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(
              locationVM.latitude, locationVM.longitude), // Initial map center
          zoom: 7.0,
        ),
        markers: locationVM.markers,
      ),
    );
  }
}
