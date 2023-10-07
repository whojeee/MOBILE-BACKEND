class Plan {
  int? plan_id;
  int? user_id;
  String? title;
  String? plan;
  DateTime? created_at;
  DateTime? updated_at;
  String? collaborator;
  DateTime? reminder;

  Plan({
    this.plan_id,
    this.user_id,
    this.title,
    this.plan,
    this.created_at,
    this.updated_at,
    this.collaborator,
    this.reminder,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      plan_id: json['plan_id'],
      user_id: json['user_id'],
      title: json['title'],
      plan: json['plan'],
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      collaborator: json['collaborator'],
      reminder:
          json['reminder'] != null ? DateTime.parse(json['reminder']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': plan_id,
      'user_id': user_id,
      'title': title,
      'plan': plan,
      'created_at': created_at?.toIso8601String(),
      'updated_at': updated_at?.toIso8601String(),
      'collaborator': collaborator,
      'reminder': reminder?.toIso8601String(),
    };
  }
}
