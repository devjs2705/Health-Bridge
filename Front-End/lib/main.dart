import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rural_med/services/authService.dart';
import 'screens/home_dashboard.dart';
import 'screens/appointment_booking.dart';
import 'screens/doctor_dashboard.dart';
import 'screens/teleconsultation.dart';
import 'screens/medicine_reminder.dart';
import 'screens/ai_symptom_checker.dart';
import 'screens/appointments_list.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'theme/app_theme.dart';
import 'providers/appointments_provider.dart';
import 'providers/availability_provider.dart';

Future<void> main() async {
  runApp(const RuralMedApp());
}

class RuralMedApp extends StatelessWidget {
  const RuralMedApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppointmentsProvider()),
        ChangeNotifierProvider(create: (_) => AvailabilityProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RuralMed',
        theme: AppTheme.theme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeDashboard(),
          '/doctor': (context) {
            String id = AuthService.id;

            int userId = int.tryParse(id) ?? 0; // Fallback to 1 if parse fails

            return DoctorDashboard(doctorId: userId);
          },
          '/appointment': (context) => const AppointmentBooking(),
          '/teleconsultation': (context) => const Teleconsultation(),
          '/medicine-reminder': (context) => const MedicineReminder(),
          '/ai-symptom-checker': (context) => ChatbotPage(),
          '/appointments-list': (context) {
            String role = AuthService.role;
            String id = AuthService.id;

            print(role);
            print(id);

            int userId = int.tryParse(id) ?? 0; // Fallback to 1 if parse fails

            return AppointmentsList(role: role, userId: userId);
          },
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
