import 'package:flutter/material.dart';

class Initpage extends StatelessWidget {
  const Initpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Welcome Vivek 👋",
              style: TextStyle(fontSize: 22),
            ),

            SizedBox(height: 12),

            Text("Your Flutter app is ready 🚀"),
          ],
        ),
      ),
    );
  }
}
