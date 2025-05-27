
class DailyContent {
  final String id;
  final String contentType; // "Dua", "Hadith", or "Motivation"
  final String name;
  final String content;
  final String specific;
  final String description;

  DailyContent({
    required this.id,
    required this.contentType,
    required this.name,
    required this.content,
    required this.specific,
    required this.description,
  });

  Map<String, String> toPreferenceFormat() {
    return {
      'name': name,
      'content': content,
      'specific': specific,
      'description': description,
      'contentType': contentType,
    };
  }

  factory DailyContent.fromFirebase(String id, Map<String, dynamic> data, String type) {
    return DailyContent(
      id: id,
      contentType: type == 'duas' ? 'Dua' : type == 'hadiths' ? 'Hadith' : 'Motivation',
      name: data['Name'] ?? '',
      content: data['Content'] ?? '',
      specific: data['Specific'] ?? '',
      description: data['Description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentType': contentType,
      'name': name,
      'content': content,
      'specific': specific,
      'description': description,
    };
  }

  factory DailyContent.fromJson(Map<String, dynamic> json) {
    return DailyContent(
      id: json['id'],
      contentType: json['contentType'],
      name: json['name'],
      content: json['content'],
      specific: json['specific'],
      description: json['description'],
    );
  }
}