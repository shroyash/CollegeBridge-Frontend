import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/academic_management_providers.dart';
import '../controllers/academic_management_state.dart';
import '../../domain/entities/academic_class.dart';


class AcademicManagementScreen extends ConsumerStatefulWidget {
  const AcademicManagementScreen({super.key});

  @override
  ConsumerState<AcademicManagementScreen> createState() =>
      _AcademicManagementScreenState();
}

class _AcademicManagementScreenState
    extends ConsumerState<AcademicManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(academicManagementNotifierProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(academicManagementNotifierProvider);

    ref.listen<AcademicManagementState>(
      academicManagementNotifierProvider,
      (previous, next) {
        if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
          ref.read(academicManagementNotifierProvider.notifier).clearMessages();
        }
        if (next.successMessage != null && next.successMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.successMessage!),
              backgroundColor: const Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );
          ref.read(academicManagementNotifierProvider.notifier).clearMessages();
        }
      },
    );

    // Find current configured AcademicClass for selected Faculty & Sem
    final currentAcademicClass = state.academicClasses.firstWhere(
      (c) => c.faculty == state.selectedFaculty && c.semester == state.selectedSemester,
      orElse: () => AcademicClass(
        classId: -1,
        faculty: state.selectedFaculty,
        semester: state.selectedSemester,
        displayName: '${state.selectedFaculty} ${_getOrdinal(state.selectedSemester)} Semester',
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E40AF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Academic & Subjects',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref
                  .read(academicManagementNotifierProvider.notifier)
                  .loadAcademicData();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Faculty Selection Tabs Header with "+ Add Faculty" option
          Container(
            color: const Color(0xFF1E40AF),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SELECT FACULTY',
                  style: TextStyle(
                    color: Color(0xFF93C5FD),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...state.supportedFaculties.map((fac) {
                        final isSelected = state.selectedFaculty == fac;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(fac),
                            selected: isSelected,
                            selectedColor: Colors.white,
                            backgroundColor: const Color(0xFF1D4ED8),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF1E40AF)
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                ref
                                    .read(
                                        academicManagementNotifierProvider.notifier)
                                    .selectFaculty(fac);
                              }
                            },
                          ),
                        );
                      }),
                      // Add Custom Faculty Button Chip
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: const Icon(Icons.add, size: 16, color: Colors.white),
                          label: const Text(
                            'Add Faculty',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: const Color(0xFF2563EB),
                          onPressed: () => _showAddCustomFacultyDialog(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Semester Selector Strip & Content — only show when faculties exist
          if (state.supportedFaculties.isEmpty && !state.isLoading) ...[
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school_outlined, size: 72, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 20),
                      const Text(
                        'No Faculties Configured',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add your first faculty/program to start configuring semesters and subjects.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showAddCustomFacultyDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Add First Faculty', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            // Semester Selector Strip
            if (state.selectedFaculty.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${state.selectedFaculty} SEMESTERS',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        InkWell(
                          onTap: () => _showAddClassDialog(context, state),
                          child: const Row(
                            children: [
                              Icon(Icons.add_circle_outline,
                                  size: 16, color: Color(0xFF2563EB)),
                              SizedBox(width: 4),
                              Text(
                                'Add Semester',
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(8, (index) {
                          final sem = index + 1;
                          final isSelected = state.selectedSemester == sem;
                          final isConfigured = state.academicClasses
                              .any((c) => c.faculty == state.selectedFaculty && c.semester == sem);

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              avatar: isConfigured
                                  ? Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: isSelected ? Colors.white : const Color(0xFF16A34A),
                                    )
                                  : null,
                              label: Text('Sem $sem'),
                              selected: isSelected,
                              selectedColor: const Color(0xFF2563EB),
                              backgroundColor: const Color(0xFFF1F5F9),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF334155),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  ref
                                      .read(academicManagementNotifierProvider.notifier)
                                      .selectSemester(sem);
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

          // Main Subject Directory Body
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview Card for Selected Faculty & Sem
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            currentAcademicClass.displayName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (currentAcademicClass.classId != -1)
                                          IconButton(
                                            icon: const Icon(Icons.edit_note, color: Colors.white, size: 22),
                                            tooltip: 'Edit Class Name',
                                            onPressed: () => _showEditClassDialog(context, state, currentAcademicClass),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${state.selectedFaculty} • Semester ${state.selectedSemester} (${state.subjects.length} Subjects)',
                                      style: const TextStyle(
                                        color: Color(0xFFDBEAFE),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.add, color: Colors.white, size: 28),
                                tooltip: 'Add Options',
                                onSelected: (value) {
                                  if (value == 'single') {
                                    _showAddSubjectDialog(context, state);
                                  } else if (value == 'batch') {
                                    _showBatchAddSubjectDialog(context, state);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'single',
                                    child: Row(
                                      children: [
                                        Icon(Icons.add_box, color: Color(0xFF2563EB)),
                                        SizedBox(width: 8),
                                        Text('Add Single Subject'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'batch',
                                    child: Row(
                                      children: [
                                        Icon(Icons.library_add, color: Color(0xFF16A34A)),
                                        SizedBox(width: 8),
                                        Text('Batch Add Subjects'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'CURRICULUM SUBJECTS',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '${state.subjects.length} item(s)',
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Subjects List
                        state.subjects.isEmpty
                            ? _buildEmptySubjectState(context, state)
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.subjects.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final subject = state.subjects[index];
                                  return _buildSubjectCard(context, state, subject);
                                },
                              ),
                      ],
                    ),
                  ),
          ),
          ], // end of else block
        ],
      ),
      floatingActionButton: state.supportedFaculties.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showAddSubjectDialog(context, state),
              backgroundColor: const Color(0xFF2563EB),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Subject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildEmptySubjectState(BuildContext context, AcademicManagementState state) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.menu_book_outlined,
            size: 56,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 16),
          Text(
            'No subjects added for ${state.selectedFaculty} Sem ${state.selectedSemester}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add subjects individually or batch-import the semester curriculum.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showAddSubjectDialog(context, state),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Subject'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showBatchAddSubjectDialog(context, state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                ),
                icon: const Icon(Icons.library_add, size: 18, color: Colors.white),
                label: const Text('Batch Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, AcademicManagementState state, dynamic subject) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.book_outlined,
              color: Color(0xFF2563EB),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${subject.creditHours} Credit Hrs',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${subject.faculty} - Sem ${subject.semester}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF2563EB)),
            tooltip: 'Edit Subject',
            onPressed: () => _showEditSubjectDialog(context, state, subject),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
            tooltip: 'Delete Subject',
            onPressed: () => _confirmDeleteSubject(context, subject),
          ),
        ],
      ),
    );
  }

  void _showAddCustomFacultyDialog(BuildContext context) {
    final facultyController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Custom Faculty / Program', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter program code (e.g. BIT, BE_CIVIL, BSW, BHM):',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: facultyController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g. BIT',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = facultyController.text.trim();
              if (code.isNotEmpty) {
                ref
                    .read(academicManagementNotifierProvider.notifier)
                    .addCustomFaculty(code);
                Navigator.pop(dialogCtx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            child: const Text('Add Program', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddClassDialog(BuildContext context, AcademicManagementState state) {
    int selectedSem = state.selectedSemester;
    final nameController = TextEditingController(
      text: '${state.selectedFaculty} ${_getOrdinal(selectedSem)} Semester',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add Academic Class (${state.selectedFaculty})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Semester:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: selectedSem,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: List.generate(
                  8,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('Semester ${index + 1}'),
                  ),
                ),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() {
                      selectedSem = val;
                      nameController.text =
                          '${state.selectedFaculty} ${_getOrdinal(selectedSem)} Semester';
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Display Name:'),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. BCA First Semester',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: state.isSubmitting
                  ? null
                  : () async {
                      final success = await ref
                          .read(academicManagementNotifierProvider.notifier)
                          .createAcademicClass(
                            semester: selectedSem,
                            displayName: nameController.text.trim(),
                          );
                      if (success && context.mounted) {
                        Navigator.pop(dialogCtx);
                      }
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB)),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create Class', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditClassDialog(BuildContext context, AcademicManagementState state, AcademicClass academicClass) {
    final nameController = TextEditingController(text: academicClass.displayName);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Class (${academicClass.faculty} Sem ${academicClass.semester})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Class Display Name:'),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g. BCA First Semester Section A',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: state.isSubmitting
                ? null
                : () async {
                    final newName = nameController.text.trim();
                    if (newName.isEmpty) return;

                    final success = await ref
                        .read(academicManagementNotifierProvider.notifier)
                        .updateAcademicClass(
                          classId: academicClass.classId,
                          semester: academicClass.semester,
                          displayName: newName,
                        );
                    if (success && context.mounted) {
                      Navigator.pop(dialogCtx);
                    }
                  },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            child: state.isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save Changes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context, AcademicManagementState state) {
    final nameController = TextEditingController();
    int creditHours = 3;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add Subject (${state.selectedFaculty} Sem ${state.selectedSemester})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Subject Name:'),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. Mobile Application Development',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Credit Hours:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: creditHours,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [1, 2, 3, 4, 5, 6]
                    .map((ch) => DropdownMenuItem(
                          value: ch,
                          child: Text('$ch Credit Hours'),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => creditHours = val);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: state.isSubmitting
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;

                      final success = await ref
                          .read(academicManagementNotifierProvider.notifier)
                          .createSubject(
                            name: name,
                            creditHours: creditHours,
                          );
                      if (success && context.mounted) {
                        Navigator.pop(dialogCtx);
                      }
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB)),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Add Subject', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSubjectDialog(BuildContext context, AcademicManagementState state, dynamic subject) {
    final nameController = TextEditingController(text: subject.name);
    int creditHours = subject.creditHours;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Edit Subject (${subject.faculty} Sem ${subject.semester})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Subject Name:'),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Subject Name',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Credit Hours:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: creditHours,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [1, 2, 3, 4, 5, 6]
                    .map((ch) => DropdownMenuItem(
                          value: ch,
                          child: Text('$ch Credit Hours'),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => creditHours = val);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: state.isSubmitting
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;

                      final success = await ref
                          .read(academicManagementNotifierProvider.notifier)
                          .updateSubject(
                            subjectId: subject.subjectId,
                            name: name,
                            creditHours: creditHours,
                          );
                      if (success && context.mounted) {
                        Navigator.pop(dialogCtx);
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Changes', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showBatchAddSubjectDialog(BuildContext context, AcademicManagementState state) {
    final batchTextController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Batch Add Subjects (${state.selectedFaculty} Sem ${state.selectedSemester})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter subject names separated by new lines or commas:',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: batchTextController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Mathematics I\nDigital Logic\nComputer Fundamentals\nEnglish I',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: state.isSubmitting
                ? null
                : () async {
                    final raw = batchTextController.text.trim();
                    if (raw.isEmpty) return;

                    final lines = raw
                        .split(RegExp(r'[\n,]'))
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();

                    if (lines.isEmpty) return;

                    final subjectsPayload = lines
                        .map((name) => {'name': name, 'creditHours': 3})
                        .toList();

                    final success = await ref
                        .read(academicManagementNotifierProvider.notifier)
                        .batchCreateSubjects(subjects: subjectsPayload);

                    if (success && context.mounted) {
                      Navigator.pop(dialogCtx);
                    }
                  },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A)),
            child: state.isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Batch Import', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSubject(BuildContext context, dynamic subject) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Subject', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${subject.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref
                  .read(academicManagementNotifierProvider.notifier)
                  .deleteSubject(subject.subjectId);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getOrdinal(int num) {
    const ordinals = ['', 'First', 'Second', 'Third', 'Fourth', 'Fifth', 'Sixth', 'Seventh', 'Eighth'];
    if (num > 0 && num < ordinals.length) return ordinals[num];
    return '${num}th';
  }
}
