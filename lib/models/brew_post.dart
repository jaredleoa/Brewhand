/// Social Sharing Models
/// 
/// Contains models for the social features of the BrewHand application,
/// including posts shared by users and comments on those posts.
/// Maps to the 'brew_posts' and 'brew_comments' tables in the Supabase database.

import 'package:brewhand/models/brew_history.dart';

/// Comment on a shared brewing post
/// 
/// Represents a user comment on a BrewPost in the social feed.
/// Contains the comment content, author information, and metadata.
class BrewComment {
  /// Unique identifier for the comment
  final String id;
  
  /// User ID of the comment author
  final String userId;
  
  /// Username of the comment author
  final String username;
  
  /// Text content of the comment
  final String content;
  
  /// Timestamp when the comment was created
  final DateTime createdAt;

  BrewComment({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  /// Creates a BrewComment instance from a JSON map
  /// 
  /// Used to convert database records or API responses into BrewComment objects.
  /// 
  /// Parameters:
  /// - [json]: Map containing the comment data
  /// 
  /// Returns a new BrewComment instance populated with the data from the map
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

/// Social post of a brewing session
/// 
/// Represents a coffee brewing session that has been shared to the social feed.
/// Contains brewing parameters, user information, and social interaction data.
class BrewPost {
  /// Unique identifier for the post
  final String id;
  
  /// User ID of the post author
  final String userId;
  
  /// Username of the post author
  final String username;
  
  /// Timestamp when the post was created in the database
  final DateTime createdAt;
  
  /// Date when the brewing session occurred (may differ from createdAt)
  final DateTime postDate;
  
  /// Brewing method used (e.g., "Pour Over", "Espresso")
  final String brewMethod;
  
  /// Type of coffee beans used
  final String beanType;
  
  /// Coarseness of the coffee grind
  final String grindSize;
  
  /// Amount of water used in milliliters
  final int waterAmount;
  
  /// Amount of coffee used in grams
  final int coffeeAmount;
  
  /// Number of likes the post has received
  final int likes;
  
  /// List of comments on the post
  final List<BrewComment> comments;
  
  /// Optional URL to an image of the coffee or brewing process
  final String? image;
  
  /// Optional text description provided by the user
  final String? caption;
  
  /// User rating of the brew on a scale (typically 1-5)
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
  /// Creates a BrewPost instance from a JSON map
  /// 
  /// Used to convert database records or API responses into BrewPost objects.
  /// Handles nested comment data if present.
  /// 
  /// Parameters:
  /// - [json]: Map containing the post data
  /// 
  /// Returns a new BrewPost instance populated with the data from the map
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

  /// Creates a BrewPost from a BrewHistory object
  /// 
  /// Converts a private brewing record into a social post format.
  /// Used when a user decides to share their brewing experience.
  /// 
  /// Parameters:
  /// - [brew]: The BrewHistory object to convert
  /// - [userId]: ID of the user sharing the post
  /// - [username]: Username of the user sharing the post
  /// - [caption]: Optional text description for the post
  /// - [image]: Optional image URL for the post
  /// 
  /// Returns a new BrewPost instance populated with data from the BrewHistory
  factory BrewPost.fromBrewHistory(BrewHistory brew, String userId, String username, {String? caption, String? image}) {
    return BrewPost(
      id: brew.id,
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
