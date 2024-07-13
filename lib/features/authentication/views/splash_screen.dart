import 'package:flutter/material.dart';
import 'package:kt_telematic/features/authentication/views/login.dart';
import 'package:kt_telematic/features/location/views/location_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigatetohome();
    getPref();
  }

  _navigatetohome() async {
    await Future.delayed(const Duration(milliseconds: 3000), () {});
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _loginStatus ? const LocationList() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Image.network(
              'https://img.freepik.com/premium-vector/welcome-text_689076-127.jpg',
              width: 200.0,
              height: 200.0,
            ),
          ),
        ),
      ),
    );
  }

  // ignore: prefer_typing_uninitialized_variables
  var _loginStatus;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(
      () {
        _loginStatus = preferences.getBool('isLoggedIn') ?? false;
      },
    );
  }
}
