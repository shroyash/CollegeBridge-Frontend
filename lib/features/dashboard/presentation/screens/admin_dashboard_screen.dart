import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/dashboard_providers.dart';
import '../controllers/dashboard_state.dart';
import '../../domain/entities/dashboard_metric.dart';
import '../widgets/metric_card.dart';
import '../widgets/quick_action_tile.dart';

import '../../../admin_users/presentation/screens/manage_users_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  final String userName;
  final VoidCallback? onLogout;
  const AdminDashboardScreen({super.key, required this.userName, this.onLogout});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch metrics on mount
    Future.microtask(() {
      ref.read(adminDashboardNotifierProvider.notifier).fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminDashboardNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF1E40AF), // Dark blue header
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.userName} • Administrator',
                        style: TextStyle(
                          color: Colors.blue[100],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: state is DashboardLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state is DashboardFailure
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text((state as DashboardFailure<List<DashboardMetric>>).message),
                              TextButton(
                                onPressed: () {
                                  ref.read(adminDashboardNotifierProvider.notifier).fetchDashboard();
                                },
                                child: const Text('Retry'),
                              )
                            ],
                          ),
                        )
                      : state is DashboardSuccess<List<DashboardMetric>>
                          ? RefreshIndicator(
                              onRefresh: () => ref.read(adminDashboardNotifierProvider.notifier).fetchDashboard(),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Metrics Grid
                                    _buildMetricsGrid(state.data),
                                    const SizedBox(height: 32),
                                    
                                    // Quick Actions
                                    const Text(
                                      'QUICK ACTIONS',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    QuickActionTile(
                                      title: 'Broadcast Message',
                                      icon: Icons.campaign_outlined,
                                      iconColor: const Color(0xFF2563EB),
                                      iconBackgroundColor: const Color(0xFFDBEAFE),
                                      onTap: () {},
                                    ),
                                    QuickActionTile(
                                      title: 'Holiday Approval',
                                      icon: Icons.event_busy_outlined,
                                      iconColor: const Color(0xFFDC2626),
                                      iconBackgroundColor: const Color(0xFFFEE2E2),
                                      badgeCount: 1,
                                      onTap: () {},
                                    ),
                                    QuickActionTile(
                                      title: 'Manage Users',
                                      icon: Icons.people_outline,
                                      iconColor: const Color(0xFF2563EB),
                                      iconBackgroundColor: const Color(0xFFDBEAFE),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const ManageUsersScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    QuickActionTile(
                                      title: 'Manage Classes',
                                      icon: Icons.class_outlined,
                                      iconColor: const Color(0xFF9333EA),
                                      iconBackgroundColor: const Color(0xFFF3E8FF),
                                      onTap: () {},
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Insights
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: const [
                                              Icon(Icons.auto_awesome, color: Color(0xFF9333EA), size: 18),
                                              SizedBox(width: 8),
                                              Text(
                                                'ADMIN INSIGHTS',
                                                style: TextStyle(
                                                  color: Color(0xFF9333EA),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Student attendance is up by 4% this week. Consider broadcasting the upcoming exam schedule for the BCA department.',
                                            style: TextStyle(
                                              color: Color(0xFF475569),
                                              fontSize: 14,
                                              height: 1.5,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox(),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF64748B),
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageUsersScreen(),
              ),
            );
          } else if (index == 3) {
            _confirmLogout(context);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), label: 'Broadcast'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(List<dynamic> metrics) {
    // Helper to find metric by key
    int getValue(String key) {
      try {
        return metrics.firstWhere((m) => m.key == key).value;
      } catch (e) {
        return 0;
      }
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2, // wide cards
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        MetricCard(
          title: 'Students',
          value: getValue('students'),
          icon: Icons.people_alt,
          iconColor: const Color(0xFF3B82F6),
          iconBackgroundColor: const Color(0xFFEFF6FF),
          subtitle: 'Students',
        ),
        MetricCard(
          title: 'Classes',
          value: getValue('classes'),
          icon: Icons.class_,
          iconColor: const Color(0xFF3B82F6),
          iconBackgroundColor: const Color(0xFFEFF6FF),
          subtitle: 'Classes',
        ),
        MetricCard(
          title: 'Teachers',
          value: getValue('teachers'),
          icon: Icons.school,
          iconColor: const Color(0xFF8B5CF6),
          iconBackgroundColor: const Color(0xFFF5F3FF),
          subtitle: 'Teachers',
        ),
        const MetricCard(
          title: 'Delivery',
          value: 98,
          icon: Icons.verified,
          iconColor: Color(0xFFEF4444),
          iconBackgroundColor: Color(0xFFFEF2F2),
          subtitle: 'Delivery', // static mock metric as per design
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(profileNotifierProvider.notifier)
                  .logoutAndClear();
              if (widget.onLogout != null) {
                widget.onLogout!();
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
