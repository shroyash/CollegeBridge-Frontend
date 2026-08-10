import 'package:flutter/material.dart';

import '../../../../core/storage/secure_storage_service.dart';
import 'admin_dashboard_screen.dart';
import 'student_dashboard_screen.dart';
import 'teacher_dashboard_screen.dart';

/// Role-router screen.
/// Reads the user role from secure storage and routes to the appropriate dashboard.
class DashboardScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  const DashboardScreen({super.key, this.onLogout});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SecureStorageService _storage = SecureStorageService();
  bool _isLoading = true;
  String? _role;
  String? _name;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final role = await _storage.getUserRole();
    final name = await _storage.getUserName();
    if (mounted) {
      setState(() {
        _role = role;
        _name = name;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userName = _name ?? 'User';

    if (_role == 'ADMIN') {
      return AdminDashboardScreen(userName: userName, onLogout: widget.onLogout);
    } else if (_role == 'TEACHER') {
      return TeacherDashboardScreen(userName: userName, onLogout: widget.onLogout);
    } else {
      return StudentDashboardScreen(userName: userName, onLogout: widget.onLogout);
    }
  }
}
