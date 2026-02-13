import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/challenge_screen.dart';
import 'screens/run_screen.dart';
import 'screens/tokens_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const RunEarnApp());
}

class RunEarnApp extends StatelessWidget {
  const RunEarnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RunEarn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        primaryColor: const Color(0xFFFF6B00),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.light().textTheme,
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFF6B00),
          secondary: Color(0xFF2E86DE),
          surface: Colors.white,
          error: Color(0xFFEF4444),
        ),
        useMaterial3: true,
      ),
      home: const SplashGate(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/run': (_) => const RunScreen(),
        '/challenge': (_) => const ChallengeScreen(),
        '/tokens': (_) => const TokensScreen(),
      },
    );
  }
}

/// Checks for an existing session and routes accordingly.
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final session = prefs.getString('session');

    if (!mounted) return;

    if (session != null && session.isNotEmpty) {
      // Verify session validity
      final user = await ApiService.getMe();
      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
        return;
      }
      // Invalid session
      await ApiService.clearSession();
    }
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF00C9FF)),
      ),
    );
  }
}
