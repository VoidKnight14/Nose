class UserProfile {
  String name;
  String grade;
  bool isConfigured;

  UserProfile({
    required this.name,
    required this.grade,
    this.isConfigured = false,
  });

  UserProfile copyWith({
    String? name,
    String? grade,
    bool? isConfigured,
  }) {
    return UserProfile(
      name: name ?? this.name,
      grade: grade ?? this.grade,
      isConfigured: isConfigured ?? this.isConfigured,
    );
  }
}
