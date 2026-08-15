import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/auth/domain/entities/auth_user.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/new_password_screen.dart';
import 'features/auth/presentation/screens/otp_verification_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/institution_admin/domain/entities/institution_entities.dart';
import 'features/institution_admin/presentation/screens/institution_registration_screen.dart';
import 'features/institution_admin/presentation/screens/managed_institutions_screen.dart';
import 'features/institution_admin/presentation/screens/pending_institutions_screen.dart';
import 'features/institution_admin/presentation/screens/registration_submitted_screen.dart';
import 'features/super_admin/presentation/screens/super_admin_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

class _AppNavigator extends StatefulWidget {
  const _AppNavigator();

  @override
  State<_AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<_AppNavigator> {
  _Screen _current = _Screen.splash;

  // Forgot-password flow state
  String _fpEmail = '';
  String _fpVerificationToken = '';

  // Registration submitted result
  InstitutionRegistrationResult? _registrationResult;

  // Role of the logged-in user (for routing to correct dashboard)
  String _userRole = '';

  void _go(_Screen screen) => setState(() => _current = screen);

  void _onLoginSuccess(AuthUser user) {
    _userRole = user.role;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
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
            onLoginSuccessWithUser: _onLoginSuccess,
            onLoginSuccess: () {
              // Route to role-specific home
              if (_userRole == 'SUPER_ADMIN') {
                _go(_Screen.superAdminDashboard);
              } else {
                _go(_Screen.dashboard);
              }
            },
            onNavigateToInstitutionRegister: () =>
                _go(_Screen.institutionRegister),
          ),
        _Screen.register => RegisterScreen(
            key: const ValueKey('register'),
            onBack: () => _go(_Screen.login),
            onNavigateToLogin: () => _go(_Screen.login),
            onRegisterSuccess: () => _go(_Screen.dashboard),
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
            onOtpVerified: (email, token) {
              setState(() {
                _fpEmail = email;
                _fpVerificationToken = token;
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('✅ Password updated successfully!'),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ));
              _go(_Screen.login);
            },
          ),
        _Screen.dashboard => DashboardScreen(
            key: const ValueKey('dashboard'),
            onLogout: () => _go(_Screen.login),
          ),
        _Screen.institutionRegister => InstitutionRegistrationScreen(
            key: const ValueKey('institutionRegister'),
            onBack: () => _go(_Screen.login),
            onSuccess: (result) {
              setState(() {
                _registrationResult = result;
                _current = _Screen.registrationSubmitted;
              });
            },
          ),
        _Screen.registrationSubmitted => RegistrationSubmittedScreen(
            key: const ValueKey('registrationSubmitted'),
            result: _registrationResult!,
            onGoToLogin: () => _go(_Screen.login),
          ),
        _Screen.superAdminDashboard => const SuperAdminShell(
            key: ValueKey('superAdminDashboard'),
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
  institutionRegister,
  registrationSubmitted,
  superAdminDashboard,
}

// ── Super Admin shell with bottom navigation ──────────────────────────────────

class _SuperAdminHome extends StatefulWidget {
  final VoidCallback onLogout;

  const _SuperAdminHome({super.key, required this.onLogout});

  @override
  State<_SuperAdminHome> createState() => _SuperAdminHomeState();
}

class _SuperAdminHomeState extends State<_SuperAdminHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [
          PendingInstitutionsScreen(),
          ManagedInstitutionsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFEFF6FF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.pending_actions_outlined),
            selectedIcon: Icon(Icons.pending_actions_rounded,
                color: Color(0xFF2563EB)),
            label: 'Pending',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon:
                Icon(Icons.business_rounded, color: Color(0xFF2563EB)),
            label: 'Institutions',
          ),
        ],
      ),
    );
  }
}
