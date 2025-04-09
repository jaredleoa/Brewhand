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
  bool isLoading = true;

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
        isLoading = false;
      });
    } catch (e) {
      print('Error loading brew history: $e');
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
    // Sort brews by date (newest first)
    brewHistory.sort((a, b) => b.brewDate.compareTo(a.brewDate));

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: brewHistory.length,
      itemBuilder: (context, index) {
        final brew = brewHistory[index];
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
                    // Logic to start brewing with these settings
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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

              // Filter options
              _buildFilterOption("All Brews", true),
              _buildFilterOption("French Press", false),
              _buildFilterOption("Pour Over", false),
              _buildFilterOption("AeroPress", false),
              _buildFilterOption("Espresso", false),
              Divider(color: orangeBrown.withOpacity(0.3)),
              _buildFilterOption("Highest Rated", false),
              _buildFilterOption("Last 30 Days", false),

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
