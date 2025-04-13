class BrewPost {
  final String id;
  final String userId;
  final DateTime postDate;
  final String brewMethod;
  final String beanType;
  final String grindSize;
  final int waterAmount;
  final int coffeeAmount;
  final int likes;
  final List<String> comments;
  final String? image;

  BrewPost({
    required this.id,
    required this.userId,
    required this.postDate,
    required this.brewMethod,
    required this.beanType,
    required this.grindSize,
    required this.waterAmount,
    required this.coffeeAmount,
    this.likes = 0,
    this.comments = const [],
    this.image,
  });

  // Factory constructor to create from JSON
  factory BrewPost.fromJson(Map<String, dynamic> json) {
    return BrewPost(
      id: json['id'],
      userId: json['userId'],
      postDate: json['postDate'] is String
          ? DateTime.parse(json['postDate'])
          : json['postDate'],
      brewMethod: json['brewMethod'],
      beanType: json['beanType'],
      grindSize: json['grindSize'],
      waterAmount: json['waterAmount'],
      coffeeAmount: json['coffeeAmount'],
      likes: json['likes'] ?? 0,
      comments: (json['comments'] as List?)
          ?.map((item) => item.toString())
          .toList() ?? [],
      image: json['image'],
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'postDate': postDate.toIso8601String(),
      'brewMethod': brewMethod,
      'beanType': beanType,
      'grindSize': grindSize,
      'waterAmount': waterAmount,
      'coffeeAmount': coffeeAmount,
      'likes': likes,
      'comments': comments,
      'image': image,
    };
  }
}
