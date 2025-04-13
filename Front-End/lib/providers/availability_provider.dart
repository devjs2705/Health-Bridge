import 'package:flutter/foundation.dart';
import '../models/availability.dart';

class AvailabilityProvider with ChangeNotifier {
  final List<Availability> _availabilities = [];

  List<Availability> get availabilities => _availabilities;

  void addAvailability(Availability availability) {
    _availabilities.add(availability);
    notifyListeners();
  }

  void updateAvailability(Availability oldAvailability, Availability newAvailability) {
    final index = _availabilities.indexOf(oldAvailability);
    if (index != -1) {
      _availabilities[index] = newAvailability;
      notifyListeners();
    }
  }

  void removeAvailability(Availability availability) {
    _availabilities.remove(availability);
    notifyListeners();
  }

  List<Availability> getAvailabilitiesForDate(DateTime date) {
    return _availabilities.where((a) => 
      a.date.year == date.year && 
      a.date.month == date.month && 
      a.date.day == date.day
    ).toList();
  }
} 