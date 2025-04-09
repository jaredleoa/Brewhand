import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brewhand/models/coffee_region.dart';
import 'package:brewhand/pages/brew_history_page.dart';
import 'package:brewhand/services/bean_library_service.dart';
import 'package:brewhand/services/brew_data_service.dart';
import 'package:brewhand/pages/my_brews_page.dart';
import 'package:brewhand/pages/brew_bot_page.dart';
import 'package:brewhand/pages/brew_social_page.dart';
import 'package:brewhand/pages/brew_history_page.dart';
import 'package:uuid/uuid.dart';

class BrewMasterPage extends StatefulWidget {
  @override
  _BrewMasterPageState createState() => _BrewMasterPageState();
}

class _BrewMasterPageState extends State<BrewMasterPage> {
  final Color darkBrown = Color(0xFF3E1F00);
  final Color mediumBrown = Color(0xFF60300F);
  final Color orangeBrown = Color(0xFFA95E04);
  final Color brightOrange = Color(0xFFFF9800);
  final Color lightBeige = Color(0xFFFFE7D3);

  String selectedBean = "Ethiopian";
  String selectedRegion = "Africa";
  // Grind size is now determined automatically based on brewing method
  String recommendedGrindSize = "Medium";
  int waterAmount = 300; // ml
  int coffeeAmount = 18; // grams

  // Loading state
  bool isLoading = true;
  BeanLibrary beanLibrary = BeanLibrary.defaultLibrary();

  // Available brewing methods with recommended grind size
  final List<Map<String, dynamic>> brewingMethods = [
    {
      'name': 'French Press',
      'icon': 'assets/coffee_cup.svg',
      'description': 'Rich, full-bodied coffee with a simple brewing process',
      'time': '4 min',
      'difficulty': 'Easy',
      'recommendedGrind': 'Coarse',
    },
    {
      'name': 'Pour Over',
      'icon': 'assets/coffee_cup.svg',
      'description': 'Clean, bright coffee with clear flavors',
      'time': '3 min',
      'difficulty': 'Medium',
      'recommendedGrind': 'Medium-Fine',
    },
    {
      'name': 'AeroPress',
      'icon': 'assets/coffee_cup.svg',
      'description': 'Smooth coffee with versatile brewing options',
      'time': '2 min',
      'difficulty': 'Easy',
      'recommendedGrind': 'Fine',
    },
    {
      'name': 'Espresso',
      'icon': 'assets/coffee_cup.svg',
      'description': 'Concentrated coffee with rich crema',
      'time': '1 min',
      'difficulty': 'Hard',
      'recommendedGrind': 'Extra Fine',
    },
  ];

  // Helper method to get beans for the selected region
  List<String> _getBeansForSelectedRegion() {
    for (var region in beanLibrary.regions) {
      if (region.name == selectedRegion) {
        return region.countries;
      }
    }
    return [];
  }

  // For the step-by-step guide
  bool showGuide = false;
  String selectedMethod = '';
  int currentStep = 0;
  bool brewCompleted = false;

  // Step lists for different brewing methods
  Map<String, List<String>> brewingSteps = {
    'French Press': [
      'Boil water to 93°C',
      'We recommend using Coarse grind for French Press',
      'Add coffee grounds to the French press',
      'Pour hot water over the grounds',
      'Stir gently to ensure all grounds are saturated',
      'Place the plunger on top but don\'t press down. Let steep for 4 minutes',
      'Slowly press the plunger down',
      'Pour and enjoy your coffee!',
    ],
    'Pour Over': [
      'Boil water to 93°C',
      'We recommend using Medium-Fine grind for Pour Over',
      'Place filter in dripper and rinse with hot water',
      'Add coffee grounds to the filter',
      'Pour a small amount of water to "bloom" the coffee for 30 seconds',
      'Slowly pour the remaining water in circular motion',
      'Allow all water to drip through',
      'Remove filter and enjoy your coffee!',
    ],
    'AeroPress': [
      'Boil water to 85°C',
      'We recommend using Fine grind for AeroPress',
      'Place filter in AeroPress cap and rinse with hot water',
      'Attach cap to AeroPress chamber and place on cup',
      'Add coffee grounds to the chamber',
      'Pour hot water and stir for 10 seconds',
      'Insert plunger and press down gently',
      'Enjoy your coffee!',
    ],
    'Espresso': [
      'Preheat your espresso machine',
      'We recommend using Extra Fine grind for Espresso',
      'Add coffee grounds to the portafilter',
      'Tamp down the grounds evenly',
      'Lock the portafilter into the machine',
      'Start the extraction - aim for 25-30 seconds',
      'Watch for the golden crema forming',
      'Enjoy your espresso!',
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadBeanLibrary();
  }

  Future<void> _loadBeanLibrary() async {
    try {
      final BeanLibraryService beanService = BeanLibraryService();
      final loadedLibrary = await beanService.getBeanLibrary();

      setState(() {
        beanLibrary = loadedLibrary;
        if (loadedLibrary.regions.isNotEmpty) {
          selectedRegion = loadedLibrary.regions[0].name;
          if (loadedLibrary.regions[0].countries.isNotEmpty) {
            selectedBean = loadedLibrary.regions[0].countries[0];
          }
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error loading bean library: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

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
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: brightOrange))
          : showGuide
              ? _buildBrewingGuide()
              : _buildBrewingMethodsList(),
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
        // Set the recommended grind size for this method
        setState(() {
          recommendedGrindSize = method['recommendedGrind'];
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              orangeBrown.withOpacity(0.9),
              orangeBrown.withOpacity(0.6),
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
    // Set the recommended grind size for the selected method
    for (var method in brewingMethods) {
      if (method['name'] == methodName) {
        recommendedGrindSize = method['recommendedGrind'];
        break;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height *
                  0.80, // Reduced height to avoid overflow
              decoration: BoxDecoration(
                color: darkBrown,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with underline
                    Column(
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
                        Container(
                          height: 3,
                          width: 100,
                          margin: EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: brightOrange,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Region selection
                    Text(
                      "Region:",
                      style: TextStyle(fontSize: 18, color: brightOrange),
                    ),
                    SizedBox(height: 8),
                    _buildDropdown(
                      value: selectedRegion,
                      items: beanLibrary.regions
                          .map((region) => region.name)
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            selectedRegion = value;
                            // Update selected bean to first in the new region
                            for (var region in beanLibrary.regions) {
                              if (region.name == value &&
                                  region.countries.isNotEmpty) {
                                selectedBean = region.countries[0];
                                break;
                              }
                            }
                          });
                        }
                      },
                    ),

                    SizedBox(height: 16),

                    // Bean selection
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Coffee beans:",
                                style: TextStyle(
                                    fontSize: 18, color: brightOrange),
                              ),
                              SizedBox(height: 8),
                              // Get countries for the selected region
                              _buildDropdown(
                                value: selectedBean,
                                items: _getBeansForSelectedRegion(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setModalState(() {
                                      selectedBean = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: brightOrange),
                          onPressed: () =>
                              _showAddBeanDialog(context, setModalState),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Recommended Grind Size Display (no dropdown, just info)
                    Text(
                      "Recommended Grind Size:",
                      style: TextStyle(fontSize: 18, color: brightOrange),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: mediumBrown,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: orangeBrown.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            recommendedGrindSize,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            Icons.info_outline,
                            color: brightOrange,
                            size: 20,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Water and coffee amount sliders in a card
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: orangeBrown.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Brew Ratio",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: brightOrange,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: darkBrown,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "1:${(waterAmount / coffeeAmount).toStringAsFixed(1)}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: brightOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.coffee,
                                            size: 14, color: brightOrange),
                                        SizedBox(width: 4),
                                        Text(
                                          "Coffee: $coffeeAmount g",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: brightOrange,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: darkBrown,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        Container(
                                          height: 8,
                                          width: (coffeeAmount - 10) /
                                              30 *
                                              MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          decoration: BoxDecoration(
                                            color: brightOrange,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Slider(
                                      value: coffeeAmount.toDouble(),
                                      min: 10,
                                      max: 40,
                                      divisions: 30,
                                      activeColor: brightOrange,
                                      inactiveColor:
                                          orangeBrown.withOpacity(0.3),
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
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Water: $waterAmount ml",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: brightOrange,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: darkBrown,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        Container(
                                          height: 8,
                                          width: (waterAmount - 150) /
                                              850 *
                                              MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          decoration: BoxDecoration(
                                            color:
                                                brightOrange.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Water slider (read-only)
                                    Slider(
                                      value: waterAmount.toDouble(),
                                      min: 150,
                                      max: 1000,
                                      divisions: 17,
                                      activeColor:
                                          brightOrange.withOpacity(0.3),
                                      inactiveColor:
                                          orangeBrown.withOpacity(0.2),
                                      onChanged:
                                          null, // Makes the slider read-only
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Spacer(),

                    // Buttons with updated design
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade800,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
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
                              foregroundColor: darkBrown,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
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

  void _showAddBeanDialog(BuildContext context, StateSetter setModalState) {
    String newBean = "";
    String selectedAddRegion = selectedRegion;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: darkBrown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Add New Bean",
                style: TextStyle(color: brightOrange),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Region:",
                      style: TextStyle(color: brightOrange),
                    ),
                    SizedBox(height: 8),
                    _buildDropdown(
                      value: selectedAddRegion,
                      items: beanLibrary.regions
                          .map((region) => region.name)
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedAddRegion = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Bean Name:",
                      style: TextStyle(color: brightOrange),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      onChanged: (value) {
                        newBean = value;
                      },
                      decoration: InputDecoration(
                        hintText: "e.g., Guatemala Huehuetenango",
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: mediumBrown,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brightOrange,
                    foregroundColor: darkBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (newBean.trim().isNotEmpty) {
                      // Add the new bean to the selected region
                      final beanService = BeanLibraryService();
                      await beanService.addCountryToRegion(
                          selectedAddRegion, newBean.trim());

                      // Refresh the bean library
                      final updatedLibrary = await beanService.getBeanLibrary();

                      // Update state in both dialogs
                      setModalState(() {
                        beanLibrary = updatedLibrary;
                        selectedBean = newBean.trim();
                        selectedRegion = selectedAddRegion;
                      });

                      // Also update the main state
                      setState(() {
                        beanLibrary = updatedLibrary;
                      });

                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    "Add Bean",
                    style: TextStyle(
                        color: darkBrown, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
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
    // If items list is empty or doesn't contain the value, provide a fallback
    if (items.isEmpty) {
      items = ["No options available"];
    }
    if (!items.contains(value)) {
      value = items[0];
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: mediumBrown,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: orangeBrown.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: darkBrown,
        underline: SizedBox(),
        style: TextStyle(color: Colors.white, fontSize: 16),
        icon: Icon(Icons.keyboard_arrow_down, color: brightOrange),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                color: item == value ? brightOrange : Colors.white,
                fontWeight: item == value ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCompletionScreen() {
    // Track rating state
    int rating = 4; // Default rating
    TextEditingController notesController = TextEditingController();

    // Calculate the height constraints to avoid overflow
    final double screenHeight = MediaQuery.of(context).size.height;

    return StatefulBuilder(
      builder: (context, setInnerState) {
        return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20), // Reduced padding to prevent overflow
          height: screenHeight * 0.6, // Control the height to prevent overflow
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                brightOrange.withOpacity(0.8),
                brightOrange.withOpacity(0.5),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Achievement badge
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80, // Reduced size
                    height: 80, // Reduced size
                    decoration: BoxDecoration(
                      color: darkBrown,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.amber,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.emoji_events,
                    size: 50, // Reduced size
                    color: Colors.amber,
                  ),
                ],
              ),

              SizedBox(height: 16), // Reduced spacing

              // Brew complete card
              Container(
                padding: EdgeInsets.all(12), // Reduced padding
                decoration: BoxDecoration(
                  color: darkBrown.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      "Congratulations!",
                      style: TextStyle(
                        fontSize: 24, // Reduced font size
                        fontWeight: FontWeight.bold,
                        color: brightOrange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8), // Reduced spacing
                    Text(
                      "You've successfully brewed a $selectedMethod using $selectedBean beans!",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16), // Reduced spacing

              // Rating system with improved visuals
              Container(
                padding: EdgeInsets.all(12), // Reduced padding
                decoration: BoxDecoration(
                  color: darkBrown.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      "How was your coffee?",
                      style: TextStyle(
                        fontSize: 18, // Slightly smaller font size
                        fontWeight: FontWeight.bold,
                        color: brightOrange,
                      ),
                    ),
                    SizedBox(height: 12), // Reduced spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setInnerState(() {
                              rating = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4.0), // Reduced padding
                            child: Icon(
                              Icons.star,
                              size: 30, // Smaller icons
                              color: index < rating
                                  ? Colors.amber
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 12), // Reduced spacing

                    // Notes field with improved styling
                    TextField(
                      controller: notesController,
                      maxLines: 2, // Reduced lines
                      decoration: InputDecoration(
                        hintText: "Add notes about this brew (optional)",
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        fillColor: mediumBrown.withOpacity(0.8),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(12), // Reduced padding
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: brightOrange.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: brightOrange),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              Spacer(),

              // Save button with enhanced styling
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBrown,
                  foregroundColor: brightOrange,
                  minimumSize: Size(double.infinity, 50), // Reduced height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: brightOrange, width: 2),
                  elevation: 5,
                ),
                onPressed: () {
                  // Create a BrewHistory object with the current details
                  final BrewHistory newBrew = BrewHistory(
                    id: Uuid().v4(),
                    brewMethod: selectedMethod,
                    beanType: selectedBean,
                    grindSize: recommendedGrindSize,
                    waterAmount: waterAmount,
                    coffeeAmount: coffeeAmount,
                    brewDate: DateTime.now(),
                    rating: rating,
                    notes: notesController.text,
                  );

                  // Save to history using the BrewDataService
                  BrewDataService().saveBrewHistory(newBrew).then((_) {
                    setState(() {
                      showGuide = false;
                      _showBrewSavedDialog();
                    });
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_alt, color: brightOrange),
                    SizedBox(width: 8),
                    Text(
                      "Save to My Brews",
                      style: TextStyle(
                        fontSize: 16, // Reduced font size
                        fontWeight: FontWeight.bold,
                        color: brightOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBrewSavedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkBrown,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: EdgeInsets.all(20),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: brightOrange, size: 28),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                "Brew Saved!",
                style: TextStyle(
                  color: brightOrange,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success animation (coffee cup icon)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: mediumBrown,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.coffee, color: brightOrange, size: 48),
              ),
              SizedBox(height: 16),

              // Message with styled container
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: mediumBrown,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: brightOrange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      "Your brew has been saved to your history and shared with your followers!",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),

                    // Divider
                    Container(
                      height: 1,
                      color: brightOrange.withOpacity(0.3),
                      margin: EdgeInsets.symmetric(vertical: 8),
                    ),

                    // Stats with icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_fire_department,
                            color: brightOrange, size: 20),
                        SizedBox(width: 5),
                        Text(
                          "Coffee Streak: +1",
                          style: TextStyle(
                              color: brightOrange, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.coffee, color: brightOrange, size: 20),
                        SizedBox(width: 5),
                        Text(
                          "Coffees Made: +1",
                          style: TextStyle(
                              color: brightOrange, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Social actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextButton.icon(
                  icon: Icon(Icons.history, color: Colors.grey),
                  label: Text("View History",
                      style: TextStyle(color: Colors.grey)),
                  onPressed: () {
                    // Navigate to history page
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BrewHistoryPage()),
                    );
                  },
                ),
              ),
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.check, color: darkBrown),
                  label: Text("Done", style: TextStyle(color: darkBrown)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brightOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 65, // Fixed height for bottom navigation bar
      decoration: BoxDecoration(
        color: darkBrown,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
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
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    nextPage,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                      position: offsetAnimation, child: child);
                },
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
        ),
      ),
    );
  }
}
