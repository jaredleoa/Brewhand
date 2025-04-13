class BrewHistory {
  final String brewMethod;
  final String beanType;
  final String grindSize;
  final int waterAmount;
  final int coffeeAmount;
  final DateTime brewDate;
  final int rating;
  final String notes;
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

  // Factory constructor to create from JSON
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

  // Method to convert to JSON
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

// Note: UserStats model moved to its own file: user_stats.dart

// Note: BrewPost model moved to its own file: brew_post.dart
