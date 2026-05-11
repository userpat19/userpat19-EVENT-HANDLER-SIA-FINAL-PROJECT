class Event {
  final String id;
  String title;
  String location;
  String description;
  DateTime date;
  int capacity;

  Event({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.date,
    required this.capacity,
  });

  Event copyWith({
    String? title,
    String? location,
    String? description,
    DateTime? date,
    int? capacity,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      location: location ?? this.location,
      description: description ?? this.description,
      date: date ?? this.date,
      capacity: capacity ?? this.capacity,
    );
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      capacity: json['capacity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'location': location,
      'description': description,
      'date': date.toIso8601String(),
      'capacity': capacity,
    };
  }
}
