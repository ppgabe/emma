import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              const FlutterLogo(size: 192,),

              Center(child: const Text("Register")),

              TextField(
                controller: _emailController,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  label: const Text("Email"),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),

              TextField(
                controller: _passwordController,
                autocorrect: false,
                autofillHints: const [AutofillHints.password],
                obscureText: true,
                decoration: InputDecoration(
                    label: const Text("Password"),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24))
                ),
              ),

              FilledButton(onPressed: () {_register();}, child: const Text("Register"))
            ],
          ),
        ),
      ),
    );
  }
}