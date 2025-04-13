class Appointment {
  final String specialty;
  final String doctor;
  final DateTime date;
  final String time;
  final String status;

  Appointment({
    required this.specialty,
    required this.doctor,
    required this.date,
    required this.time,
    this.status = 'Upcoming',
  });

  Map<String, dynamic> toMap() {
    return {
      'specialty': specialty,
      'doctor': doctor,
      'date': date.toString().split(' ')[0],
      'time': time,
      'status': status,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      specialty: map['specialty'],
      doctor: map['doctor'],
      date: DateTime.parse(map['date']),
      time: map['time'],
      status: map['status'],
    );
  }
} 