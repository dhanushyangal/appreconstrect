import 'package:flutter/material.dart';
import 'vision_board_page.dart';
import '/Annual Planner/annual_planner_page.dart';

class PlannersPage extends StatelessWidget {
  const PlannersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planners'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.dashboard_customize),
            title: const Text('Vision Board Templates'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VisionBoardPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('2024 Annual Planner'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnnualPlannerPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_week),
            title: const Text('2024 Weekly Planner'),
            onTap: () {
              _showComingSoonDialog(context); // Navigate to Coming Soon
            },
          ),
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('2024 Daily To Do List'),
            onTap: () {
              _showComingSoonDialog(context); // Navigate to Coming Soon
            },
          ),
        ],
      ),
    );
  }

  // Function to show Coming Soon dialog
  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Coming Soon'),
          content: const Text('This feature is coming soon!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
