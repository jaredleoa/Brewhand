/// BrewHand - Coffee Enthusiast Platform
/// 
/// A mobile application for coffee enthusiasts to track, share, and discover
/// coffee brewing experiences. The app combines personal brewing history with
/// social features to create a community-driven platform.
/// 
/// Created: April 2025
/// 
import 'package:flutter/material.dart';
import 'pages/my_brews_page.dart';
import 'pages/brew_master_page.dart' as master;
import 'pages/brew_bot_page.dart' as bot;
import 'pages/brew_social_page.dart' as social;
import 'pages/auth/login_page.dart';
import 'pages/auth/profile_setup_page.dart';

// Backend services
import 'services/supabase_service.dart';

/// Application entry point
/// 
/// Initializes the Flutter binding and Supabase backend service
/// before launching the main application widget.
void main() async {
  // Ensure Flutter is initialized before using platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase backend connection
  final supabaseService = SupabaseService();
  await supabaseService.initialize();

  runApp(const BrewHandApp());
}

/// Main application widget
/// 
/// Root widget of the application that manages authentication state
/// and provides the appropriate screens based on user authentication status.
class BrewHandApp extends StatefulWidget {
  const BrewHandApp({Key? key}) : super(key: key);

  @override
  State<BrewHandApp> createState() => _BrewHandAppState();
}

class _BrewHandAppState extends State<BrewHandApp> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  bool _needsProfileSetup = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    setState(() {
      _isLoading = true;
    });

    // Check if user is authenticated
    _isAuthenticated = _supabaseService.isSignedIn;

    if (_isAuthenticated) {
      // Check if user has a profile
      final profile = await _supabaseService.getUserProfile();
      _needsProfileSetup = profile == null;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BrewHand',
      theme: ThemeData(
        primaryColor: const Color(0xFF3E1F00),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E1F00),
          primary: const Color(0xFF3E1F00),
          secondary: const Color(0xFFFFB74D),
        ),
      ),
      home: _isLoading ? _buildLoadingScreen() : _getInitialScreen(),
      routes: {
        '/home': (context) => MyBrewsPage(),
        '/login': (context) => const LoginPage(),
        '/profile_setup': (context) => const ProfileSetupPage(),
        '/myBrews': (context) => MyBrewsPage(),
        '/brewMaster': (context) => master.BrewMasterPage(),
        '/brewBot': (context) => bot.BrewBotPage(),
        '/brewSocial': (context) => social.BrewSocialPage(),
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF3E1F00),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or app name
            const Text(
              'BrewHand',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Loading indicator
            const CircularProgressIndicator(
              color: Color(0xFFFFB74D),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getInitialScreen() {
    if (!_isAuthenticated) {
      return const LoginPage();
    } else if (_needsProfileSetup) {
      return const ProfileSetupPage();
    } else {
      return HomePage();
    }
  }
}

class HomePage extends StatelessWidget {
  final Color backgroundColor = Color(0xFFFFE7D3);
  final Color darkBrown = Color(0xFF3E1F00);
  final Color orangeBrown = Color(0xFFA95E04);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'BrewHand',
                style: TextStyle(
                  color: darkBrown,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    List<Map<String, dynamic>> tiles = [
                      {
                        'title': 'My Brews',
                        'image': 'assets/my_brews.svg',
                        'tileColor': darkBrown,
                        'iconColor': orangeBrown,
                        'route': '/myBrews',
                      },
                      {
                        'title': 'Brew Master',
                        'image': 'assets/brew_master.svg',
                        'tileColor': orangeBrown,
                        'iconColor': darkBrown,
                        'route': '/brewMaster',
                      },
                      {
                        'title': 'BrewBot',
                        'image': 'assets/brew_bot.svg',
                        'tileColor': orangeBrown,
                        'iconColor': darkBrown,
                        'route': '/brewBot',
                      },
                      {
                        'title': 'Brew Social',
                        'image': 'assets/brew_social.svg',
                        'tileColor': darkBrown,
                        'iconColor': orangeBrown,
                        'route': '/brewSocial',
                      },
                    ];

                    return _MenuItem(
                      title: tiles[index]['title'],
                      imagePath: tiles[index]['image'],
                      tileColor: tiles[index]['tileColor'],
                      iconColor: tiles[index]['iconColor'],
                      route: tiles[index]['route'],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}

/// Custom menu item widget with animation
///
/// Provides a consistent UI component for navigation menu items
/// with smooth tap animation and icon highlighting effects.
class _MenuItem extends StatefulWidget {
  final String title;
  final String imagePath;
  final Color tileColor;
  final Color iconColor;
  final String route;

  const _MenuItem({
    required this.title,
    required this.imagePath,
    required this.tileColor,
    required this.iconColor,
    required this.route,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  double opacity = 1.0; // Default opacity for tap effect

  void _handleTap() async {
    setState(() {
      opacity = 0.6; // Reduce opacity for tap effect
    });

    await Future.delayed(Duration(milliseconds: 150));

    setState(() {
      opacity = 1.0; // Restore opacity
    });

    await Future.delayed(Duration(milliseconds: 100));

    print("Navigating to: ${widget.route}"); // Debugging output

    Navigator.pushNamed(context, widget.route);
  }

  // Convert SVG paths to Material Icons
  IconData _getIconForPath(String path) {
    switch (path) {
      case 'assets/my_brews.svg':
        return Icons.local_cafe;
      case 'assets/brew_master.svg':
        return Icons.coffee_maker;
      case 'assets/brew_bot.svg':
        return Icons.smart_toy;
      case 'assets/brew_social.svg':
        return Icons.people;
      default:
        return Icons.coffee;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 150),
        opacity: opacity, // Manual tap effect
        child: Container(
          decoration: BoxDecoration(
            color: widget.tileColor,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconForPath(widget.imagePath),
                size: 90,
                color: widget.iconColor,
              ),
              SizedBox(height: 15),
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.iconColor.withAlpha((0.9 * 255).toInt()),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation placeholder pages
///
/// These classes serve as temporary placeholders for navigation
/// during development and testing.
class BrewMasterPage extends StatelessWidget {
  const BrewMasterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Brew Master')),
      body: Center(child: Text('Brew Master Page')),
    );
  }
}

class BrewBotPage extends StatelessWidget {
  const BrewBotPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BrewBot')),
      body: Center(child: Text('BrewBot Page')),
    );
  }
}

class BrewSocialPage extends StatelessWidget {
  const BrewSocialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Brew Social')),
      body: Center(child: Text('Brew Social Page')),
    );
  }
}
