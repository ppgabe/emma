import 'package:flutter/material.dart';
import 'package:emma_mobile/routes/splash_screen.dart';

class RetryConnection extends StatelessWidget {
  const RetryConnection({super.key});

  void _retry(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SplashScreen(),)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.signal_wifi_connected_no_internet_4, size: 128,),

            const Text("Unable to connect to auth service. Please try again."),

            FilledButton(onPressed: () {
              _retry(context);
            }, child: const Text("Retry"))
          ],
        ),
      ),
    );
  }
}