import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../widgets/custom_textfield.dart';
import '../core/theme.dart';
import 'setup_profile_page.dart' hide State;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog() {
    final TextEditingController _resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Reset Password",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your email to receive a reset link."),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _resetEmailController,
              label: "Email Address",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
            onPressed: () {
              // Local Placeholder instead of Supabase
              debugPrint("Reset email sent to: ${_resetEmailController.text}");
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Reset link sent! (Simulation)")),
              );
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppTheme.emmaBlue;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.shield, size: 100, color: primaryColor),
                        Icon(
                          Icons.monitor_heart,
                          size: 50,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'EMMA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'Emergency Monitoring Management Application',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),

                  Text(
                    isLogin ? 'Log In' : 'Sign Up',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLogin
                        ? 'Log in to continue'
                        : 'Create an account to continue',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  CustomTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),

                  if (isLogin)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              activeColor: primaryColor,
                              onChanged: (v) =>
                                  setState(() => _rememberMe = v!),
                            ),
                            const Text("Remember me"),
                          ],
                        ),
                        TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      if (isLogin) {
                        debugPrint("Attempting Login...");
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SetupProfilePage(),
                          ),
                        );
                      }
                    },
                    child: Text(isLogin ? 'Sign In' : 'Continue'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: RichText(
                      text: TextSpan(
                        text: isLogin
                            ? "Don't have an account? "
                            : "Already have an account? ",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Montserrat',
                        ),
                        children: [
                          TextSpan(
                            text: isLogin ? 'Sign Up' : 'Log In',
                            style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
