import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kt_telematic/database/sqlite/database_helper.dart';
import 'package:kt_telematic/features/authentication/views/login.dart';
import 'package:kt_telematic/features/authentication/views/splash_screen.dart';
import 'package:kt_telematic/features/location/view_model/location_viewmodel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().initDB();
  await requestLocationPermission();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LocationViewModel>(
          lazy: true,
          create: (context) => LocationViewModel(),
          child: const Splash(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// Function to request location permission
Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
  } else if (permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse) {}
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
