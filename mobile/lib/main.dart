import 'package:emma_mobile/routes/auth_page.dart';
import 'package:emma_mobile/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:emma_mobile/routes/emma_secure_storage.dart';
import 'package:emma_mobile/env/env.dart';
import 'package:emma_mobile/routes/map_screen.dart';
import 'package:emma_mobile/routes/setup_profile_page.dart';
import 'package:emma_mobile/routes/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseProjectUrl,
    anonKey: Env.supabasePublishableKey,
    authOptions: FlutterAuthClientOptions(localStorage: EmmaSecureStorage()),
  );

  runApp(const EmmaApp());
}

class EmmaApp extends StatefulWidget {
  const EmmaApp({super.key});

  @override
  State<StatefulWidget> createState() => _EmmaAppState();
}

class _EmmaAppState extends State<EmmaApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      debugPrint("Auth Event: $event");

      if (event == AuthChangeEvent.initialSession) {
        Widget destination;
        if (data.session != null) {
          final username = data.session!.user.userMetadata?['username'];
          if (username == null || username.toString().isEmpty) {
            destination = const SetupProfilePage();
          } else {
            destination = const MapScreen();
          }
        } else {
          destination = const AuthPage();
        }

        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => destination),
          (route) => false,
        );

        return;
      } else if (event == AuthChangeEvent.signedOut) {
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthPage()),
          (route) => false,
        );

        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EMMA',
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.light().textTheme
        )
      ),
      home: const SplashScreen(),
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
    );
  }
}
