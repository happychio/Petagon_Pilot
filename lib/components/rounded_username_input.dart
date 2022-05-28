import 'package:flutter/material.dart';
import 'package:petagonv0_flutter/components/input_container.dart';
import 'package:petagonv0_flutter/constraints.dart';

class RoundedInput extends StatelessWidget {
  const RoundedInput(
      {Key? key,
      required this.icon,
      required this.hint,
      required this.controller})
      : super(key: key);
  final String hint;
  final IconData icon;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return InputContainer(
        child: TextField(
      keyboardType: TextInputType.emailAddress,
      controller: controller,
      cursorColor: kPrimaryColor,
      decoration: InputDecoration(
          icon: Icon(icon, color: kPrimaryColor),
          hintText: hint,
          border: InputBorder.none),
    ));
  }
}
