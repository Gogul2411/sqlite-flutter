import 'package:flutter/material.dart';

class AddLatLongForm extends StatefulWidget {
  const AddLatLongForm({super.key});

  @override
  State<AddLatLongForm> createState() => _AddLatLongFormState();
}

class _AddLatLongFormState extends State<AddLatLongForm> {
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
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
              onPressed: () {
                // Validate the form
                if (_formKey.currentState!.validate()) {
                  // Process latitude and longitude, e.g., save to database
                  double latitude =
                      double.tryParse(latitudeController.text) ?? 0.0;
                  double longitude =
                      double.tryParse(longitudeController.text) ?? 0.0;

                  // Add your latitude and longitude
                  // Provider.of<LocationViewModel>(context, listen: false).addManualLocation(
                  //     widget.profile?.usrId ?? 0, latitude, longitude);

                  // ignore: avoid_print
                  print('Latitude: $latitude, Longitude: $longitude');

                  // Close the dialog
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
