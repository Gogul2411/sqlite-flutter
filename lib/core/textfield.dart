import 'package:flutter/material.dart';

// ignore: must_be_immutable
class InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool passwordInvisible;
  String? Function(String?)? checkValidator;
  final TextEditingController controller;
  final FocusNode? focusNode; // Include focusNode in the parameters

  InputField({
    Key? key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.passwordInvisible = false,
    required this.checkValidator,
    this.focusNode, // Update here
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return TextFormField(
      validator: checkValidator,
      obscureText: passwordInvisible,
      controller: controller,
      focusNode: focusNode, // Pass the focusNode to TextFormField
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 22.0, horizontal: 22.0),
        hintText: hint,
      ),
    );
  }
}
