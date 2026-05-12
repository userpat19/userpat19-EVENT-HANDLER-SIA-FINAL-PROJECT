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
      title: json['title'] ?? json['eventTitle'] ?? '',
      location: json['location'] ?? json['eventLocation'] ?? '',
      description: json['description'] ?? json['eventDescription'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : json['eventDate'] != null
              ? DateTime.parse(json['eventDate'])
              : DateTime.now(),
      capacity: json['capacity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'eventTitle': title,
      'location': location,
      'eventLocation': location,
      'description': description,
      'eventDescription': description,
      'date': date.toIso8601String(),
      'eventDate': date.toIso8601String(),
      'capacity': capacity,
    };
  }
}
