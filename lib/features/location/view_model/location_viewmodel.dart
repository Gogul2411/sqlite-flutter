import 'package:flutter/material.dart';
import 'package:kt_telematic/database/sqlite/database_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationViewModel extends ChangeNotifier {
  Set<Marker> markers = {};
  double latitude = 0.0;
  double longitude = 0.0;
  // ignore: avoid_init_to_null
  Future<List<Map<String, dynamic>>>? userLocations =
      null; // Initialize to null

  Future addManualLocation(
      int userId, double latitude, double longitude) async {
    await DatabaseHelper().storeLocationInDatabase(
        userId, latitude, longitude, DateTime.now().millisecondsSinceEpoch);
    notifyListeners();
  }

  Future<void> fetchUserLocations(int userId) async {
    // Fetch user locations from the database
    userLocations = DatabaseHelper().getUserLocations(userId);

    // Notify listeners about the changes
    notifyListeners();
  }

  Future getCurrentLocation(int userId) async {
    LocationPermission permission = await Geolocator.requestPermission();
    try {
      if (permission == LocationPermission.denied) {
        // Handle denied permission
      } else if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        // Store the location in the local database
        await DatabaseHelper().storeLocationInDatabase(
            userId,
            position.latitude,
            position.longitude,
            DateTime.now().millisecondsSinceEpoch);
        notifyListeners();
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error: $e");
    }
  }

  Future<void> updateMarkers(List<Map<String, dynamic>> userLocations) async {
    // Clear existing markers
    markers.clear();

    // Add new markers based on user locations
    for (var location in userLocations) {
      final id = location['id']?.toString() ?? '';
      final latitude = location['latitude'] as double?;
      final longitude = location['longitude'] as double?;

      if (id.isNotEmpty && latitude != null && longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(id),
            position: LatLng(latitude, longitude),
            infoWindow: const InfoWindow(
              title: 'Location',
              snippet: 'Details here',
            ),
          ),
        );
      }
    }

    notifyListeners();
    // Return a completed Future
    return Future.value();
  }
}
