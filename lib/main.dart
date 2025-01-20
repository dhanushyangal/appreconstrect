import 'package:flutter/material.dart';
import 'pages/vision_board_page.dart';
import 'Annual Planner/annual_planner_page.dart';
import 'pages/planners_page.dart';
import 'pages/box_them_vision_board.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/services.dart';
import 'pages/premium_them_vision_board.dart';
import 'pages/post_it_theme_vision_board.dart';
import 'pages/winter_warmth_theme_vision_board.dart';
import 'pages/ruby_reds_theme_vision_board.dart';
import 'pages/coffee_hues_theme_vision_board.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HomeWidget.registerInteractivityCallback(backgroundCallback);

  // Set up platform channel to receive widget intent
  const platform = MethodChannel('com.reconstrect.visionboard/widget');
  platform.setMethodCallHandler((call) async {
    if (call.method == 'openVisionBoardWithTheme') {
      final category = call.arguments['category'] as String?;
      final theme = call.arguments['theme'] as String?;

      if (category != null && theme != null) {
        Widget page;
        switch (theme) {
          case 'Premium Vision Board':
            page = const PremiumThemeVisionBoard();
            break;
          case 'PostIt Vision Board':
            page = const PostItThemeVisionBoard();
            break;
          case 'Winter Warmth Vision Board':
            page = const WinterWarmthThemeVisionBoard();
            break;
          case 'Ruby Reds Vision Board':
            page = const RubyRedsThemeVisionBoard();
            break;
          case 'Coffee Hues Vision Board':
            page = const CoffeeHuesThemeVisionBoard();
            break;
          case 'Box Vision Board':
          default:
            page = VisionBoardDetailsPage(title: theme);
        }

        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => page),
        );
      }
    }
  });

  runApp(const MyApp());
}

// Global navigator key to access navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> backgroundCallback(Uri? uri) async {
  if (uri?.host == 'updatewidget') {
    // Handle widget update
    await HomeWidget.updateWidget(
      androidName: 'VisionBoardWidget',
      iOSName: 'VisionBoardWidget',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Add navigator key here
      title: 'Reconstruct',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const PlannersPage(),
    const MindKitsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        toolbarHeight: 40,
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Image.asset('assets/logo.png', height: 36),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize),
            label: 'Planners',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Mind Kits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _visionBoardKey = GlobalKey();
  bool _isHovered = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Mind tools for optimal everyday performance.',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Gain control over your thoughts',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    final RenderBox renderBox = _visionBoardKey.currentContext
                        ?.findRenderObject() as RenderBox;
                    final position = renderBox.localToGlobal(Offset.zero);
                    _scrollController.animateTo(
                      position.dy,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Try Mind Tools',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                SizedBox(
                  key: _visionBoardKey,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '2025 Digital Planners & Calendars',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 32),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildPlannerCard(
                              context,
                              'assets/vision-board-plain.jpg',
                              'Vision Board',
                            ),
                            const SizedBox(width: 24),
                            _buildPlannerCard(
                              context,
                              'assets/annual.jpg',
                              'Annual Planner',
                            ),
                            const SizedBox(width: 24),
                            _buildPlannerCard(
                              context,
                              'assets/calendar.jpg',
                              'Calendar',
                            ),
                            const SizedBox(width: 24),
                            _buildPlannerCard(
                              context,
                              'assets/weeklyplanner.jpg',
                              'Weekly Planner',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlannerCard(
      BuildContext context, String imagePath, String title) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered
            ? (Matrix4.identity()..translate(0, -10))
            : Matrix4.identity(),
        child: GestureDetector(
          onTap: () {
            if (title == 'Annual Planner') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnnualPlannerPage(),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VisionBoardPage(),
                ),
              );
            }
          },
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(_isHovered ? 40 : 25),
                  blurRadius: _isHovered ? 15 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: 300,
                    height: 400,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MindKitsPage extends StatelessWidget {
  const MindKitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      children: [
        _buildMindKitCard(
            'Lonely', Icons.sentiment_dissatisfied, Colors.purple),
        _buildMindKitCard('Angry', Icons.mood_bad, Colors.red),
        _buildMindKitCard(
            'Sad', Icons.sentiment_very_dissatisfied, Colors.blue),
        _buildMindKitCard('Anxious', Icons.psychology, Colors.orange),
        _buildMindKitCard('Irritated', Icons.mood_bad, Colors.deepOrange),
        _buildMindKitCard(
            'Frustrated', Icons.sentiment_very_dissatisfied, Colors.brown),
      ],
    );
  }

  Widget _buildMindKitCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => const VisionBoardPage()),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Coming Soon!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'This feature is under development. Stay tuned!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
