import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'brew_master_page.dart';
import 'brew_bot_page.dart' as bot;
import 'brew_social_page.dart' as social;
import 'package:brewhand/services/brew_data_service.dart';
import 'package:brewhand/pages/brew_history_page.dart';

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
    "Arabica",
    "Robusta",
    "Liberica",
    "Excelsa",
    "Kenya AA",
    "Colombian Supremo",
    "Ethiopian Yirgacheffe",
    "Sumatra Mandheling"
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget nextPage;
    switch (index) {
      case 1:
        nextPage = BrewMasterPage();
        break;
      case 2:
        nextPage = bot.BrewBotPage(); // Use the prefix here
        break;
      case 3:
        nextPage = social.BrewSocialPage(); // Use the prefix here
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _showProfilePictureDialog(context),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child:
                          SvgPicture.asset("assets/camera_icon.svg", width: 50),
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
                  SizedBox(height: 10),
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
                        label: Text("Share",
                            style: TextStyle(color: brightOrange)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Statistics",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: brightOrange,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _navigateToBrewHistory(context),
                          icon: Icon(Icons.history, color: brightOrange),
                          label: Text(
                            "View History",
                            style: TextStyle(color: brightOrange),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildStatBox(
                            "250", "Coffee Streak", "assets/coffee_cup.svg"),
                        _buildStatBox(
                            "23", "Unique Drinks", "assets/brew_master.svg"),
                        _buildStatBox("746", "Coffees Made", "assets/Star.svg"),
                        _buildStatBox(
                            "7", "Unique Beans", "assets/my_brews.svg"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 32,
              height: 32,
              child: SvgPicture.asset(
                "assets/my_brews.svg",
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 0 ? brightOrange : orangeBrown,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 32,
              height: 32,
              child: SvgPicture.asset(
                "assets/brew_master.svg",
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 1 ? brightOrange : orangeBrown,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 32,
              height: 32,
              child: SvgPicture.asset(
                "assets/brew_bot.svg",
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 2 ? brightOrange : orangeBrown,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 32,
              height: 32,
              child: SvgPicture.asset(
                "assets/brew_social.svg",
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 3 ? brightOrange : orangeBrown,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: "",
          ),
        ],
      ),
    );
  }

  void _showProfilePictureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Profile Picture"),
        content: Text("Do you want to update or remove your profile picture?"),
        actions: [
          TextButton(onPressed: () {}, child: Text("Remove")),
          TextButton(onPressed: () {}, child: Text("Update")),
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        ],
      ),
    );
  }

  void _showOrderSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: coffeeOrders
            .map((order) => ListTile(
                  title: Text(order),
                  onTap: () {
                    setState(() => selectedOrder = order);
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _showBeanSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: coffeeBeans
            .map((bean) => ListTile(
                  title: Text(bean),
                  onTap: () {
                    setState(() => selectedBean = bean);
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _showAddFriendsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Friends"),
        content:
            TextField(decoration: InputDecoration(labelText: "Enter Username")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(onPressed: () {}, child: Text("Add")),
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
