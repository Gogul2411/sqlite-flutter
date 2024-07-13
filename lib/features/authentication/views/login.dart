import 'package:flutter/material.dart';
import 'package:kt_telematic/core/button.dart';
import 'package:kt_telematic/core/colors.dart';
import 'package:kt_telematic/core/textfield.dart';
import 'package:kt_telematic/features/authentication/model/users.dart';
import 'package:kt_telematic/database/sqlite/database_helper.dart';
import 'package:kt_telematic/features/authentication/views/signup.dart';
import 'package:kt_telematic/features/location/views/location_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Our controllers
  //Controller is used to take the value from the user and pass it to the database
  final usrName = TextEditingController();
  final password = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  bool isChecked = false;
  bool isLoginTrue = false;

  final db = DatabaseHelper();

  @override
  void dispose() {
    // Dispose of the FocusNodes when the widget is disposed
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  //Login Method
  //We will take the value of text fields using controllers to verify whether details are correct or not
  login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Users? usrDetails = await db.getUser(usrName.text);
    var res = await db
        .authenticate(Users(usrName: usrName.text, password: password.text));

    if (res == true) {
      // If result is correct then go to profile or home
      prefs.setBool('isLoggedIn', true);
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return LocationList(profile: usrDetails);
          },
        ),
        (_) => false,
      );
    } else {
      // Otherwise show the error message
      setState(() {
        isLoginTrue = true;
      });
    }
  }

  // Close the keyboard
  void _closeKeyboard() {
    _usernameFocus.unfocus();
    _passwordFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "LOGIN",
                      style: TextStyle(color: primaryColor, fontSize: 40),
                    ),
                    Image.asset("assets/background.jpg"),
                    InputField(
                      hint: "Username",
                      icon: Icons.account_circle,
                      controller: usrName,
                      focusNode: _usernameFocus,
                      checkValidator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                    InputField(
                      hint: "Password",
                      icon: Icons.lock,
                      controller: password,
                      passwordInvisible: true,
                      focusNode: _passwordFocus,
                      checkValidator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    // Our login button
                    Button(
                      label: "LOGIN",
                      press: () {
                        _closeKeyboard();
                        if (_formKey.currentState!.validate()) {
                          login();
                          // Close the keyboard after pressing the login button
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                            // Close the keyboard when navigating to the signup screen
                            _closeKeyboard();
                          },
                          child: const Text("SIGN UP"),
                        ),
                      ],
                    ),
                    // Access denied message in case when your username and password are incorrect
                    // By default we must hide it
                    // When login is not true then display the message
                    isLoginTrue
                        ? Text(
                            "Username or password is incorrect",
                            style: TextStyle(color: Colors.red.shade900),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
