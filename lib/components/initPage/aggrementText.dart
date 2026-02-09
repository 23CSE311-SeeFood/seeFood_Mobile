import 'package:flutter/material.dart';

class aggrementText extends StatelessWidget {
  const aggrementText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "By clicking “Get Started,” you agree to our Terms and Conditions.",
      style: TextStyle(
        color: Color.fromARGB(204, 255, 255, 255),
        fontSize: 12,
        fontWeight: FontWeight.w400,
      )
    );
  }
}