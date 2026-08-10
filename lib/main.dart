import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/new_password_screen.dart';
import 'features/auth/presentation/screens/otp_verification_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';

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

  // Passed between forgot-password flow steps
  String _fpEmail = '';
  String _fpVerificationToken = '';

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
            onForgotPassword: () => _go(_Screen.forgotPassword),
            onLoginSuccess: () {
              _go(_Screen.dashboard);
            },
          ),
        _Screen.register => RegisterScreen(
            key: const ValueKey('register'),
            onBack: () => _go(_Screen.login),
            onNavigateToLogin: () => _go(_Screen.login),
            onRegisterSuccess: () {
              _go(_Screen.dashboard);
            },
          ),
        _Screen.forgotPassword => ForgotPasswordScreen(
            key: const ValueKey('forgotPassword'),
            onBack: () => _go(_Screen.login),
            onOtpSent: (email) {
              setState(() {
                _fpEmail = email;
                _current = _Screen.otpVerification;
              });
            },
          ),
        _Screen.otpVerification => OtpVerificationScreen(
            key: const ValueKey('otpVerification'),
            email: _fpEmail,
            onBack: () => _go(_Screen.forgotPassword),
            onOtpVerified: (email, verificationToken) {
              setState(() {
                _fpEmail = email;
                _fpVerificationToken = verificationToken;
                _current = _Screen.newPassword;
              });
            },
          ),
        _Screen.newPassword => NewPasswordScreen(
            key: const ValueKey('newPassword'),
            email: _fpEmail,
            verificationToken: _fpVerificationToken,
            onBack: () => _go(_Screen.otpVerification),
            onPasswordReset: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Password updated successfully!'),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
              _go(_Screen.login);
            },
          ),
        _Screen.dashboard => DashboardScreen(
            key: const ValueKey('dashboard'),
            onLogout: () => _go(_Screen.login),
          ),
      },
    );
  }
}

enum _Screen {
  splash,
  login,
  register,
  forgotPassword,
  otpVerification,
  newPassword,
  dashboard,
}
