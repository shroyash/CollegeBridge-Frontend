import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(const ProviderScope(child: BridgeApp()));
}

class BridgeApp extends StatelessWidget {
  const BridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Bridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const _AppNavigator(),
    );
  }
}

/// Simple imperative navigator to switch between auth screens.
/// Replace with go_router once home screen is added.
class _AppNavigator extends StatefulWidget {
  const _AppNavigator();

  @override
  State<_AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<_AppNavigator> {
  _Screen _current = _Screen.splash;

  void _go(_Screen screen) => setState(() => _current = screen);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: switch (_current) {
        _Screen.splash => SplashScreen(
            key: const ValueKey('splash'),
            onComplete: () => _go(_Screen.login),
          ),
        _Screen.login => LoginScreen(
            key: const ValueKey('login'),
            onBack: () => _go(_Screen.splash),
            onNavigateToRegister: () => _go(_Screen.register),
            onLoginSuccess: () {
              // TODO: Navigate to home screen after login
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Login successful!'),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
        _Screen.register => RegisterScreen(
            key: const ValueKey('register'),
            onBack: () => _go(_Screen.login),
            onNavigateToLogin: () => _go(_Screen.login),
            onRegisterSuccess: () {
              // TODO: Navigate to home screen after registration
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Account created successfully!'),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
      },
    );
  }
}

enum _Screen { splash, login, register }
