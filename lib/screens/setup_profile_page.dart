import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../core/theme.dart';

class SetupProfilePage extends StatefulWidget {
  const SetupProfilePage({super.key});

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppTheme.emmaBlue; // Using your professional blue

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_circle_outlined,
                      size: 100,
                      color: primaryColor,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Identify Yourself',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pick a username to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 48),
                    CustomTextField(
                      controller: _usernameController,
                      label: 'Username',
                    ),
                  ],
                ),


                const Spacer(),

                ElevatedButton(
                  onPressed: () {
                    // for saving username.
                    Navigator.pop(context);
                  },
                  child: const Text('Complete Setup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
