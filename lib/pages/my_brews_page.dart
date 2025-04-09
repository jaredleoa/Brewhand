import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'brew_master_page.dart';
import 'brew_bot_page.dart' as bot;
import 'brew_social_page.dart' as social;
import 'package:brewhand/services/brew_data_service.dart';
import 'package:brewhand/pages/brew_history_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MyBrewsPage extends StatefulWidget {
  @override
  _MyBrewsPageState createState() => _MyBrewsPageState();
}

class _MyBrewsPageState extends State<MyBrewsPage> {
  final Color darkBrown = Color(0xFF3E1F00);
  final Color orangeBrown = Color(0xFFA95E04);
  final Color brightOrange = Color(0xFFFF9800);

  int _selectedIndex = 0;
  String selectedOrder = "Flat White";
  String selectedBean = "Kenya";
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

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
    _loadProfileImage();
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

  void _navigateToBrewHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BrewHistoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBrown,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                // Profile Section
                GestureDetector(
                  onTap: () => _showProfilePictureDialog(context),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: _profileImage != null
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
                  "Jared's Brew Profile",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: orangeBrown),
                ),
                Text(
                  "@jaredcoffee",
                  style: TextStyle(
                      fontSize: 16, color: orangeBrown.withOpacity(0.8)),
                ),
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
                SizedBox(height: 30),

                // Statistics section
                _buildStatisticsHeader(),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatBox(
                        "250", "Coffee Streak", "assets/coffee_cup.svg"),
                    _buildStatBox(
                        "23", "Unique Drinks", "assets/brew_master.svg"),
                    _buildStatBox("746", "Coffees Made", "assets/Star.svg"),
                    _buildStatBox("7", "Unique Beans", "assets/my_brews.svg"),
                  ],
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

  Widget _buildStatisticsHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Statistics",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: brightOrange,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: darkBrown.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: brightOrange.withOpacity(0.3)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _navigateToBrewHistory(context),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.history, color: brightOrange, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "View History",
                        style: TextStyle(color: brightOrange, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
    return Container(
      width: 160,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            brightOrange.withOpacity(0.2),
            brightOrange.withOpacity(0.6)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(iconPath,
              width: 40,
              colorFilter: ColorFilter.mode(brightOrange, BlendMode.srcIn)),
          SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: brightOrange)),
          SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 16, color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }
}
