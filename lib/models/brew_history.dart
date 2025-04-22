/// Coffee Brewing Session Record
/// 
/// Represents a single coffee brewing session in the BrewHand application.
/// Stores brewing parameters, results, and user feedback for tracking and analysis.
/// Maps to the 'brew_history' table in the Supabase database.
class BrewHistory {
  /// Brewing method used (e.g., "Pour Over", "Espresso", "French Press")
  final String brewMethod;
  
  /// Type of coffee beans used (e.g., "Ethiopian", "Colombian")
  final String beanType;
  
  /// Coarseness of the coffee grind (e.g., "Fine", "Medium", "Coarse")
  final String grindSize;
  
  /// Amount of water used in milliliters
  final int waterAmount;
  
  /// Amount of coffee used in grams
  final int coffeeAmount;
  
  /// Date and time when the coffee was brewed
  final DateTime brewDate;
  
  /// User rating of the brew on a scale (typically 1-5)
  final int rating;
  
  /// Optional user notes about the brewing session
  final String notes;
  
  /// Unique identifier for the brewing session
  final String id;

  BrewHistory({
    required this.brewMethod,
    required this.beanType,
    required this.grindSize,
    required this.waterAmount,
    required this.coffeeAmount,
    required this.brewDate,
    required this.rating,
    this.notes = '',
    required this.id,
  });

  /// Creates a BrewHistory instance from a JSON map
  /// 
  /// Used to convert database records or API responses into BrewHistory objects.
  /// 
  /// Parameters:
  /// - [json]: Map containing the brewing session data with keys matching database columns
  /// 
  /// Returns a new BrewHistory instance populated with the data from the map.
  factory BrewHistory.fromJson(Map<String, dynamic> json) {
    return BrewHistory(
      id: json['id'],
      brewMethod: json['brewMethod'],
      beanType: json['beanType'],
      grindSize: json['grindSize'],
      waterAmount: json['waterAmount'],
      coffeeAmount: json['coffeeAmount'],
      brewDate: DateTime.parse(json['brewDate']),
      rating: json['rating'],
      notes: json['notes'] ?? '',
    );
  }

  /// Converts this BrewHistory instance to a JSON map
  /// 
  /// Used when sending brewing session data to the database or API.
  /// The keys in the returned map match the column names in the database.
  /// 
  /// Returns a Map with the brewing session data in the correct format for storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brewMethod': brewMethod,
      'beanType': beanType,
      'grindSize': grindSize,
      'waterAmount': waterAmount,
      'coffeeAmount': coffeeAmount,
      'brewDate': brewDate.toIso8601String(),
      'rating': rating,
      'notes': notes,
    };
  }
}

/// Note: Related models have been moved to separate files:
/// - UserStats: user_stats.dart
/// - BrewPost: brew_post.dart
