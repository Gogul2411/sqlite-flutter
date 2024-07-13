import 'package:flutter/material.dart';
import 'package:kt_telematic/core/button.dart';
import 'package:kt_telematic/core/colors.dart';
import 'package:kt_telematic/core/textfield.dart';
import 'package:kt_telematic/features/authentication/model/users.dart';
import 'package:kt_telematic/database/sqlite/database_helper.dart';
import 'package:kt_telematic/features/authentication/views/login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  //Controllers
  final fullName = TextEditingController();
  final email = TextEditingController();
  final usrName = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final db = DatabaseHelper();
  signUp() async {
    var res = await db.createUser(Users(
        fullName: fullName.text,
        email: email.text,
        usrName: usrName.text,
        password: password.text));
    if (res > 0) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Register New Account",
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InputField(
                      hint: "Full name",
                      icon: Icons.person,
                      controller: fullName,
                      checkValidator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    ),
                    InputField(
                      hint: "Email",
                      icon: Icons.email,
                      controller: email,
                      checkValidator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@') ||
                            !value.contains('.')) {
                          return 'Please enter valid mai';
                        }
                        return null;
                      },
                    ),
                    InputField(
                      hint: "Username",
                      icon: Icons.account_circle,
                      controller: usrName,
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
                      checkValidator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Button(
                        label: "SIGN UP",
                        press: () {
                          if (_formKey.currentState!.validate()) {
                            signUp();
                          }
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text("LOGIN"),
                        )
                      ],
                    )
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
