import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_providers.dart';
import '../controllers/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_info_card.dart';
import '../widgets/auth_text_field.dart';


class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToRegister;
  final VoidCallback onLoginSuccess;
  final VoidCallback onBack;

  const LoginScreen({
    super.key,
    required this.onNavigateToRegister,
    required this.onLoginSuccess,
    required this.onBack,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authNotifierProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for state changes and react
    ref.listen<AuthState>(authNotifierProvider, (_, next) {
      if (next is AuthSuccess) {
        widget.onLoginSuccess();
      } else if (next is AuthFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        ref.read(authNotifierProvider.notifier).reset();
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Back button ──
                GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Heading ──
                const Text(
                  'Welcome Back 👋',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Login to your account',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Email field ──
                AuthTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ── Password field ──
                AuthTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                ),

                // ── Forgot password ──
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 0),
                    ),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Login button ──
                AuthButton(
                  label: 'LOGIN',
                  isLoading: isLoading,
                  onPressed: _onLogin,
                ),

                const SizedBox(height: 24),

                // ── OR divider ──
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Sign Up link ──
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onNavigateToRegister,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Quick Insight card ──
                AuthInfoCard(
                  icon: Icons.flash_on_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  iconBgColor: const Color(0xFFFEF3C7),
                  title: 'Quick Insight',
                  description:
                      'Last login from a MacBook Pro in New York. If this wasn\'t you, reset your password immediately.',
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
