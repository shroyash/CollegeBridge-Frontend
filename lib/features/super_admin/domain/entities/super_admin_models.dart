class PaginatedResponse<T> {
  final List<T> content;
  final int currentPage;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedResponse({
    required this.content,
    required this.currentPage,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    final list = json['content'] as List? ?? [];
    return PaginatedResponse<T>(
      content:
          list.map((item) => fromJsonT(item as Map<String, dynamic>)).toList(),
      currentPage: json['currentPage'] ?? json['number'] ?? 0,
      pageSize: json['pageSize'] ?? json['size'] ?? 20,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNext: json['hasNext'] ?? !(json['last'] ?? true),
      hasPrevious: json['hasPrevious'] ?? !(json['first'] ?? true),
    );
  }
}

class SuperAdminDashboardStats {
  final int totalInstitutions;
  final int pendingInstitutions;
  final int activeInstitutions;
  final int suspendedInstitutions;
  final int totalUsers;
  final int totalStudents;
  final int totalTeachers;
  final int totalAdmins;

  SuperAdminDashboardStats({
    required this.totalInstitutions,
    required this.pendingInstitutions,
    required this.activeInstitutions,
    required this.suspendedInstitutions,
    required this.totalUsers,
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalAdmins,
  });
}

class SuperAdminUser {
  final int id;
  final String name;
  final String email;
  final String? profileImage;
  final String role;
  final String status;
  final int? institutionId;
  final String? institutionName;
  final String? createdAt;

  SuperAdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.role,
    required this.status,
    this.institutionId,
    this.institutionName,
    this.createdAt,
  });

  factory SuperAdminUser.fromJson(Map<String, dynamic> json) {
    return SuperAdminUser(
      id: json['id'] ?? json['userId'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'] ?? json['imageUrl'],
      role: json['role'] ?? 'STUDENT',
      status: json['status'] ?? 'ACTIVE',
      institutionId: json['institutionId'],
      institutionName: json['institutionName'],
      createdAt: json['createdAt'],
    );
  }
}

class SuperAdminInstitution {
  final int institutionId;
  final String institutionName;
  final String? profileImage;
  final String location;
  final String? website;
  final String status;
  final int totalStudents;
  final int totalTeachers;
  final String? createdAt;

  SuperAdminInstitution({
    required this.institutionId,
    required this.institutionName,
    this.profileImage,
    required this.location,
    this.website,
    required this.status,
    required this.totalStudents,
    required this.totalTeachers,
    this.createdAt,
  });

  factory SuperAdminInstitution.fromJson(Map<String, dynamic> json) {
    return SuperAdminInstitution(
      institutionId: json['institutionId'] ?? 0,
      institutionName: json['institutionName'] ?? json['name'] ?? '',
      profileImage: json['profileImage'],
      location: json['location'] ?? 'Kathmandu',
      website: json['website'],
      status: json['status'] ?? 'ACTIVE',
      totalStudents: json['totalStudents'] ?? 0,
      totalTeachers: json['totalTeachers'] ?? 0,
      createdAt: json['createdAt'],
    );
  }
}

class SuperAdminPendingInstitution {
  final int institutionId;
  final String institutionName;
  final String? profileImage;
  final String location;
  final String? website;
  final String? contactPerson;
  final String? email;
  final String status;
  final int totalStudents;
  final int totalTeachers;
  final String? submittedAt;

  SuperAdminPendingInstitution({
    required this.institutionId,
    required this.institutionName,
    this.profileImage,
    required this.location,
    this.website,
    this.contactPerson,
    this.email,
    required this.status,
    required this.totalStudents,
    required this.totalTeachers,
    this.submittedAt,
  });

  factory SuperAdminPendingInstitution.fromJson(Map<String, dynamic> json) {
    return SuperAdminPendingInstitution(
      institutionId: json['institutionId'] ?? 0,
      institutionName: json['institutionName'] ?? json['name'] ?? '',
      profileImage: json['profileImage'],
      location: json['location'] ?? 'Kathmandu',
      website: json['website'],
      contactPerson: json['contactPerson'] ?? json['submittedByAdminName'],
      email: json['email'] ?? json['submittedByAdminEmail'],
      status: json['status'] ?? 'PENDING',
      totalStudents: json['totalStudents'] ?? 0,
      totalTeachers: json['totalTeachers'] ?? 0,
      submittedAt: json['submittedAt'] ?? json['createdAt'],
    );
  }
}
