import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brewhand/models/brew_history.dart';
import 'package:brewhand/services/brew_data_service.dart';
import 'package:intl/intl.dart';
import 'brew_master_page.dart';

class BrewHistoryPage extends StatefulWidget {
  @override
  _BrewHistoryPageState createState() => _BrewHistoryPageState();
}

class _BrewHistoryPageState extends State<BrewHistoryPage> {
  final Color darkBrown = Color(0xFF3E1F00);
  final Color mediumBrown = Color(0xFF60300F);
  final Color orangeBrown = Color(0xFFA95E04);
  final Color brightOrange = Color(0xFFFF9800);

  List<BrewHistory> brewHistory = [];
  List<BrewHistory> filteredBrewHistory = [];
  bool isLoading = true;
  
  // Filter state variables
  String currentFilter = "All Brews";
  bool isHighestRatedFilter = false;
  bool isLast30DaysFilter = false;

  @override
  void initState() {
    super.initState();
    _loadBrewHistory();
  }

  Future<void> _loadBrewHistory() async {
    try {
      final BrewDataService dataService = BrewDataService();
      final history = await dataService.getBrewHistory();

      setState(() {
        brewHistory = history;
        // Initialize filtered list with all brews
        filteredBrewHistory = List.from(history);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading brew history: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  
  // Apply filters based on current filter settings
  void _applyFilters() {
    setState(() {
      // Start with all brews
      filteredBrewHistory = List.from(brewHistory);
      
      // Apply method filter if not "All Brews"
      if (currentFilter != "All Brews") {
        filteredBrewHistory = filteredBrewHistory
            .where((brew) => brew.brewMethod == currentFilter)
            .toList();
      }
      
      // Apply highest rated filter
      if (isHighestRatedFilter) {
        filteredBrewHistory.sort((a, b) => b.rating.compareTo(a.rating));
        // Keep only top rated brews (rating 4 or higher)
        filteredBrewHistory = filteredBrewHistory
            .where((brew) => brew.rating >= 4)
            .toList();
      }
      
      // Apply last 30 days filter
      if (isLast30DaysFilter) {
        final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
        filteredBrewHistory = filteredBrewHistory
            .where((brew) => brew.brewDate.isAfter(thirtyDaysAgo))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBrown,
      appBar: AppBar(
        title: Text(
          "Brew History",
          style: TextStyle(color: brightOrange, fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkBrown,
        elevation: 0,
        iconTheme: IconThemeData(color: brightOrange),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: brightOrange),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: brightOrange))
          : brewHistory.isEmpty
              ? _buildEmptyState()
              : _buildBrewHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/coffee_cup.svg",
            width: 80,
            height: 80,
            colorFilter:
                ColorFilter.mode(orangeBrown.withOpacity(0.6), BlendMode.srcIn),
          ),
          SizedBox(height: 24),
          Text(
            "No Brews Yet",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: brightOrange,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Start brewing with Brew Master to record your coffee journey",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: brightOrange,
              foregroundColor: darkBrown,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: Icon(Icons.coffee_maker, color: darkBrown),
            label: Text(
              "Start Brewing",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkBrown,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              // Explicitly navigate to Brew Master page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BrewMasterPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBrewHistoryList() {
    // Apply filters if not already applied
    if (filteredBrewHistory.isEmpty && brewHistory.isNotEmpty) {
      _applyFilters();
    }
    
    // Check if filtered list is empty after applying filters
    if (filteredBrewHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_alt_off, size: 60, color: orangeBrown.withOpacity(0.6)),
            SizedBox(height: 24),
            Text(
              "No matches found",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: brightOrange,
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Try adjusting your filters",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredBrewHistory.length,
      itemBuilder: (context, index) {
        final brew = filteredBrewHistory[index];
        return _buildBrewCard(brew);
      },
    );
  }

  Widget _buildBrewCard(BrewHistory brew) {
    // Format the date
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final formattedDate = dateFormat.format(brew.brewDate);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Method and Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brew.brewMethod,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating stars
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < brew.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Bean and Grind Size
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem("Bean", brew.beanType),
                    ),
                    Expanded(
                      child: _buildDetailItem("Grind", brew.grindSize),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Coffee and Water Amount
                Row(
                  children: [
                    Expanded(
                      child:
                          _buildDetailItem("Coffee", "${brew.coffeeAmount} g"),
                    ),
                    Expanded(
                      child:
                          _buildDetailItem("Water", "${brew.waterAmount} ml"),
                    ),
                  ],
                ),

                // Notes (if any)
                if (brew.notes.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: darkBrown.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Notes:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: brightOrange,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          brew.notes,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(Icons.repeat, size: 18),
                  label: Text("Brew Again"),
                  onPressed: () {
                    // Navigate to Brew Master page with these settings
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BrewMasterPage(
                          initialBrewMethod: brew.brewMethod,
                          initialBeanType: brew.beanType,
                          initialGrindSize: brew.grindSize,
                          initialWaterAmount: brew.waterAmount,
                          initialCoffeeAmount: brew.coffeeAmount,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(Icons.share, size: 18),
                  label: Text("Share"),
                  onPressed: () {
                    // Logic to share this brew
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Row(
      children: [
        Icon(
          _getIconForDetail(label),
          size: 16,
          color: brightOrange,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconForDetail(String label) {
    switch (label) {
      case "Bean":
        return Icons.coffee;
      case "Grind":
        return Icons.grid_4x4;
      case "Coffee":
        return Icons.scale;
      case "Water":
        return Icons.water_drop;
      default:
        return Icons.info;
    }
  }

  void _showFilterDialog() {
    // Create local variables to track filter state during dialog
    String tempFilter = currentFilter;
    bool tempHighestRated = isHighestRatedFilter;
    bool tempLast30Days = isLast30DaysFilter;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: darkBrown,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Filter Brews",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: brightOrange,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Filter options for brewing methods
                  GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        tempFilter = "All Brews";
                      });
                    },
                    child: _buildFilterOption("All Brews", tempFilter == "All Brews"),
                  ),
                  GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        tempFilter = "French Press";
                      });
                    },
                    child: _buildFilterOption("French Press", tempFilter == "French Press"),
                  ),
                  GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        tempFilter = "Pour Over";
                      });
                    },
                    child: _buildFilterOption("Pour Over", tempFilter == "Pour Over"),
                  ),
                  GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        tempFilter = "AeroPress";
                      });
                    },
                    child: _buildFilterOption("AeroPress", tempFilter == "AeroPress"),
                  ),
                  GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        tempFilter = "Espresso";
                      });
                    },
                    child: _buildFilterOption("Espresso", tempFilter == "Espresso"),
                  ),
                  
                  Divider(color: orangeBrown.withOpacity(0.3)),
                  
                  // Additional filter options
                  GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        tempHighestRated = !tempHighestRated;
                      });
                    },
                    child: _buildFilterOption("Highest Rated", tempHighestRated),
                  ),
                  GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        tempLast30Days = !tempLast30Days;
                      });
                    },
                    child: _buildFilterOption("Last 30 Days", tempLast30Days),
                  ),

                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade800,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel"),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brightOrange,
                            foregroundColor: darkBrown,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // Apply filters and close dialog
                            setState(() {
                              currentFilter = tempFilter;
                              isHighestRatedFilter = tempHighestRated;
                              isLast30DaysFilter = tempLast30Days;
                            });
                            _applyFilters(); // Apply the new filters
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Apply Filters",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: isSelected ? brightOrange : Colors.white,
            size: 20,
          ),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
