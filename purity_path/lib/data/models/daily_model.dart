class DailyContent {
  final String id;
  final String contentType; // "Dua", "Hadith", or "Motivation"
  final String name;
  final String primaryContent; // Arabic for duas, Hadith text for hadiths, Title for motivations
  final String secondaryContent; // Translation for duas, Report for hadiths, Description for motivations
  final String tertiaryContent; // Content for duas/hadiths, "Tap to read more" for motivations
  
  DailyContent({
    required this.id,
    required this.contentType,
    required this.name,
    required this.primaryContent,
    required this.secondaryContent,
    required this.tertiaryContent,
  });
  
  // Convert to the a,b,c,d,e format you need
  Map<String, String> toPreferenceFormat() {
    return {
      'a': name,
      'b': primaryContent,
      'c': secondaryContent,
      'd': tertiaryContent,
      'e': contentType,
    };
  }
  
  // Create from Firebase data
  factory DailyContent.fromFirebase(String id, Map<String, dynamic> data, String type) {
    switch (type) {
      case 'duas':
        return DailyContent(
          id: id,
          contentType: "Dua",
          name: data['Name'] ?? '',
          primaryContent: data['Arabic'] ?? '',
          secondaryContent: data['Translation'] ?? '',
          tertiaryContent: data['Content'] ?? '',
        );
      case 'hadiths':
        return DailyContent(
          id: id,
          contentType: "Hadith",
          name: data['Name'] ?? '',
          primaryContent: data['Hadith'] ?? '',
          secondaryContent: data['Report'] ?? '',
          tertiaryContent: data['Content'] ?? '',
        );
      case 'motivations':
        return DailyContent(
          id: id,
          contentType: "Motivation",
          name: data['Name'] ?? '',
          primaryContent: data['Title'] ?? '',
          secondaryContent: data['Description'] ?? '',
          tertiaryContent: "Tap to read more",
        );
      default:
        throw ArgumentError('Unknown content type: $type');
    }
  }
  
  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentType': contentType,
      'name': name,
      'primaryContent': primaryContent,
      'secondaryContent': secondaryContent,
      'tertiaryContent': tertiaryContent,
    };
  }
  
  factory DailyContent.fromJson(Map<String, dynamic> json) {
    return DailyContent(
      id: json['id'],
      contentType: json['contentType'],
      name: json['name'],
      primaryContent: json['primaryContent'],
      secondaryContent: json['secondaryContent'],
      tertiaryContent: json['tertiaryContent'],
    );
  }
}