import 'package:flutter/material.dart';
import 'animal_theme_annual_planner.dart';
import 'summer_theme_annual_planner.dart';
import 'spaniel_theme_annual_planner.dart';
import 'happy_couple_theme_annual_planner.dart';

class AnnualPlannerPage extends StatelessWidget {
  const AnnualPlannerPage({super.key});

  Widget _buildTemplateCard(
      BuildContext context, String imagePath, String title) {
    return GestureDetector(
      onTap: () {
        if (title == 'Animal theme 2025 Calendar') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnimalThemeCalendarApp(),
            ),
          );
        } else if (title == 'Summer theme 2025 Calendar') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SummerThemeCalendarApp(),
            ),
          );
        } else if (title == 'Spanish theme 2025 Calendar') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SpanielThemeCalendarApp(),
            ),
          );
        } else if (title == 'Happy Couple theme 2025 Calendar') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HappyCoupleThemeCalendarApp(),
            ),
          );
        }
        // Add more conditions for other titles if needed
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annual Planner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Annual Planner Templates for 2025',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Colorcode dates and create your own custom 2025 calendar online for FREE. Choose from stunning templates to track the months. You can also color-code dates for specific events like personal, finance, medical, work etc. Edit and download in just a few steps.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                children: [
                  _buildTemplateCard(
                      context,
                      'assets/vision-board-ruled-theme.png',
                      'Animal theme 2025 Calendar'),
                  _buildTemplateCard(
                      context,
                      'assets/Post-it Theme-Vision-Board.png',
                      'Summer theme 2025 Calendar'),
                  _buildTemplateCard(context, 'assets/premium-theme.png',
                      'Spanish theme 2025 Calendar'),
                  _buildTemplateCard(
                      context,
                      'assets/winter-warmth-theme-vision-board.png',
                      'Happy Couple theme 2025 Calendar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
