import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/availability_provider.dart';
import '../models/availability.dart';
import '../services/setAvailabilityService.dart';

class DoctorDashboard extends StatefulWidget {
  final int doctorId;
  const DoctorDashboard({super.key, required this.doctorId});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedIndex = 0;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildHomeTab()
          : _buildProfileTab(),
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

  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. Sarah Johnson',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Cardiologist'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildActionCard(
                  context,
                  'My Appointments',
                  Icons.calendar_today,
                  Colors.blue,
                      () => Navigator.pushNamed(context, '/appointments-list'),
                ),
                _buildActionCard(
                  context,
                  'Set Availability',
                  Icons.schedule,
                  Colors.orange,
                      () => _showAvailabilityDialog(),
                ),
                _buildActionCard(
                  context,
                  'View Availability',
                  Icons.calendar_month,
                  Colors.green,
                      () => _showAvailabilityList(),
                ),
              ],
            ),
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

  void _showAvailabilityList() async {
    try {
      final availabilityMap = await AvailabilityService.fetchDoctorAvailability(widget.doctorId);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Doctor Availability'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ListView(
              shrinkWrap: true,
              children: availabilityMap.entries.map((entry) {
                final rawDateStr = entry.key;
                final slots = List<Map<String, dynamic>>.from(entry.value);

                // Convert to DateTime
                DateTime parsedDate;
                try {
                  final parts = rawDateStr.split(' ');
                  // Example: ["Sat", "Apr", "26", "2025", "00:00:00", "GMT+0530", "(India", "Standard", "Time)"]
                  final monthMap = {
                    'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
                    'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
                  };
                  final day = int.parse(parts[2]);
                  final month = monthMap[parts[1]]!;
                  final year = int.parse(parts[3]);

                  parsedDate = DateTime(year, month, day);
                } catch (e) {
                  parsedDate = DateTime.now();
                }
                print(parsedDate);
                print(parsedDate.day);
                print(parsedDate.month);
                print(parsedDate.year);
                String formattedDate = '${parsedDate.day.toString().padLeft(2, '0')}/'
                    '${parsedDate.month.toString().padLeft(2, '0')}/'
                    '${parsedDate.year}';


                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: slots.map((slot) {
                            return Chip(
                              label: Text(slot['time_slot']),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  void _showAvailabilityDialog({Availability? existingAvailability}) {
    DateTime? tempDate = existingAvailability?.date ?? DateTime.now();
    List<String> tempTimeSlots = List.from(existingAvailability?.timeSlots ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existingAvailability == null ? 'Set Availability' : 'Edit Availability'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Date'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: CalendarDatePicker(
                    initialDate: tempDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                    onDateChanged: (date) {
                      setDialogState(() {
                        tempDate = date;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Available Time Slots'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _timeSlots.map((time) {
                    return ChoiceChip(
                      label: Text(time),
                      selected: tempTimeSlots.contains(time),
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            tempTimeSlots.add(time);
                          } else {
                            tempTimeSlots.remove(time);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: tempDate != null && tempTimeSlots.isNotEmpty
                  ? () async {
                final success = await AvailabilityService.setAvailability(
                  doctorId: widget.doctorId, // Replace with actual doctorId if available dynamically
                  availableDate: tempDate!,
                  timeSlots: tempTimeSlots,
                );

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(existingAvailability == null
                          ? 'Availability added'
                          : 'Availability updated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to set availability'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
                  : null,
              child: Text(existingAvailability == null ? 'Save' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Dr. Sarah Johnson',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Cardiologist',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSection(
            'Professional Information',
            [
              _buildInfoTile('Specialization', 'Cardiologist'),
              _buildInfoTile('Experience', '10 years'),
              _buildInfoTile('Education', 'MBBS, MD'),
              _buildInfoTile('License', 'MD123456'),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Contact Information',
            [
              _buildInfoTile('Email', 'dr.sarah@ruralmed.com'),
              _buildInfoTile('Phone', '+1 234 567 8900'),
              _buildInfoTile('Address', '123 Medical Center, City'),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Settings',
            [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Handle notification settings
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Navigate to change password
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Navigate to help & support
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
    );
  }
}