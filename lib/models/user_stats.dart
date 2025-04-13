import 'package:brewhand/models/brew_history.dart';

// User stats class to track coffee statistics
class UserStats {
  int coffeeStreak;
  int coffeesMade;
  int uniqueDrinks;
  int uniqueBeans;
  List<String> beansUsed;
  List<String> methodsUsed;

  UserStats({
    this.coffeeStreak = 0,
    this.coffeesMade = 0,
    this.uniqueDrinks = 0,
    this.uniqueBeans = 0,
    this.beansUsed = const [],
    this.methodsUsed = const [],
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

    // Update streak (in a real app, check if the last brew was yesterday)
    updateStreak(brew.brewDate);
  }

  // Function to check and update streak
  void updateStreak(DateTime brewDate) {
    // This is simplified - in a real app, you'd compare with the last brew date
    // to see if the streak should continue, reset, or increment
    coffeeStreak++;
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
    };
  }
}
