import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/academic_admin_remote_datasource.dart';
import '../../data/repositories/academic_admin_repository_impl.dart';
import '../../domain/repositories/academic_admin_repository.dart';
import 'academic_management_notifier.dart';
import 'academic_management_state.dart';

final _apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final academicAdminRemoteDataSourceProvider =
    Provider<AcademicAdminRemoteDataSource>((ref) {
  return AcademicAdminRemoteDataSource(
    ref.watch(_apiClientProvider),
    ref.watch(secureStorageProvider),
  );
});

final academicAdminRepositoryProvider =
    Provider<AcademicAdminRepository>((ref) {
  return AcademicAdminRepositoryImpl(
    ref.watch(academicAdminRemoteDataSourceProvider),
  );
});

final academicManagementNotifierProvider = StateNotifierProvider<
    AcademicManagementNotifier, AcademicManagementState>((ref) {
  return AcademicManagementNotifier(
    ref.watch(academicAdminRepositoryProvider),
  );
});
