import 'package:flutter/material.dart';
import 'profile_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RuralMed'),
      ),
      body: _selectedIndex == 0
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Text(
                  //   'Welcome to RuralMed',
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // const SizedBox(height: 24),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildActionCard(
                          context,
                          'Book Appointment',
                          Icons.calendar_today,
                          Colors.blue,
                          () => Navigator.pushNamed(context, '/appointment'),
                        ),
                        _buildActionCard(
                          context,
                          'My Appointments',
                          Icons.event_note,
                          Colors.orange,
                          () => Navigator.pushNamed(context, '/appointments-list'),
                        ),
                        _buildActionCard(
                          context,
                          'AI Symptom Checker',
                          Icons.medical_services,
                          Colors.orange,
                          () => Navigator.pushNamed(context, '/ai-symptom-checker'),
                        ),
                        _buildActionCard(
                          context,
                          'Medicine Reminders',
                          Icons.medication,
                          Colors.purple,
                          () => Navigator.pushNamed(context, '/medicine-reminder'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const ProfileScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 