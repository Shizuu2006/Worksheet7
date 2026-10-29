class Course {
  final int? id;
  final String code;
  final String title;
  final int credits;
  final String status;
  final String description;

  const Course({
    this.id,
    required this.code,
    required this.title,
    required this.credits,
    this.status = 'planned',
    this.description = '',
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int?,
      code: json['code'] as String,
      title: json['title'] as String,
      credits: json['credits'] as int,
      status: (json['status'] as String?) ?? 'planned',
      description: (json['description'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'title': title,
    'credits': credits,
    'status': status,
    'description': description,
  };
}
