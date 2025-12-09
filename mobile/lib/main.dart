import 'package:flutter/material.dart';
import 'package:emma_mobile/emma_secure_storage.dart';
import 'package:emma_mobile/env/env.dart';
import 'package:emma_mobile/landing_screen.dart';
import 'package:emma_mobile/map_screen.dart';
import 'package:emma_mobile/splash_screen.dart';
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
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => data.session != null
                ? const MapScreen()
                : const LandingScreen(),
          ),
          (route) => false,
        );

        return;
      } else if (event == AuthChangeEvent.signedOut) {
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LandingScreen()),
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
      theme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme
        )
      ),
      home: const SplashScreen(),
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
    );
  }
}
