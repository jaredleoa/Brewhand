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

// Social post model for the Brew Social feed
class BrewPost {
  final String userId;
  final String username;
  final String brewMethod;
  final String beanType;
  final DateTime postDate;
  final String id;
  final int likes;
  final List<String> comments;
  final String? image;

  BrewPost({
    required this.userId,
    required this.username,
    required this.brewMethod,
    required this.beanType,
    required this.postDate,
    required this.id,
    this.likes = 0,
    this.comments = const [],
    this.image,
  });

  // Factory constructor to create from JSON
  factory BrewPost.fromJson(Map<String, dynamic> json) {
    return BrewPost(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      brewMethod: json['brewMethod'],
      beanType: json['beanType'],
      postDate: DateTime.parse(json['postDate']),
      likes: json['likes'] ?? 0,
      comments: List<String>.from(json['comments'] ?? []),
      image: json['image'],
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'brewMethod': brewMethod,
      'beanType': beanType,
      'postDate': postDate.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'image': image,
    };
  }
}
