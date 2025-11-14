class ReductionPhase {
  final int phaseNumber;
  final String phaseType; // 'duration', 'frequency', 'spacing'
  final int weekNumber;
  final int? durationLimit; // in minutes per session
  final int? frequencyLimit; // times per week
  final String? spacingLimit; // 'weekly', 'biweekly', 'monthly'
  final String description;
  final DateTime startDate;
  final DateTime? completedDate;
  final bool isCompleted;

  ReductionPhase({
    required this.phaseNumber,
    required this.phaseType,
    required this.weekNumber,
    this.durationLimit,
    this.frequencyLimit,
    this.spacingLimit,
    required this.description,
    required this.startDate,
    this.completedDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'phaseNumber': phaseNumber,
      'phaseType': phaseType,
      'weekNumber': weekNumber,
      'durationLimit': durationLimit,
      'frequencyLimit': frequencyLimit,
      'spacingLimit': spacingLimit,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory ReductionPhase.fromJson(Map<String, dynamic> json) {
    return ReductionPhase(
      phaseNumber: json['phaseNumber'],
      phaseType: json['phaseType'],
      weekNumber: json['weekNumber'],
      durationLimit: json['durationLimit'],
      frequencyLimit: json['frequencyLimit'],
      spacingLimit: json['spacingLimit'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      completedDate:
          json['completedDate'] != null
              ? DateTime.parse(json['completedDate'])
              : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  ReductionPhase copyWith({
    int? phaseNumber,
    String? phaseType,
    int? weekNumber,
    int? durationLimit,
    int? frequencyLimit,
    String? spacingLimit,
    String? description,
    DateTime? startDate,
    DateTime? completedDate,
    bool? isCompleted,
  }) {
    return ReductionPhase(
      phaseNumber: phaseNumber ?? this.phaseNumber,
      phaseType: phaseType ?? this.phaseType,
      weekNumber: weekNumber ?? this.weekNumber,
      durationLimit: durationLimit ?? this.durationLimit,
      frequencyLimit: frequencyLimit ?? this.frequencyLimit,
      spacingLimit: spacingLimit ?? this.spacingLimit,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      completedDate: completedDate ?? this.completedDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
