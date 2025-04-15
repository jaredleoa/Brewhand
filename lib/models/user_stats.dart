import 'package:brewhand/models/brew_history.dart';
import 'package:flutter/foundation.dart';

// User stats class to track coffee statistics
class UserStats {
  int coffeeStreak;
  int coffeesMade;
  int uniqueDrinks;
  int uniqueBeans;
  List<String> beansUsed;
  List<String> methodsUsed;
  String? lastBrewDate; // Store the date of the last brew (YYYY-MM-DD format)

  UserStats({
    this.coffeeStreak = 0,
    this.coffeesMade = 0,
    this.uniqueDrinks = 0,
    this.uniqueBeans = 0,
    this.beansUsed = const [],
    this.methodsUsed = const [],
    this.lastBrewDate,
  });

  // Update stats when a new brew is completed
  void updateWithNewBrew(BrewHistory brew) {
    // Increment coffees made
    coffeesMade++;

    // Check if this is a new bean and update uniqueBeans
    if (!beansUsed.contains(brew.beanType)) {
      beansUsed.add(brew.beanType);
      uniqueBeans = beansUsed.length;
    }

    // Check if this is a new method and update uniqueDrinks
    if (!methodsUsed.contains(brew.brewMethod)) {
      methodsUsed.add(brew.brewMethod);
      uniqueDrinks = methodsUsed.length;
    }

    // Update streak based on the brew date
    updateStreak(brew.brewDate);
  }

  // Function to check and update streak
  void updateStreak(DateTime brewDate) {
    // Format the current brew date to YYYY-MM-DD format for day comparison
    final String formattedBrewDate = _formatDateToYYYYMMDD(brewDate);
    
    // Format current date for debugging output
    final String today = _formatDateToYYYYMMDD(DateTime.now());
    
    debugPrint('Updating streak. Today: $today, Brew date: $formattedBrewDate, Last brew date: $lastBrewDate');
    
    if (lastBrewDate == null) {
      // First time brewing, start streak at 1
      coffeeStreak = 1;
    } else if (formattedBrewDate == lastBrewDate) {
      // Already had coffee today, streak remains the same
      debugPrint('Already had coffee today, streak remains at $coffeeStreak');
    } else {
      // Convert dates to DateTime objects for comparison
      final DateTime lastBrewDateTime = _parseYYYYMMDD(lastBrewDate!);
      final DateTime brewDateTime = _parseYYYYMMDD(formattedBrewDate);
      
      // Calculate the difference in days
      final difference = brewDateTime.difference(lastBrewDateTime).inDays;
      
      if (difference == 1) {
        // Coffee on consecutive days, increment streak
        coffeeStreak++;
        debugPrint('Coffee on consecutive days, streak now: $coffeeStreak');
      } else if (difference > 1) {
        // Missed a day, reset streak to 1
        coffeeStreak = 1;
        debugPrint('Missed ${difference - 1} days, streak reset to 1');
      }
    }
    
    // Update the last brew date
    lastBrewDate = formattedBrewDate;
  }
  
  // Helper method to format date to YYYY-MM-DD
  String _formatDateToYYYYMMDD(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  // Helper method to parse YYYY-MM-DD string into DateTime
  DateTime _parseYYYYMMDD(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]), 
      int.parse(parts[1]), 
      int.parse(parts[2])
    );
  }

  // Factory constructor to create from JSON
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      coffeeStreak: json['coffeeStreak'] ?? 0,
      coffeesMade: json['coffeesMade'] ?? 0,
      uniqueDrinks: json['uniqueDrinks'] ?? 0,
      uniqueBeans: json['uniqueBeans'] ?? 0,
      beansUsed: List<String>.from(json['beansUsed'] ?? []),
      methodsUsed: List<String>.from(json['methodsUsed'] ?? []),
      lastBrewDate: json['lastBrewDate'],
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'coffeeStreak': coffeeStreak,
      'coffeesMade': coffeesMade,
      'uniqueDrinks': uniqueDrinks,
      'uniqueBeans': uniqueBeans,
      'beansUsed': beansUsed,
      'methodsUsed': methodsUsed,
      'lastBrewDate': lastBrewDate,
    };
  }
  
  // Method to check if the streak should be reset based on today's date
  // This should be called when loading the stats, to handle the case where
  // the user hasn't brewed coffee for more than a day
  void checkStreakReset() {
    if (lastBrewDate == null) return;
    
    final DateTime now = DateTime.now();
    final DateTime lastBrewDateTime = _parseYYYYMMDD(lastBrewDate!);
    
    // Calculate days since last brew
    final difference = now.difference(lastBrewDateTime).inDays;
    
    if (difference > 1) {
      // If it's been more than 1 day since the last brew, reset the streak
      debugPrint('No coffee for $difference days, resetting streak to 0');
      coffeeStreak = 0;
    }
  }
}
