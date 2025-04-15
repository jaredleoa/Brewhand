import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'brew_master_page.dart';
import 'brew_bot_page.dart' as bot;
import 'brew_social_page.dart' as social;
import 'package:brewhand/services/supabase_service.dart';
import 'package:brewhand/pages/brew_history_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:brewhand/models/user_profile.dart';
import 'package:brewhand/models/user_stats.dart';

class MyBrewsPage extends StatefulWidget {
  @override
  _MyBrewsPageState createState() => _MyBrewsPageState();
}

class _MyBrewsPageState extends State<MyBrewsPage> with WidgetsBindingObserver {
  final Color darkBrown = Color(0xFF3E1F00);
  final Color orangeBrown = Color(0xFFA95E04);
  final Color brightOrange = Color(0xFFFF9800);

  int _selectedIndex = 0;
  String selectedOrder = "Flat White";
  String selectedBean = "Kenya";
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final SupabaseService _supabaseService = SupabaseService();
  
  // Add variables to store user profile and stats
  UserProfile? _userProfile;
  UserStats? _userStats;
  bool _isLoading = true;

  List<String> coffeeOrders = [
    "Espresso",
    "Americano",
    "Cappuccino",
    "Latte",
    "Flat White",
    "Macchiato",
    "Mocha",
    "Affogato"
  ];

  List<String> coffeeBeans = [
    "Kenya",
    "Ethiopia",
    "Rwanda",
    "Uganda",
    "Tanzania",
    "Colombia",
    "Brazil",
    "Costa Rica",
    "Guatemala",
    "Panama",
    "Honduras",
    "Peru",
    "Indonesia (Sumatra)",
    "Vietnam",
    "Thailand"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfileImage();
    _loadUserData(); // Add method to load user profile and stats
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app is resumed
      _loadUserData();
    }
  }
  
  // Load user profile and stats data
  Future<void> _loadUserData() async {
    try {
      // Load user profile
      final profile = await _supabaseService.getUserProfile();
      if (profile != null && mounted) {
        setState(() {
          _userProfile = profile;
          // Update selected values if they exist in profile
          if (profile.favoriteBrew != null && profile.favoriteBrew!.isNotEmpty) {
            // Split favorite brew if it contains both order and bean
            if (profile.favoriteBrew!.contains('(')) {
              final parts = profile.favoriteBrew!.split('(');
              selectedOrder = parts[0].trim();
              selectedBean = parts[1].replaceAll(')', '').trim();
            } else {
              selectedOrder = profile.favoriteBrew!;
            }
          }
        });
      }
      
      // Load user stats
      final stats = await _supabaseService.getUserStats();
      print('Loaded user stats: $stats'); // Debug logging
      if (stats != null && mounted) {
        setState(() {
          _userStats = stats;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/profile_image.jpg';
      final file = File(path);

      if (await file.exists()) {
        setState(() {
          _profileImage = file;
        });
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  Future<void> _saveProfileImage(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/profile_image.jpg';

      // Copy the image to app storage
      await image.copy(path);

      setState(() {
        _profileImage = File(path);
      });
    } catch (e) {
      print('Error saving profile image: $e');
    }
  }

  Future<void> _deleteProfileImage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/profile_image.jpg';
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }

      setState(() {
        _profileImage = null;
      });
    } catch (e) {
      print('Error deleting profile image: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _saveProfileImage(File(pickedFile.path));
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget nextPage;
    switch (index) {
      case 1:
        nextPage = BrewMasterPage();
        break;
      case 2:
        nextPage = bot.BrewBotPage();
        break;
      case 3:
        nextPage = social.BrewSocialPage();
        break;
      default:
        nextPage = MyBrewsPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }
  
  // Refresh data when returning from another screen
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _loadUserData();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToBrewHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BrewHistoryPage()),
    ).then((_) {
      // Refresh data when returning from BrewHistoryPage
      _refreshData();
    });
  }

  // Get the title for the app bar based on selected tab
  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'My Brews';
      case 1:
        return 'Brew Master';
      case 2:
        return 'BrewBot';
      case 3:
        return 'Brew Social';
      default:
        return 'BrewHand';
    }
  }

  // Show settings menu with logout option
  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: darkBrown,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.logout, color: brightOrange),
                title: Text('Log Out', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _handleLogout();
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: brightOrange),
                title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Edit Profile feature coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.color_lens, color: brightOrange),
                title: Text('App Theme', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Theme settings coming soon!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Handle logout action
  Future<void> _handleLogout() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: darkBrown,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: brightOrange),
                SizedBox(height: 20),
                Text('Logging out...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        );
      },
    );
    
    // Perform logout
    try {
      await _supabaseService.signOut();
      
      // Close dialog and navigate to login page
      Navigator.of(context).pop(); // Close dialog
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Close dialog and show error
      Navigator.of(context).pop(); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBrown,
      appBar: AppBar(
        backgroundColor: darkBrown,
        elevation: 0,
        title: Text(
          _getAppBarTitle(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: _selectedIndex == 0 ? [
          // Only show settings button on My Brews tab
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsMenu(context),
          ),
        ] : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                // Profile Section
                _isLoading 
                ? Center(child: CircularProgressIndicator(color: brightOrange))
                : Column(children: [
                  GestureDetector(
                    onTap: () => _showProfilePictureDialog(context),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: _userProfile?.avatarUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                _userProfile!.avatarUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => 
                                  Icon(Icons.person, size: 50, color: orangeBrown),
                              ),
                            )
                          : _profileImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.file(
                                    _profileImage!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : SvgPicture.asset(
                                  "assets/camera_icon.svg",
                                  width: 50,
                                  colorFilter:
                                      ColorFilter.mode(orangeBrown, BlendMode.srcIn),
                                ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${_userProfile?.fullName ?? _userProfile?.username ?? 'User'}\'s Brew Profile",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: orangeBrown),
                  ),
                  Text(
                    "@${_userProfile?.username ?? 'anonymous'}",
                    style: TextStyle(
                        fontSize: 16, color: orangeBrown.withOpacity(0.8)),
                  ),
                ]),
                SizedBox(height: 10),

                // Following and Followers counts
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("900 Following",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: brightOrange)),
                    SizedBox(width: 20),
                    Text("3452 Followers",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: brightOrange)),
                  ],
                ),
                SizedBox(height: 10),

                // Order and Bean selection boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _showOrderSelection(context),
                      child: _buildSelectionBox("Order: $selectedOrder"),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _showBeanSelection(context),
                      child: _buildSelectionBox("Bean: $selectedBean"),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Add Friends and Share buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAddFriendsDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBrown,
                        side: BorderSide(color: brightOrange),
                      ),
                      icon: Icon(Icons.person_add, color: brightOrange),
                      label: Text("Add Friends",
                          style: TextStyle(color: brightOrange)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _shareProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBrown,
                        side: BorderSide(color: brightOrange),
                      ),
                      icon: Icon(Icons.share, color: brightOrange),
                      label:
                          Text("Share", style: TextStyle(color: brightOrange)),
                    ),
                  ],
                ),
                SizedBox(height: 15), // Reduced from 30 to 15

                // Statistics section with header and grid in a container with gradient background
                Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [orangeBrown.withOpacity(0.35), orangeBrown.withOpacity(0.15)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      // Header row with View History button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Statistics",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          InkWell(
                            onTap: () => _navigateToBrewHistory(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: darkBrown.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: brightOrange.withOpacity(0.3), width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.history, color: brightOrange, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    "View History",
                                    style: TextStyle(
                                      color: brightOrange, 
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 15),
                      
                      // Stats grid
                      _isLoading
                      ? Center(child: CircularProgressIndicator(color: brightOrange))
                      : GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        childAspectRatio: 0.9,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          _buildStatBox("${_userStats?.coffeeStreak ?? 0}", "Coffee Streak", "assets/coffee_cup.svg"),
                          _buildStatBox("${_userStats?.uniqueDrinks ?? 0}", "Unique Drinks", "assets/brew_master.svg"),
                          _buildStatBox("${_userStats?.coffeesMade ?? 0}", "Coffees Made", "assets/Star.svg"),
                          _buildStatBox("${_userStats?.uniqueBeans ?? 0}", "Unique Beans", "assets/my_brews.svg"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: darkBrown,
        elevation: 0,
        selectedItemColor: brightOrange,
        unselectedItemColor: orangeBrown,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                "assets/my_brews.svg",
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 0 ? brightOrange : orangeBrown,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: "Brews",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                "assets/brew_master.svg",
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 1 ? brightOrange : orangeBrown,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: "Master",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                "assets/brew_bot.svg",
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 2 ? brightOrange : orangeBrown,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: "Bot",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                "assets/brew_social.svg",
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 3 ? brightOrange : orangeBrown,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: "Social",
          ),
        ],
      ),
    );
  }

  // Removed unused statistics header method

  void _showOrderSelection(BuildContext context) {
    TextEditingController customOrderController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: darkBrown,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Coffee Order",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: brightOrange,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: brightOrange),
                      onPressed: () {
                        // Show dialog to add custom order
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: darkBrown,
                            title: Text(
                              "Add Custom Order",
                              style: TextStyle(color: brightOrange),
                            ),
                            content: TextField(
                              controller: customOrderController,
                              decoration: InputDecoration(
                                hintText: "Enter custom coffee order",
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.6)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: orangeBrown.withOpacity(0.5)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: brightOrange),
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.7)),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: brightOrange,
                                  foregroundColor: darkBrown,
                                ),
                                onPressed: () {
                                  if (customOrderController.text
                                      .trim()
                                      .isNotEmpty) {
                                    Navigator.pop(context);

                                    // Add to list if it doesn't already exist
                                    if (!coffeeOrders.contains(
                                        customOrderController.text.trim())) {
                                      coffeeOrders.add(
                                          customOrderController.text.trim());
                                    }

                                    // Set as selected order and close sheet
                                    setState(() {
                                      selectedOrder =
                                          customOrderController.text.trim();
                                    });
                                    Navigator.pop(context);

                                    // Update parent widget state
                                    this.setState(() {});
                                  }
                                },
                                child: Text(
                                  "Add",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: darkBrown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Divider(color: orangeBrown.withOpacity(0.3)),
              Expanded(
                child: ListView.builder(
                  itemCount: coffeeOrders.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(
                      coffeeOrders[index],
                      style: TextStyle(
                        color: coffeeOrders[index] == selectedOrder
                            ? brightOrange
                            : Colors.white,
                        fontWeight: coffeeOrders[index] == selectedOrder
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: coffeeOrders[index] == selectedOrder
                        ? Icon(Icons.check, color: brightOrange)
                        : null,
                    onTap: () {
                      setState(() => selectedOrder = coffeeOrders[index]);
                      this.setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBeanSelection(BuildContext context) {
    TextEditingController customBeanController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: darkBrown,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Coffee Bean",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: brightOrange,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: brightOrange),
                      onPressed: () {
                        // Show dialog to add custom bean
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: darkBrown,
                            title: Text(
                              "Add Custom Bean",
                              style: TextStyle(color: brightOrange),
                            ),
                            content: TextField(
                              controller: customBeanController,
                              decoration: InputDecoration(
                                hintText: "Enter custom coffee bean",
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.6)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: orangeBrown.withOpacity(0.5)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: brightOrange),
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.7)),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: brightOrange,
                                  foregroundColor: darkBrown,
                                ),
                                onPressed: () {
                                  if (customBeanController.text
                                      .trim()
                                      .isNotEmpty) {
                                    Navigator.pop(context);

                                    // Add to list if it doesn't already exist
                                    if (!coffeeBeans.contains(
                                        customBeanController.text.trim())) {
                                      coffeeBeans.add(
                                          customBeanController.text.trim());
                                    }

                                    // Set as selected bean and close sheet
                                    setState(() {
                                      selectedBean =
                                          customBeanController.text.trim();
                                    });
                                    Navigator.pop(context);

                                    // Update parent widget state
                                    this.setState(() {});
                                  }
                                },
                                child: Text(
                                  "Add",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: darkBrown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Divider(color: orangeBrown.withOpacity(0.3)),
              Expanded(
                child: ListView.builder(
                  itemCount: coffeeBeans.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(
                      coffeeBeans[index],
                      style: TextStyle(
                        color: coffeeBeans[index] == selectedBean
                            ? brightOrange
                            : Colors.white,
                        fontWeight: coffeeBeans[index] == selectedBean
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: coffeeBeans[index] == selectedBean
                        ? Icon(Icons.check, color: brightOrange)
                        : null,
                    onTap: () {
                      setState(() => selectedBean = coffeeBeans[index]);
                      this.setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfilePictureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkBrown,
        title: Text("Profile Picture", style: TextStyle(color: brightOrange)),
        content: Text(
          "Do you want to update or remove your profile picture?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProfileImage();
            },
            child: Text("Remove",
                style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showImageSourceDialog(context);
            },
            child: Text("Update",
                style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brightOrange,
              foregroundColor: darkBrown,
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(fontWeight: FontWeight.bold, color: darkBrown),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkBrown,
        title:
            Text("Choose Image Source", style: TextStyle(color: brightOrange)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: brightOrange),
              title:
                  Text("Take a photo", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: brightOrange),
              title: Text("Choose from gallery",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFriendsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkBrown,
        title: Text(
          "Add Friends",
          style: TextStyle(color: brightOrange),
        ),
        content: TextField(
          decoration: InputDecoration(
            labelText: "Enter Username",
            labelStyle: TextStyle(color: brightOrange.withOpacity(0.7)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: orangeBrown.withOpacity(0.5)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: brightOrange),
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brightOrange,
              foregroundColor: darkBrown,
            ),
            onPressed: () {
              // Add friend logic would go here
              Navigator.pop(context);
            },
            child: Text(
              "Add",
              style: TextStyle(fontWeight: FontWeight.bold, color: darkBrown),
            ),
          ),
        ],
      ),
    );
  }

  void _shareProfile() {
    // Placeholder function for sharing
    print("Sharing profile...");
  }

  Widget _buildSelectionBox(String text) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: brightOrange, borderRadius: BorderRadius.circular(10)),
      child: Text(text,
          style: TextStyle(fontWeight: FontWeight.bold, color: darkBrown)),
    );
  }

  Widget _buildStatBox(String value, String label, String iconPath) {
    // Convert SVG path to Material Icon
    IconData icon = Icons.coffee;
    
    // Map icon paths to Material Icons
    if (iconPath == 'assets/coffee_cup.svg') {
      icon = Icons.local_cafe;
    } else if (iconPath == 'assets/brew_master.svg') {
      icon = Icons.auto_awesome;
    } else if (iconPath == 'assets/Star.svg') {
      icon = Icons.star;
    } else if (iconPath == 'assets/my_brews.svg') {
      icon = Icons.coffee_maker;
    }
    
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [orangeBrown.withOpacity(0.35), orangeBrown.withOpacity(0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: brightOrange.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Larger icon container
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 48,
              color: brightOrange,
            ),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: brightOrange,
            ),
          ),
          SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
