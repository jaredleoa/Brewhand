/// User Statistics Model
/// 
/// Tracks and manages user activity statistics related to coffee brewing.
/// Includes metrics like streaks, counts, and variety of brewing methods and beans used.
/// Maps to the 'user_stats' table in the Supabase database.

import 'package:brewhand/models/brew_history.dart';
import 'package:flutter/foundation.dart';
class UserStats {
  /// Current consecutive days streak of brewing coffee
  int coffeeStreak;
  
  /// Total number of coffee brewing sessions recorded
  int coffeesMade;
  
  /// Number of different brewing methods the user has tried
  int uniqueDrinks;
  
  /// Number of different coffee bean types the user has used
  int uniqueBeans;
  
  /// List of all bean types the user has brewed with
  List<String> beansUsed;
  
  /// List of all brewing methods the user has used
  List<String> methodsUsed;
  
  /// Date of the last recorded brew in YYYY-MM-DD format
  /// Used for streak calculations
  String? lastBrewDate;

  UserStats({
    this.coffeeStreak = 0,
    this.coffeesMade = 0,
    this.uniqueDrinks = 0,
    this.uniqueBeans = 0,
    this.beansUsed = const [],
    this.methodsUsed = const [],
    this.lastBrewDate,
  });

  /// Updates user statistics when a new brewing session is completed
  /// 
  /// Increments counters, updates lists of beans and methods used,
  /// and recalculates the user's brewing streak.
  /// 
  /// Parameters:
  /// - [brew]: The BrewHistory object representing the new brewing session
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

  /// Updates the user's coffee brewing streak based on the date of a new brew
  /// 
  /// Calculates whether the streak should increase, reset, or remain unchanged
  /// based on the relationship between the brew date and the last recorded brew.
  /// 
  /// Parameters:
  /// - [brewDate]: The date of the new brewing session
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
  
  /// Formats a DateTime to YYYY-MM-DD string format
  /// 
  /// Used for date comparisons when calculating streaks.
  /// 
  /// Parameters:
  /// - [date]: The DateTime to format
  /// 
  /// Returns a string in YYYY-MM-DD format
  String _formatDateToYYYYMMDD(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// Parses a YYYY-MM-DD string into a DateTime object
  /// 
  /// Used for date comparisons when calculating streaks.
  /// 
  /// Parameters:
  /// - [dateStr]: The string to parse
  /// 
  /// Returns a DateTime object
  DateTime _parseYYYYMMDD(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]), 
      int.parse(parts[1]), 
      int.parse(parts[2])
    );
  }

  /// Creates a UserStats instance from a JSON map
  /// 
  /// Used to convert database records or API responses into UserStats objects.
  /// 
  /// Parameters:
  /// - [json]: Map containing the user statistics data
  /// 
  /// Returns a new UserStats instance populated with the data from the map
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

  /// Converts this UserStats instance to a JSON map
  /// 
  /// Used when sending user statistics data to the database or API.
  /// 
  /// Returns a Map with the user statistics in the correct format for storage
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
