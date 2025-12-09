import 'package:flutter/material.dart';
import 'package:emma_mobile/login_form.dart';
import 'package:emma_mobile/register_form.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _colorBreathingAnimationController;


  @override
  void initState() {
    super.initState();

    _colorBreathingAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _colorBreathingAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _colorBreathingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.center,
      children: [
        AnimatedBuilder(
          animation: _colorBreathingAnimationController,
          builder: (context, child) {
            return Container(
              color: Color.lerp(
                Colors.deepPurple,
                Colors.redAccent,
                _colorBreathingAnimationController.value,
              ),
            );
          },
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(32, 24),
                topRight: Radius.elliptical(32, 24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: () {
                    _showLoginForm(context);
                  },
                  child: const Text("Login"),
                ),

                OutlinedButton(
                  onPressed: () {
                    _showRegisterForm(context);
                  },
                  child: const Text("Register"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLoginForm(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const LoginForm()));
  }

  void _showRegisterForm(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const RegisterForm()));
  }
}
