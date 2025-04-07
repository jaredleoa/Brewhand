import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brewhand/services/brew_data_service.dart';
import 'package:brewhand/pages/my_brews_page.dart';
import 'package:brewhand/pages/brew_bot_page.dart';
import 'package:brewhand/pages/brew_social_page.dart';

class BrewMasterPage extends StatefulWidget {
  @override
  _BrewMasterPageState createState() => _BrewMasterPageState();
}

class _BrewMasterPageState extends State<BrewMasterPage> {
  final Color darkBrown = Color(0xFF3E1F00);
  final Color orangeBrown = Color(0xFFA95E04);
  final Color brightOrange = Color(0xFFFF9800);
  final Color lightBeige = Color(0xFFFFE7D3);

  String selectedBean = "Kenya";
  int waterAmount = 300; // ml
  int coffeeAmount = 18; // grams

  // Available brewing methods
  final List<Map<String, dynamic>> brewingMethods = [
    {
      'name': 'French Press',
      'icon': 'assets/coffee_cup.svg',
      'description': 'Rich, full-bodied coffee with a simple brewing process',
      'time': '4 min',
      'difficulty': 'Easy',
    },
    {
      'name': 'Pour Over',
      'icon': 'assets/coffee_cup.svg',
      'description': 'Clean, bright coffee with clear flavors',
      'time': '3 min',
      'difficulty': 'Medium',
    },
    {
      'name': 'AeroPress',
      'icon': 'assets/coffee_cup.svg',
      'description': 'Smooth coffee with versatile brewing options',
      'time': '2 min',
      'difficulty': 'Easy',
    },
    {
      'name': 'Espresso',
      'icon': 'assets/coffee_cup.svg',
      'description': 'Concentrated coffee with rich crema',
      'time': '1 min',
      'difficulty': 'Hard',
    },
  ];

  // For the step-by-step guide
  bool showGuide = false;
  String selectedMethod = '';
  int currentStep = 0;
  bool brewCompleted = false;

  // Step lists for different brewing methods
  Map<String, List<String>> brewingSteps = {
    'French Press': [
      'Boil water to 200°F (93°C)',
      'Grind coffee beans to coarse consistency',
      'Add coffee grounds to the French press',
      'Pour hot water over the grounds',
      'Stir gently to ensure all grounds are saturated',
      'Place the plunger on top but don\'t press down. Let steep for 4 minutes',
      'Slowly press the plunger down',
      'Pour and enjoy your coffee!',
    ],
    'Pour Over': [
      'Boil water to 200°F (93°C)',
      'Grind coffee beans to medium-fine consistency',
      'Place filter in dripper and rinse with hot water',
      'Add coffee grounds to the filter',
      'Pour a small amount of water to "bloom" the coffee for 30 seconds',
      'Slowly pour the remaining water in circular motion',
      'Allow all water to drip through',
      'Remove filter and enjoy your coffee!',
    ],
    'AeroPress': [
      'Boil water to 185°F (85°C)',
      'Grind coffee beans to fine consistency',
      'Place filter in AeroPress cap and rinse with hot water',
      'Attach cap to AeroPress chamber and place on cup',
      'Add coffee grounds to the chamber',
      'Pour hot water and stir for 10 seconds',
      'Insert plunger and press down gently',
      'Enjoy your coffee!',
    ],
    'Espresso': [
      'Preheat your espresso machine',
      'Grind coffee beans to fine consistency',
      'Add coffee grounds to the portafilter',
      'Tamp down the grounds evenly',
      'Lock the portafilter into the machine',
      'Start the extraction - aim for 25-30 seconds',
      'Watch for the golden crema forming',
      'Enjoy your espresso!',
    ],
  };

  List<String> coffeeBeans = [
    "Arabica",
    "Robusta",
    "Liberica",
    "Excelsa",
    "Kenya",
    "Colombian Supremo",
    "Ethiopian Yirgacheffe",
    "Sumatra Mandheling",
  ];

  List<String> grindSizes = [
    "Extra Coarse",
    "Coarse",
    "Medium-Coarse",
    "Medium",
    "Medium-Fine",
    "Fine",
    "Extra Fine",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBrown,
      appBar: AppBar(
        title: Text(
          "Brew Master",
          style: TextStyle(color: brightOrange, fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkBrown,
        elevation: 0,
        iconTheme: IconThemeData(color: brightOrange),
      ),
      body: showGuide ? _buildBrewingGuide() : _buildBrewingMethodsList(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBrewingMethodsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select a Brewing Method",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: brightOrange,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: brewingMethods.length,
              itemBuilder: (context, index) {
                return _buildBrewingMethodCard(brewingMethods[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrewingMethodCard(Map<String, dynamic> method) {
    return GestureDetector(
      onTap: () {
        // Show brewing setup dialog
        _showBrewingSetupDialog(method['name']);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              orangeBrown.withOpacity(0.8),
              orangeBrown.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                method['icon'],
                width: 60,
                height: 60,
                colorFilter: ColorFilter.mode(brightOrange, BlendMode.srcIn),
              ),
              SizedBox(height: 16),
              Text(
                method['name'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                method['description'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMethodStat(Icons.timer, method['time']),
                  _buildMethodStat(Icons.trending_up, method['difficulty']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: brightOrange),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.white)),
      ],
    );
  }

  void _showBrewingSetupDialog(String methodName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: darkBrown,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Brew Setup - $methodName",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: brightOrange,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Select your coffee bean:",
                      style: TextStyle(fontSize: 18, color: brightOrange),
                    ),
                    SizedBox(height: 8),
                    _buildDropdown(
                      value: selectedBean,
                      items: coffeeBeans,
                      onChanged: (value) {
                        setModalState(() {
                          selectedBean = value!;
                        });
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Water: $waterAmount ml",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: brightOrange,
                                ),
                              ),
                              // Water slider is read-only/display only
                              Slider(
                                value: waterAmount.toDouble(),
                                min: 150,
                                max: 1000,
                                divisions: 17,
                                activeColor: brightOrange.withOpacity(
                                  0.3,
                                ), // dimmed to indicate it's not interactive
                                inactiveColor: orangeBrown.withOpacity(0.2),
                                onChanged: null, // Makes the slider read-only
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Coffee: $coffeeAmount g",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: brightOrange,
                                ),
                              ),
                              Slider(
                                value: coffeeAmount.toDouble(),
                                min: 10,
                                max: 40,
                                divisions: 30,
                                activeColor: brightOrange,
                                inactiveColor: orangeBrown.withOpacity(0.3),
                                onChanged: (value) {
                                  setModalState(() {
                                    coffeeAmount = value.toInt();
                                    // Calculate water based on coffee (using 1:16.67 ratio)
                                    waterAmount =
                                        (coffeeAmount * 16.67).round();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Ratio: 1:${(waterAmount / coffeeAmount).toStringAsFixed(1)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: brightOrange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade800,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brightOrange,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                selectedMethod = methodName;
                                showGuide = true;
                                currentStep = 0;
                                brewCompleted = false;
                              });
                            },
                            child: Text(
                              "Start Brewing",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkBrown,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: orangeBrown.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: orangeBrown),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: darkBrown,
        underline: SizedBox(),
        style: TextStyle(color: brightOrange, fontSize: 16),
        icon: Icon(Icons.keyboard_arrow_down, color: brightOrange),
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildBrewingGuide() {
    List<String> steps = brewingSteps[selectedMethod] ?? [];
    bool isLastStep = currentStep == steps.length - 1;

    return Column(
      children: [
        // Progress bar
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$selectedMethod Guide",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: brightOrange,
                    ),
                  ),
                  Text(
                    "Step ${currentStep + 1}/${steps.length}",
                    style: TextStyle(fontSize: 16, color: brightOrange),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (currentStep + 1) / steps.length,
                  minHeight: 10,
                  backgroundColor: orangeBrown.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(brightOrange),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        // Brewing setup display
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: orangeBrown.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBrewInfoItem("Bean", selectedBean),
              _buildBrewInfoItem("Water", "$waterAmount ml"),
              _buildBrewInfoItem("Coffee", "$coffeeAmount g"),
            ],
          ),
        ),
        SizedBox(height: 16),
        // Step display
        Expanded(
          child:
              brewCompleted
                  ? _buildCompletionScreen()
                  : Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          orangeBrown.withOpacity(0.6),
                          orangeBrown.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getStepIcon(currentStep),
                          size: 80,
                          color: brightOrange,
                        ),
                        SizedBox(height: 24),
                        Text(
                          steps[currentStep],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brightOrange,
                            minimumSize: Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              if (isLastStep) {
                                brewCompleted = true;
                                // Here you would update stats
                                // Example: updateStats();
                              } else {
                                currentStep++;
                              }
                            });
                          },
                          child: Text(
                            isLastStep ? "Complete Brew" : "Next Step",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildBrewInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: brightOrange.withOpacity(0.8)),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: brightOrange,
          ),
        ),
      ],
    );
  }

  IconData _getStepIcon(int step) {
    List<IconData> icons = [
      Icons.water_drop,
      Icons.coffee_maker,
      Icons.add,
      Icons.hourglass_top,
      Icons.stacked_line_chart,
      Icons.timelapse,
      Icons.play_circle,
      Icons.done_all,
    ];

    return step < icons.length ? icons[step] : Icons.coffee;
  }

  Widget _buildCompletionScreen() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            brightOrange.withOpacity(0.6),
            brightOrange.withOpacity(0.3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, size: 80, color: Colors.amber),
          SizedBox(height: 24),
          Text(
            "Congratulations!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            "You've successfully brewed a $selectedMethod using $selectedBean beans!",
            style: TextStyle(fontSize: 18, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          // Rating system
          Text(
            "How was your coffee?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  // Save rating logic
                },
                icon: Icon(
                  Icons.star,
                  size: 36,
                  color:
                      index < 4 ? Colors.amber : Colors.white.withOpacity(0.3),
                ),
              );
            }),
          ),
          SizedBox(height: 24),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Add notes about this brew (optional)",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              fillColor: darkBrown.withOpacity(0.3),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
          Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBrown,
              minimumSize: Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              setState(() {
                showGuide = false;
                // Here you would save the brew to history
                _showBrewSavedDialog();
              });
            },
            child: Text(
              "Save to My Brews",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: brightOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBrewSavedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: darkBrown,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              "Brew Saved!",
              style: TextStyle(
                color: brightOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, color: brightOrange, size: 64),
                SizedBox(height: 16),
                Text(
                  "Your brew has been saved to your history and shared with your followers!",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "Stats updated:\n• Coffee Streak: +1\n• Coffees Made: +1",
                  style: TextStyle(color: brightOrange),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close", style: TextStyle(color: brightOrange)),
              ),
            ],
          ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: darkBrown,
      elevation: 0,
      selectedItemColor: brightOrange,
      unselectedItemColor: orangeBrown,
      currentIndex: 1, // BrewMaster is index 1
      onTap: (index) {
        if (index == 1) return; // Already on this page

        Widget nextPage;
        switch (index) {
          case 0:
            nextPage = MyBrewsPage();
            break;
          case 2:
            nextPage = BrewBotPage();
            break;
          case 3:
            nextPage = BrewSocialPage();
            break;
          default:
            return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    index == 0
                        ? MyBrewsPage()
                        : index == 2
                        ? BrewBotPage()
                        : BrewSocialPage(),
          ),
        );
      },
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
              colorFilter: ColorFilter.mode(orangeBrown, BlendMode.srcIn),
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
              colorFilter: ColorFilter.mode(brightOrange, BlendMode.srcIn),
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
              colorFilter: ColorFilter.mode(orangeBrown, BlendMode.srcIn),
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
              colorFilter: ColorFilter.mode(orangeBrown, BlendMode.srcIn),
            ),
          ),
          label: "",
        ),
      ],
    );
  }
}

class BrewBotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class BrewSocialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
