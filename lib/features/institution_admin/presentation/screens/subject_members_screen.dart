import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bridge_mobile/features/institution_admin/presentation/controllers/role_academic_providers.dart';
import 'package:bridge_mobile/features/institution_admin/data/models/class_detail_model.dart';

class SubjectMembersScreen extends ConsumerStatefulWidget {
  final String subjectName;
  final String teacherName;
  final int totalStudents;
  final bool isFromDashboard;

  const SubjectMembersScreen({
    super.key,
    required this.subjectName,
    required this.teacherName,
    this.totalStudents = 42,
    this.isFromDashboard = false,
  });

  @override
  ConsumerState<SubjectMembersScreen> createState() => _SubjectMembersScreenState();
}

class _SubjectMembersScreenState extends ConsumerState<SubjectMembersScreen> {
  @override
  Widget build(BuildContext context) {
    final classDetailAsync = ref.watch(studentClassDetailsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2563EB), size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Members',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF2563EB), size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: classDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildMembersContent(null),
        data: (ClassDetailModel? details) => _buildMembersContent(details),
      ),
    );
  }

  Widget _buildMembersContent(ClassDetailModel? details) {
    final rawTeacherName = details?.classTeacherName ?? widget.teacherName;
    final isTeacherAssigned = rawTeacherName.isNotEmpty &&
        !rawTeacherName.toLowerCase().contains('unassigned') &&
        !rawTeacherName.toLowerCase().contains('not assign') &&
        rawTeacherName != 'Class Coordinator';

    final displayTeacherName = isTeacherAssigned ? rawTeacherName : 'Teacher not assigned yet';

    final studentsList = details?.students ?? [];
    final studentsCount = details?.totalStudents ?? widget.totalStudents;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Teacher Section (Only if not viewing general dashboard members or if teacher is assigned) ──────────────────────
          Row(
            children: [
              Text(
                widget.isFromDashboard ? 'Faculty Teachers' : 'Teacher',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Teacher Card or "Teacher not assigned yet"
          if (isTeacherAssigned)
            _buildAssignedTeacherCard(displayTeacherName)
          else
            _buildUnassignedTeacherCard(),

          const SizedBox(height: 28),

          // ── 2. Students Section ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Students ($studentsCount)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Students List (No Trophies / Scores)
          if (studentsList.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: studentsList.length > 8 ? 8 : studentsList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final student = studentsList[index];
                final mockMajors = ['CS Major', 'IT Major', 'CS Major', 'Engineering', 'IT Major'];
                final major = mockMajors[index % mockMajors.length];
                final rollNo = (index + 1).toString().padLeft(2, '0');

                return _buildStudentCard(
                  name: student.fullName,
                  rollNo: rollNo,
                  major: major,
                  index: index,
                );
              },
            )
          else
            _buildFallbackStudentsList(),

          const SizedBox(height: 20),

          // View All Students Link
          Center(
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Students',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAssignedTeacherCard(String teacherName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  teacherName.isNotEmpty ? teacherName[0].toUpperCase() : 'T',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Color(0xFF2563EB),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacherName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Assistant Professor',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 14, color: Color(0xFF2563EB)),
                    const SizedBox(width: 4),
                    Text(
                      '${teacherName.toLowerCase().replaceAll(' ', '.')}@college.edu',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnassignedTeacherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.person_off_outlined,
            color: Color(0xFFD97706),
            size: 26,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teacher not assigned yet',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your institution admin will assign a faculty teacher soon.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackStudentsList() {
    final defaultStudents = [
      {'name': 'Aarav', 'roll': '01', 'major': 'CS Major'},
      {'name': 'Sita', 'roll': '04', 'major': 'IT Major'},
      {'name': 'Ram', 'roll': '12', 'major': 'CS Major'},
      {'name': 'Hari', 'roll': '15', 'major': 'Engineering'},
      {'name': 'Nabin', 'roll': '22', 'major': 'IT Major'},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: defaultStudents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = defaultStudents[index];
        return _buildStudentCard(
          name: item['name'] as String,
          rollNo: item['roll'] as String,
          major: item['major'] as String,
          index: index,
        );
      },
    );
  }

  Widget _buildStudentCard({
    required String name,
    required String rollNo,
    required String major,
    required int index,
  }) {
    final avatarColors = [
      const Color(0xFFF3E8FF), // Light Purple
      const Color(0xFFEFF6FF), // Light Blue
      const Color(0xFFF1F5F9), // Light Gray
      const Color(0xFFFEF3C7), // Light Yellow
      const Color(0xFFDCFCE7), // Light Green
    ];

    final textColors = [
      const Color(0xFF7E22CE),
      const Color(0xFF1D4ED8),
      const Color(0xFF475569),
      const Color(0xFFB45309),
      const Color(0xFF15803D),
    ];

    final bg = avatarColors[index % avatarColors.length];
    final textColor = textColors[index % textColors.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: bg,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'S',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Roll No. $rollNo  •  $major',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // "View" Student Button
          InkWell(
            onTap: () {
              _showStudentDetailsModal(context, name, rollNo, major);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentDetailsModal(BuildContext context, String name, String rollNo, String major) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Roll No. $rollNo  •  $major',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
