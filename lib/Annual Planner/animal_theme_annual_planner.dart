import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';

class AnimalThemeCalendarApp extends StatefulWidget {
  const AnimalThemeCalendarApp({super.key});

  @override
  State<AnimalThemeCalendarApp> createState() => _AnimalThemeCalendarAppState();
}

class _AnimalThemeCalendarAppState extends State<AnimalThemeCalendarApp> {
  final screenshotController = ScreenshotController();
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  final Map<int, int> daysInMonth2025 = {
    1: 31,
    2: 28,
    3: 31,
    4: 30,
    5: 31,
    6: 30,
    7: 31,
    8: 31,
    9: 30,
    10: 31,
    11: 30,
    12: 31
  };

  Map<String, Map<int, int>> selectedDates = {};
  int currentColorIndex = 0;

  final List<Color> colorOptions = [
    const Color(0xFFff6f61), // Color 1
    const Color(0xFFfddb3a), // Color 2
    const Color(0xFF1b998b), // Color 3
    const Color(0xFF8360c3), // Color 4
  ];

  @override
  void initState() {
    super.initState();
    for (var month in months) {
      selectedDates[month] = {};
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedDates();
    });
  }

  Future<void> _saveDates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> dataToSave = {};

      for (var month in selectedDates.keys) {
        if (selectedDates[month]!.isNotEmpty) {
          List<String> entries = [];
          selectedDates[month]!.forEach((day, colorIndex) {
            entries.add('$day:$colorIndex');
          });
          dataToSave[month] = entries.join(',');
        }
      }

      final String jsonData = dataToSave.toString();
      await prefs.setString('animal_calendar_theme_2025', jsonData);

      // Update the widget
      await HomeWidget.saveWidgetData('animal_calendar_theme_2025', jsonData);
      await HomeWidget.updateWidget(
        name: 'CalendarThemeWidget',
        iOSName: 'CalendarThemeWidget',
        qualifiedAndroidName: 'com.reconstrect.visionboard.CalendarThemeWidget',
      );
    } catch (e) {
      debugPrint('Error saving dates: $e');
    }
  }

  Future<void> _loadSavedDates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString('animal_calendar_theme_2025');
      debugPrint('Loading data: $savedData');

      if (savedData != null && savedData.isNotEmpty) {
        // Reset current selections
        for (var month in months) {
          selectedDates[month] = {};
        }

        // Remove the outer braces and process the string
        String cleanData = savedData.substring(1, savedData.length - 1);
        List<String> pairs = cleanData.split(', ');

        for (var pair in pairs) {
          // Split month and its data
          List<String> parts = pair.split(': ');
          if (parts.length == 2) {
            String month = parts[0].replaceAll('"', '');
            String value = parts[1].replaceAll('"', '');

            if (months.contains(month) && value.isNotEmpty) {
              // Process each day:color pair
              List<String> dayEntries = value.split(',');
              for (var entry in dayEntries) {
                List<String> dayColor = entry.split(':');
                if (dayColor.length == 2) {
                  int day = int.parse(dayColor[0]);
                  int colorIndex = int.parse(dayColor[1]);
                  selectedDates[month]![day] = colorIndex;
                }
              }
            }
          }
        }

        setState(() {});
        debugPrint('Loaded dates: $selectedDates');
      }
    } catch (e) {
      debugPrint('Error loading dates: $e');
    }
  }

  Future<void> _takeScreenshotAndShare() async {
    try {
      final image = await screenshotController.capture();
      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/animal_theme_calendar_2025.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      await Share.shareXFiles([XFile(imagePath)],
          text: 'My Animal Theme Calendar 2025');
    } catch (e) {
      debugPrint('Error sharing calendar: $e');
    }
  }

  Widget _buildMonthCard(String month, int monthIndex) {
    return SizedBox(
      height: 400, // Total fixed height for the card
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 114, // Fixed height for image
                child: Image.asset(
                  'assets/animal_calendar/animaltheme-${monthIndex + 1}.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            const SizedBox(height: 4), // Spacing between image and calendar
            SizedBox(
              height: 200, // Fixed height for calendar grid
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: _buildCalendarGrid(month, monthIndex + 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(String month, int monthNumber) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) => Text(day,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11, // Smaller font
                  )))
              .toList(),
        ),
        const SizedBox(height: 20), // Minimal spacing
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final firstDay = DateTime(2025, monthNumber, 1);
              final offset = firstDay.weekday % 7;
              final adjustedIndex = index - offset;

              if (adjustedIndex < 0 ||
                  adjustedIndex >= daysInMonth2025[monthNumber]!) {
                return const SizedBox();
              }

              final day = adjustedIndex + 1;
              final colorIndex = selectedDates[month]?[day] ?? -1;
              final backgroundColor =
                  colorIndex >= 0 ? colorOptions[colorIndex] : Colors.white;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (!selectedDates[month]!.containsKey(day)) {
                      selectedDates[month]![day] = 0;
                    } else {
                      int currentIndex = selectedDates[month]![day]!;
                      if (currentIndex < colorOptions.length - 1) {
                        selectedDates[month]![day] = currentIndex + 1;
                      } else {
                        selectedDates[month]!.remove(day);
                      }
                    }
                    _saveDates();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
                        color: backgroundColor == Colors.white
                            ? Colors.black87
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Theme Calendar 2025'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Screenshot(
              controller: screenshotController,
              child: Container(
                color: Colors.white,
                child: GridView.builder(
                  padding: const EdgeInsets.all(6),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: months.length,
                  itemBuilder: (context, index) =>
                      _buildMonthCard(months[index], index),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _takeScreenshotAndShare,
              icon: const Icon(Icons.share),
              label: const Text('Download Calendar'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
