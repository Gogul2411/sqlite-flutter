import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kt_telematic/features/authentication/model/users.dart';
import 'package:kt_telematic/database/sqlite/database_helper.dart';
import 'package:kt_telematic/features/location/view_model/location_viewmodel.dart';
import 'package:kt_telematic/features/location/views/google_map_view.dart';
import 'package:provider/provider.dart';

class LocationList extends StatefulWidget {
  final Users? profile;

  const LocationList({super.key, this.profile});

  @override
  // ignore: library_private_types_in_public_api
  _LocationListState createState() => _LocationListState();
}

class _LocationListState extends State<LocationList> {
  final db = DatabaseHelper();
  late LocationViewModel locationVM;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    locationVM = Provider.of<LocationViewModel>(context, listen: false);
    initialFunction(); // Call initialFunction here

    // Set up a timer to update the location every 15 minutes
    Timer.periodic(
      const Duration(minutes: 15),
      (timer) {
        locationVM.getCurrentLocation(widget.profile?.usrId ?? 0);
      },
    );
  }

  Future<void> initialFunction() async {
    try {
      await locationVM.getCurrentLocation(widget.profile?.usrId ?? 0);
      await Future.delayed(
        Duration.zero,
        () {
          locationVM.userLocations =
              DatabaseHelper().getUserLocations(widget.profile?.usrId ?? 0);
        },
      );
    } catch (error) {
      // ignore: avoid_print
      print('Error: $error');
      // Handle errors as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Locations'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Consumer<LocationViewModel>(
          builder: (context, locationViewModel, child) {
            if (locationViewModel.userLocations == null) {
              // Loading state
              return const CircularProgressIndicator();
            } else {
              // Access the list from the Future
              Future<List<Map<String, dynamic>>> userLocationsFuture =
                  locationViewModel.userLocations!;

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: userLocationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Empty state
                    return const Center(
                        child: Text('No user locations available.'));
                  } else {
                    // Display the user locations
                    List<Map<String, dynamic>> userLocations = snapshot.data!;

                    return Stack(
                      children: [
                        ListView.builder(
                          itemCount: userLocations.length,
                          itemBuilder: (context, index) {
                            final location = userLocations[index];
                            return ListTile(
                              title: Text('Latitude: ${location['latitude']}'),
                              subtitle:
                                  Text('Longitude: ${location['longitude']}'),
                              // You can add more details or customize the UI as needed
                            );
                          },
                        ),
                        Positioned(
                          bottom: 100,
                          right:
                              20, // Adjust the position based on your requirements
                          child: SizedBox(
                            height: 60,
                            width: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.only(right: 0),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Button border radius
                                ),
                              ),
                              onPressed: () {
                                _showFormAlertDialog(
                                    context, locationViewModel);
                              },
                              child: const Icon(
                                Icons.add,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          right:
                              20, // Adjust the position based on your requirements
                          child: SizedBox(
                            height: 60,
                            width: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.only(right: 0),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Button border radius
                                ),
                              ),
                              onPressed: () async {
                                await locationVM.updateMarkers(userLocations);
                                // ignore: use_build_context_synchronously
                                await Navigator.push<void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        const GoogleMapView(),
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.play_arrow,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  void _showFormAlertDialog(
      BuildContext context, LocationViewModel locationViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController latitudeController = TextEditingController();
        TextEditingController longitudeController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Latlong Form'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: latitudeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter latitude';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: longitudeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter longitude';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    // Validate the form
                    if (_formKey.currentState!.validate()) {
                      // Process latitude and longitude, e.g., save to database
                      double latitude =
                          double.tryParse(latitudeController.text) ?? 0.0;
                      double longitude =
                          double.tryParse(longitudeController.text) ?? 0.0;

                      // Add your latitude and longitude
                      await locationViewModel.addManualLocation(
                          widget.profile?.usrId ?? 0, latitude, longitude);

                      await locationViewModel
                          .fetchUserLocations(widget.profile?.usrId ?? 0);

                      // ignore: avoid_print
                      print('Latitude: $latitude, Longitude: $longitude');

                      // Close the dialog
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
