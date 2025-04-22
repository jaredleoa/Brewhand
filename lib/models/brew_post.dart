import 'package:brewhand/models/brew_history.dart';

class BrewComment {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;

  BrewComment({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  factory BrewComment.fromJson(Map<String, dynamic> json) {
    return BrewComment(
      id: json['id'],
      userId: json['user_id'],
      username: json['username'],
      content: json['content'],
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'])
          : json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class BrewPost {
  final String id;
  final String userId;
  final String username;
  final DateTime createdAt;
  final DateTime postDate;
  final String brewMethod;
  final String beanType;
  final String grindSize;
  final int waterAmount;
  final int coffeeAmount;
  final int likes;
  final List<BrewComment> comments;
  final String? image;
  final String? caption;
  final int rating;

  BrewPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.createdAt,
    required this.postDate,
    required this.brewMethod,
    required this.beanType,
    required this.grindSize,
    required this.waterAmount,
    required this.coffeeAmount,
    this.likes = 0,
    this.comments = const [],
    this.image,
    this.caption,
    required this.rating,
  });

  // Factory constructor to create from JSON
  factory BrewPost.fromJson(Map<String, dynamic> json) {
    List<BrewComment> commentsList = [];
    if (json['comments'] != null) {
      if (json['comments'] is List) {
        commentsList = (json['comments'] as List)
            .map((item) => BrewComment.fromJson(item))
            .toList();
      }
    }

    return BrewPost(
      id: json['id'],
      userId: json['user_id'],
      username: json['username'] ?? 'Anonymous',
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'])
          : json['created_at'],
      postDate: json['post_date'] is String
          ? DateTime.parse(json['post_date'])
          : (json['post_date'] ?? DateTime.now()),
      brewMethod: json['brew_method'],
      beanType: json['bean_type'],
      grindSize: json['grind_size'],
      waterAmount: json['water_amount'],
      coffeeAmount: json['coffee_amount'],
      likes: json['likes'] ?? 0,
      comments: commentsList,
      image: json['image'],
      caption: json['caption'],
      rating: json['rating'] ?? 0,
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'created_at': createdAt.toIso8601String(),
      'post_date': postDate.toIso8601String(),
      'brew_method': brewMethod,
      'bean_type': beanType,
      'grind_size': grindSize,
      'water_amount': waterAmount,
      'coffee_amount': coffeeAmount,
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'image': image,
      'caption': caption,
      'rating': rating,
    };
  }

  // Create a BrewPost from a BrewHistory
  factory BrewPost.fromBrewHistory(
    String id,
    String userId,
    String username,
    BrewHistory brew, {
    String? caption,
    String? image,
  }) {
    return BrewPost(
      id: id,
      userId: userId,
      username: username,
      createdAt: DateTime.now(),
      postDate: DateTime.now(),
      brewMethod: brew.brewMethod,
      beanType: brew.beanType,
      grindSize: brew.grindSize,
      waterAmount: brew.waterAmount,
      coffeeAmount: brew.coffeeAmount,
      likes: 0,
      comments: [],
      image: image,
      caption: caption,
      rating: brew.rating,
    );
  }
}
