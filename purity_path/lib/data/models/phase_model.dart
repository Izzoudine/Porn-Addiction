class ReductionPhase {
  final int phaseNumber;
  final String phaseName;
  final int weekNumber;
  final int allowedDurationMinutes;
  final int allowedFrequencyPerWeek;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCompleted;
  final String goal;

  ReductionPhase({
    required this.phaseNumber,
    required this.phaseName,
    required this.weekNumber,
    required this.allowedDurationMinutes,
    required this.allowedFrequencyPerWeek,
    required this.startDate,
    this.endDate,
    this.isCompleted = false,
    required this.goal,
  });

  Map<String, dynamic> toJson() {
    return {
      'phaseNumber': phaseNumber,
      'phaseName': phaseName,
      'weekNumber': weekNumber,
      'allowedDurationMinutes': allowedDurationMinutes,
      'allowedFrequencyPerWeek': allowedFrequencyPerWeek,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'goal': goal,
    };
  }

  factory ReductionPhase.fromJson(Map<String, dynamic> json) {
    return ReductionPhase(
      phaseNumber: json['phaseNumber'] as int,
      phaseName: json['phaseName'] as String,
      weekNumber: json['weekNumber'] as int,
      allowedDurationMinutes: json['allowedDurationMinutes'] as int,
      allowedFrequencyPerWeek: json['allowedFrequencyPerWeek'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      goal: json['goal'] as String,
    );
  }

  ReductionPhase copyWith({
    int? phaseNumber,
    String? phaseName,
    int? weekNumber,
    int? allowedDurationMinutes,
    int? allowedFrequencyPerWeek,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    String? goal,
  }) {
    return ReductionPhase(
      phaseNumber: phaseNumber ?? this.phaseNumber,
      phaseName: phaseName ?? this.phaseName,
      weekNumber: weekNumber ?? this.weekNumber,
      allowedDurationMinutes: allowedDurationMinutes ?? this.allowedDurationMinutes,
      allowedFrequencyPerWeek: allowedFrequencyPerWeek ?? this.allowedFrequencyPerWeek,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      goal: goal ?? this.goal,
    );
  }
}
