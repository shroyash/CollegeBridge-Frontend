import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/dashboard_metric.dart';
import '../../domain/entities/subject.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_admin_dashboard_usecase.dart';
import '../../domain/usecases/get_my_subjects_usecase.dart';
import 'admin_dashboard_notifier.dart';
import 'dashboard_state.dart';
import 'student_dashboard_notifier.dart';

// ── Infrastructure ─────────────────────────────────────────────────────────

// Re-use core providers (assume these might be defined globally, but for modularity we declare them here or import them)
// We'll create local instances since Riverpod providers are just global variables.
final _apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final _secureStorageProvider =
    Provider<SecureStorageService>((ref) => SecureStorageService());

// ── Data Layer ─────────────────────────────────────────────────────────────

final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource(
    ref.watch(_apiClientProvider),
    ref.watch(_secureStorageProvider),
  );
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider));
});

// ── Domain — Use Cases ──────────────────────────────────────────────────────

final getAdminDashboardUseCaseProvider =
    Provider<GetAdminDashboardUseCase>((ref) {
  return GetAdminDashboardUseCase(ref.watch(dashboardRepositoryProvider));
});

final getMySubjectsUseCaseProvider = Provider<GetMySubjectsUseCase>((ref) {
  return GetMySubjectsUseCase(ref.watch(dashboardRepositoryProvider));
});

// ── Presentation — Notifier ─────────────────────────────────────────────────

final adminDashboardNotifierProvider = StateNotifierProvider<
    AdminDashboardNotifier, DashboardState<List<DashboardMetric>>>((ref) {
  return AdminDashboardNotifier(ref.watch(getAdminDashboardUseCaseProvider));
});

final studentDashboardNotifierProvider = StateNotifierProvider<
    StudentDashboardNotifier, DashboardState<List<Subject>>>((ref) {
  return StudentDashboardNotifier(ref.watch(getMySubjectsUseCaseProvider));
});
