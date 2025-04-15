import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brewhand/models/coffee_region.dart';
import 'package:brewhand/pages/brew_history_page.dart';
import 'package:brewhand/models/brew_history.dart';
import 'package:brewhand/services/bean_library_service.dart';
import 'package:brewhand/services/brew_data_service.dart';
import 'package:brewhand/pages/my_brews_page.dart';
import 'package:brewhand/pages/brew_bot_page.dart';
import 'package:brewhand/pages/brew_social_page.dart';
import 'package:brewhand/widgets/brew_timer.dart';
import 'package:uuid/uuid.dart';
import 'package:brewhand/widgets/animated_scale.dart';

class BrewMasterPage extends StatefulWidget {
  // Optional parameters for the "Brew Again" functionality
  final String? initialBrewMethod;
  final String? initialBeanType;
  final String? initialGrindSize;
  final int? initialWaterAmount;
  final int? initialCoffeeAmount;

  const BrewMasterPage({
    Key? key,
    this.initialBrewMethod,
    this.initialBeanType,
    this.initialGrindSize,
    this.initialWaterAmount,
    this.initialCoffeeAmount,
  }) : super(key: key);

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
    'description': 'Rich, full-bodied coffee with a simple brewing process',
    'time': '4 min',
    'difficulty': 'Easy',
    'recommendedGrind': 'Coarse',
    'flavorNotes': 'Full-bodied, High Extraction',
  },
  {
    'name': 'Pour Over',
    'description': 'Clean, bright coffee with clear flavors',
    'time': '3 min',
    'difficulty': 'Medium',
    'recommendedGrind': 'Medium-Fine',
    'flavorNotes': 'Clean, Bright Acidity',
  },
  {
    'name': 'AeroPress',
    'description': 'Smooth coffee with versatile brewing options',
    'time': '2 min',
    'difficulty': 'Easy',
    'recommendedGrind': 'Fine',
    'flavorNotes': 'Versatile, Low Acidity',
  },
  {
    'name': 'Espresso',
    'description': 'Concentrated coffee with rich crema',
    'time': '1 min',
    'difficulty': 'Hard',
    'recommendedGrind': 'Extra Fine',
    'flavorNotes': 'Concentrated, Rich Crema',
  },
  {
    'name': 'Moka Pot',
    'description': 'Stovetop coffee with rich, robust flavor',
    'time': '5 min',
    'difficulty': 'Medium',
    'recommendedGrind': 'Fine',
    'flavorNotes': 'Strong, Intense Body',
  },
  {
    'name': 'Cold Brew',
    'description': 'Smooth, refreshing coffee brewed cold over hours',
    'time': '8 hr',
    'difficulty': 'Easy',
    'recommendedGrind': 'Coarse',
    'flavorNotes': 'Smooth, Very Low Acidity',
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

  // Difficulty filter for brewing methods
  String difficultyFilter = 'All';

  // Step lists for different brewing methods
  Map<String, List<Map<String, dynamic>>> brewingSteps = {
    'French Press': [
      {
        'text': 'Boil water to 93°C',
        'description':
            'Heat your water to the ideal temperature for French Press brewing.',
        'timer': false
      },
      {
        'text': 'Grind your coffee',
        'description': 'We recommend using Coarse grind for French Press.',
        'timer': false
      },
      {
        'text': 'Add coffee grounds',
        'description': 'Add the coffee grounds to the French press.',
        'timer': false
      },
      {
        'text': 'Pour hot water',
        'description':
            'Pour hot water over the grounds, making sure all grounds are saturated.',
        'timer': false
      },
      {
        'text': 'Stir gently',
        'description':
            'Stir gently to ensure all grounds are evenly saturated.',
        'timer': false
      },
      {
        'text': 'Let steep',
        'description':
            'Place the plunger on top but don\'t press down. Let steep for 4 minutes.',
        'timer': true,
        'duration': 240
      },
      {
        'text': 'Press plunger',
        'description': 'Slowly press the plunger down with steady pressure.',
        'timer': false
      },
      {
        'text': 'Serve and enjoy',
        'description':
            'Pour into your cup and enjoy your freshly brewed coffee!',
        'timer': false
      },
    ],
    'Pour Over': [
      {
        'text': 'Boil water to 93°C',
        'description':
            'Heat your water to the ideal temperature for Pour Over brewing.',
        'timer': false
      },
      {
        'text': 'Grind your coffee',
        'description': 'We recommend using Medium-Fine grind for Pour Over.',
        'timer': false
      },
      {
        'text': 'Prepare filter',
        'description':
            'Place filter in dripper and rinse with hot water to remove paper taste and preheat.',
        'timer': false
      },
      {
        'text': 'Add coffee grounds',
        'description':
            'Add the coffee grounds to the filter, creating an even bed.',
        'timer': false
      },
      {
        'text': 'Bloom the coffee',
        'description':
            'Pour a small amount of water (about twice the weight of coffee) to "bloom" the coffee.',
        'timer': true,
        'duration': 30
      },
      {
        'text': 'Continue pouring',
        'description':
            'Slowly pour the remaining water in a circular motion, maintaining a consistent flow.',
        'timer': false
      },
      {
        'text': 'Wait for dripping',
        'description': 'Allow all water to drip through the filter completely.',
        'timer': false
      },
      {
        'text': 'Serve and enjoy',
        'description': 'Remove filter and enjoy your freshly brewed coffee!',
        'timer': false
      },
    ],
    'AeroPress': [
      {
        'text': 'Boil water to 85°C',
        'description':
            'Heat your water to the ideal temperature for AeroPress brewing.',
        'timer': false
      },
      {
        'text': 'Grind your coffee',
        'description': 'We recommend using Fine grind for AeroPress.',
        'timer': false
      },
      {
        'text': 'Prepare filter',
        'description':
            'Place filter in AeroPress cap and rinse with hot water.',
        'timer': false
      },
      {
        'text': 'Assemble AeroPress',
        'description': 'Attach cap to AeroPress chamber and place on cup.',
        'timer': false
      },
      {
        'text': 'Add coffee grounds',
        'description': 'Add the coffee grounds to the chamber.',
        'timer': false
      },
      {
        'text': 'Add water and stir',
        'description': 'Pour hot water and stir for 10 seconds.',
        'timer': true,
        'duration': 10
      },
      {
        'text': 'Press',
        'description':
            'Insert plunger and press down gently with steady pressure.',
        'timer': false
      },
      {
        'text': 'Serve and enjoy',
        'description': 'Enjoy your freshly brewed coffee!',
        'timer': false
      },
    ],
    'Espresso': [
      {
        'text': 'Preheat machine',
        'description': 'Preheat your espresso machine thoroughly.',
        'timer': false
      },
      {
        'text': 'Grind your coffee',
        'description': 'We recommend using Extra Fine grind for Espresso.',
        'timer': false
      },
      {
        'text': 'Dose portafilter',
        'description': 'Add coffee grounds to the portafilter evenly.',
        'timer': false
      },
      {
        'text': 'Tamp grounds',
        'description': 'Tamp down the grounds with even pressure.',
        'timer': false
      },
      {
        'text': 'Lock portafilter',
        'description': 'Lock the portafilter into the machine securely.',
        'timer': false
      },
      {
        'text': 'Extract espresso',
        'description':
            'Start the extraction - aim for 25-30 seconds for optimal flavor.',
        'timer': true,
        'duration': 28
      },
      {
        'text': 'Watch crema',
        'description': 'Watch for the golden crema forming on top.',
        'timer': false
      },
      {
        'text': 'Serve and enjoy',
        'description': 'Enjoy your freshly brewed espresso!',
        'timer': false
      },
    ],
    'Moka Pot': [
      {
        'text': 'Boil water',
        'description': 'Heat water just below boiling point (90-95°C).',
        'timer': false
      },
      {
        'text': 'Grind your coffee',
        'description': 'We recommend using Fine grind for Moka Pot, similar to espresso but slightly coarser.',
        'timer': false
      },
      {
        'text': 'Fill bottom chamber',
        'description': 'Fill the bottom chamber with hot water up to the valve level.',
        'timer': false
      },
      {
        'text': 'Insert filter basket',
        'description': 'Insert the filter basket and fill with coffee grounds. Don\'t tamp or overfill.',
        'timer': false
      },
      {
        'text': 'Assemble pot',
        'description': 'Screw on the top chamber tightly. Use a towel if the bottom is hot.',
        'timer': false
      },
      {
        'text': 'Place on heat source',
        'description': 'Place on medium-low heat with the lid open to observe.',
        'timer': false
      },
      {
        'text': 'Watch for brewing',
        'description': 'Coffee will begin to flow into the top chamber. This should take 4-5 minutes.',
        'timer': true,
        'duration': 270
      },
      {
        'text': 'Remove from heat',
        'description': 'Remove from heat when you hear a gurgling sound or see the stream turning lighter in color.',
        'timer': false
      },
      {
        'text': 'Serve immediately',
        'description': 'Pour immediately and enjoy your rich, intense coffee!',
        'timer': false
      },
    ],
    'Cold Brew': [
      {
        'text': 'Grind your coffee',
        'description': 'We recommend using Coarse grind for Cold Brew to prevent over-extraction.',
        'timer': false
      },
      {
        'text': 'Measure coffee and water',
        'description': 'Use a 1:5 coffee-to-water ratio for concentrate (1:8 for ready-to-drink).',
        'timer': false
      },
      {
        'text': 'Combine in container',
        'description': 'Add coffee grounds to a large jar or cold brew maker, then add cold filtered water.',
        'timer': false
      },
      {
        'text': 'Stir gently',
        'description': 'Stir to ensure all grounds are saturated with water.',
        'timer': false
      },
      {
        'text': 'Cover and refrigerate',
        'description': 'Cover the container and place in refrigerator.',
        'timer': false
      },
      {
        'text': 'Steep for 12-24 hours',
        'description': 'Let steep for 12-24 hours. Longer steeping creates stronger coffee.',
        'timer': true,
        'duration': 43200
      },
      {
        'text': 'Filter the coffee',
        'description': 'Strain through a fine mesh sieve lined with cheesecloth or coffee filter.',
        'timer': false
      },
      {
        'text': 'Store and serve',
        'description': 'Store in refrigerator for up to 2 weeks. Serve over ice, diluted with water or milk as desired.',
        'timer': false
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadBeanLibrary();
    
    // Initialize with values from "Brew Again" if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialBrewMethod != null) {
        // Find the brewing method in the list
        for (var method in brewingMethods) {
          if (method['name'] == widget.initialBrewMethod) {
            _showBrewingSetupDialog(widget.initialBrewMethod!);
            break;
          }
        }
        
        // Set other initial values if provided
        setState(() {
          if (widget.initialBeanType != null) {
            selectedBean = widget.initialBeanType!;
          }
          
          if (widget.initialGrindSize != null) {
            recommendedGrindSize = widget.initialGrindSize!;
          }
          
          if (widget.initialWaterAmount != null) {
            waterAmount = widget.initialWaterAmount!;
          }
          
          if (widget.initialCoffeeAmount != null) {
            coffeeAmount = widget.initialCoffeeAmount!;
          }
        });
      }
    });
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
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: brightOrange))
            : showGuide
                ? SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: _buildBrewingGuide(),
                  )
                : _buildBrewingMethodsList(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBrewingMethodsList() {
    List<String> difficulties = ['All', 'Easy', 'Medium', 'Hard'];
    List<Map<String, dynamic>> filteredMethods = difficultyFilter == 'All'
        ? brewingMethods
        : brewingMethods.where((m) => m['difficulty'] == difficultyFilter).toList();
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
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: darkBrown.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: brightOrange.withOpacity(0.3), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Filter: ", 
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )
                ),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: difficultyFilter,
                  dropdownColor: darkBrown,
                  icon: Icon(Icons.arrow_drop_down, color: brightOrange),
                  underline: Container(height: 0), // Remove the underline
                  style: TextStyle(color: brightOrange, fontWeight: FontWeight.bold),
                  items: difficulties
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(d),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => difficultyFilter = value);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0, // Square cards
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredMethods.length,
              itemBuilder: (context, index) {
                return _buildBrewingMethodCard(filteredMethods[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrewingMethodCard(Map<String, dynamic> method) {
    // Get the appropriate icon based on method name
    IconData icon = Icons.coffee; // Default icon
    
    // Map method names to their corresponding Material Icons
    if (method['name'] == 'Pour Over') {
      icon = Icons.filter_alt;
    } else if (method['name'] == 'Espresso') {
      icon = Icons.local_cafe;
    } else if (method['name'] == 'Moka Pot') {
      icon = Icons.coffee_maker;
    } else if (method['name'] == 'Cold Brew') {
      icon = Icons.ac_unit;
    } else if (method['name'] == 'French Press') {
      icon = Icons.plumbing;
    } else if (method['name'] == 'AeroPress') {
      icon = Icons.compress;
    }
    
    // Card tap animation
    return AnimatedScaleOnTap(
      onTap: () {
        _showBrewingSetupDialog(method['name']);
        setState(() {
          recommendedGrindSize = method['recommendedGrind'];
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              orangeBrown.withOpacity(0.35),
              orangeBrown.withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: brightOrange.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 1.0, // Make cards square
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Material Icon
                Expanded(flex: 2, child: Center(
                  child: Icon(
                    icon,
                    size: 48,
                    color: brightOrange,
                  ),
                )),
                // Method Name
                Expanded(flex: 2, child: Center(
                  child: Text(
                    method['name'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                )),
                // Stats
                Expanded(flex: 1, child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMethodStat(Icons.timer, method['time']),
                    _buildMethodStat(Icons.trending_up, method['difficulty']),
                  ],
                )),
              ],
            ),
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
    // Get method details
    String methodDescription = '';
    String methodCharacteristics = '';
    
    for (var method in brewingMethods) {
      if (method['name'] == methodName) {
        recommendedGrindSize = method['recommendedGrind'];
        methodDescription = method['description'];
        methodCharacteristics = method['flavorNotes'];
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
              height: MediaQuery.of(context).size.height * 0.80,
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
              child: SingleChildScrollView(
                // Add SingleChildScrollView here
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Add this
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
                      SizedBox(height: 16),
                      
                      // Method description
                      Text(
                        methodDescription,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 12),
                      
                      // Method characteristics
                      Row(
                        children: [
                          Text(
                            "Characteristics: ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: brightOrange,
                            ),
                          ),
                          Text(
                            methodCharacteristics,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
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
                          border:
                              Border.all(color: orangeBrown.withOpacity(0.5)),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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

                      // Action buttons at the bottom
                      SizedBox(height: 30),
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

    return StatefulBuilder(
      builder: (context, setInnerState) {
        return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Achievement badge
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: darkBrown,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    size: 50,
                    color: Colors.amber,
                  ),
                ),

                // Brew complete card
                Container(
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: darkBrown.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Congratulations!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: brightOrange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "You've successfully brewed a $selectedMethod using $selectedBean beans!",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Rating system
                Container(
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: darkBrown.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "How was your coffee?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: brightOrange,
                        ),
                      ),
                      SizedBox(height: 12),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Icon(
                                Icons.star,
                                size: 30,
                                color: index < rating
                                    ? Colors.amber
                                    : Colors.white.withOpacity(0.3),
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 12),

                      // Notes field
                      TextField(
                        controller: notesController,
                        maxLines: 2,
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
                          contentPadding: EdgeInsets.all(12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: brightOrange.withOpacity(0.3)),
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

                // Save button
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBrown,
                      foregroundColor: brightOrange,
                      minimumSize: Size(double.infinity, 50),
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

                      // Save to history and update stats
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: brightOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

  // Add this method to your _BrewMasterPageState class in brew_master_page.dart

  Widget _buildBrewingGuide() {
    // Check if brewing is complete
    if (brewCompleted) {
      return _buildCompletionScreen();
    }

    final steps = brewingSteps[selectedMethod] ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with method name and back button
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: brightOrange),
                onPressed: () {
                  setState(() {
                    showGuide = false;
                  });
                },
              ),
              Text(
                "$selectedMethod Guide",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: brightOrange,
                ),
              ),
            ],
          ),

          // Progress indicator
          Container(
            margin: EdgeInsets.symmetric(vertical: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: steps.isEmpty ? 0 : (currentStep + 1) / steps.length,
                backgroundColor: mediumBrown,
                valueColor: AlwaysStoppedAnimation<Color>(brightOrange),
                minHeight: 10,
              ),
            ),
          ),

          // Current step card
          Container(
            margin: EdgeInsets.only(bottom: 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  orangeBrown.withOpacity(0.8),
                  orangeBrown.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: darkBrown,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${currentStep + 1}",
                          style: TextStyle(
                            color: brightOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps.isNotEmpty
                                ? "Step ${currentStep + 1}"
                                : "No steps available",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (steps.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                steps[currentStep]['text'].toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  steps.isNotEmpty
                      ? steps[currentStep]['description'].toString()
                      : "No steps available",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),

                // Add timer component for steps that require timing
                if (steps.isNotEmpty && steps[currentStep]['timer'] == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: BrewTimer(
                      durationInSeconds: steps[currentStep]['duration'] as int,
                      backgroundColor: darkBrown,
                      progressColor: brightOrange,
                      textColor: Colors.white,
                      onComplete: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("Timer completed! Ready for next step."),
                            backgroundColor: brightOrange,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Next step button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brightOrange,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              setState(() {
                if (currentStep < steps.length - 1) {
                  currentStep++;
                } else {
                  // Last step completed
                  brewCompleted = true;
                }
              });
            },
            child: Text(
              currentStep < steps.length - 1 ? "Next Step" : "Complete Brewing",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkBrown,
              ),
            ),
          ),

          if (currentStep > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: brightOrange,
                  minimumSize: Size(double.infinity, 50),
                  side: BorderSide(color: brightOrange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    if (currentStep > 0) {
                      currentStep--;
                    }
                  });
                },
                child: Text(
                  "Previous Step",
                  style: TextStyle(
                    fontSize: 16,
                    color: brightOrange,
                  ),
                ),
              ),
            ),

          // Coffee and water amount reminder
          Container(
            margin: EdgeInsets.only(top: 24),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: darkBrown.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: brightOrange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Brew Settings Reminder:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: brightOrange,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildReminderItem(
                        Icons.coffee, "Coffee", "$coffeeAmount g"),
                    _buildReminderItem(
                        Icons.water_drop, "Water", "$waterAmount ml"),
                    _buildReminderItem(
                        Icons.grain, "Grind", recommendedGrindSize),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: brightOrange, size: 20),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: brightOrange,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: darkBrown, // Set consistent background color
      ),
      child: Container(
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
        child: BottomNavigationBar(
          backgroundColor: darkBrown,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: brightOrange,
          unselectedItemColor: orangeBrown,
          showSelectedLabels: true, // Changed to true
          showUnselectedLabels: true, // Changed to true
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
                context, MaterialPageRoute(builder: (context) => nextPage));
          },
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/my_brews.svg",
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(orangeBrown, BlendMode.srcIn),
              ),
              label: "Brews",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/brew_master.svg",
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(brightOrange, BlendMode.srcIn),
              ),
              label: "Master",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/brew_bot.svg",
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(orangeBrown, BlendMode.srcIn),
              ),
              label: "Bot",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/brew_social.svg",
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(orangeBrown, BlendMode.srcIn),
              ),
              label: "Social",
            ),
          ],
        ),
      ),
    );
  }
}
