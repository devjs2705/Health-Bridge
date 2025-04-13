class Availability {
  final DateTime date;
  final List<String> timeSlots;
  final bool isAvailable;

  Availability({
    required this.date,
    required this.timeSlots,
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'timeSlots': timeSlots,
      'isAvailable': isAvailable,
    };
  }

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      date: DateTime.parse(json['date']),
      timeSlots: List<String>.from(json['timeSlots']),
      isAvailable: json['isAvailable'] ?? true,
    );
  }
} 