import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/faculty.dart';
import '../controllers/auth_providers.dart';
import '../controllers/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_info_card.dart';
import '../widgets/auth_text_field.dart';

/// Register Screen — matches the design:
/// • "Create Student Account" heading + subtitle
/// • Full Name, Email, Password fields
/// • Department dropdown (Faculty enum)
/// • Semester chip grid (1st–8th)
/// • "Institutional Onboarding" info card
/// • Blue "CREATE ACCOUNT →" CTA
/// • "Already have an account? Sign In" link
class RegisterScreen extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToLogin;
  final VoidCallback onRegisterSuccess;
  final VoidCallback onBack;

  const RegisterScreen({
    super.key,
    required this.onNavigateToLogin,
    required this.onRegisterSuccess,
    required this.onBack,
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Faculty? _selectedFaculty;
  int? _selectedSemester;
  bool _obscurePassword = true;

  static const _semesterLabels = [
    '1st', '2nd', '3rd', '4th',
    '5th', '6th', '7th', '8th',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFaculty == null) {
      _showError('Please select a faculty / department.');
      return;
    }
    if (_selectedSemester == null) {
      _showError('Please select a semester.');
      return;
    }

    ref.read(authNotifierProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          faculty: _selectedFaculty!,
          semester: _selectedSemester!,
        );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (_, next) {
      if (next is AuthSuccess) {
        widget.onRegisterSuccess();
      } else if (next is AuthFailure) {
        _showError(next.message);
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

                const SizedBox(height: 24),

                // ── Heading ──
                const Text(
                  'Create Student Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Join your classroom and start learning.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Full Name ──
                AuthTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  suffixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFFB0BAC8),
                    size: 20,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
                    if (v.trim().length > 100) return 'Name too long';
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ── Email ──
                AuthTextField(
                  label: 'Email Address',
                  hint: 'Enter your college email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  suffixIcon: const Icon(
                    Icons.mail_outline_rounded,
                    color: Color(0xFFB0BAC8),
                    size: 20,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ── Password ──
                AuthTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.lock_outline_rounded
                          : Icons.lock_open_rounded,
                      color: const Color(0xFFB0BAC8),
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ── Department dropdown ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DEPARTMENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<Faculty>(
                      initialValue: _selectedFaculty,
                      hint: const Text(
                        'Select Faculty / Program',
                        style: TextStyle(
                          color: Color(0xFFB0BAC8),
                          fontSize: 14,
                        ),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF2563EB), width: 2),
                        ),
                      ),
                      items: Faculty.values.map((f) {
                        return DropdownMenuItem(
                          value: f,
                          child: Text(
                            f.displayName,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedFaculty = v),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF94A3B8),
                      ),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ── Semester chip grid ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FACULTY / PROGRAM',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.4,
                      ),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        final semester = index + 1;
                        final isSelected = _selectedSemester == semester;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedSemester = semester),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _semesterLabels[index],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // ── Institutional Onboarding card ──
                AuthInfoCard(
                  icon: Icons.verified_user_outlined,
                  iconColor: const Color(0xFF2563EB),
                  iconBgColor: const Color(0xFFDBEAFE),
                  title: 'Institutional Onboarding',
                  description:
                      'By registering, you\'ll gain access to the secure College Bridge portal for automated course tracking and collaborative tools.',
                ),

                const SizedBox(height: 24),

                // ── Create Account button ──
                AuthButton(
                  label: 'CREATE ACCOUNT',
                  trailingIcon: Icons.arrow_forward_rounded,
                  isLoading: isLoading,
                  onPressed: _onRegister,
                ),

                const SizedBox(height: 20),

                // ── Sign In link ──
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onNavigateToLogin,
                        child: const Text(
                          'Sign In',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
