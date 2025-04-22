/// User Profile Model
/// 
/// Represents a user's profile information in the BrewHand application.
/// Maps directly to the 'profiles' table in the Supabase database.
/// Contains personal information, preferences, and profile metadata.
class UserProfile {
  /// Unique identifier for the user, matches Supabase Auth user ID
  final String id;
  
  /// User's chosen username, must be unique across the platform
  final String username;
  
  /// User's full name (optional), maps to 'full_name' column in database
  final String? fullName;
  
  /// URL to the user's profile picture (optional), maps to 'avatar_url' column
  final String? avatarUrl;
  
  /// User's self-description or biography (optional)
  final String? bio;
  
  /// User's favorite coffee brew (optional), maps to 'favorite_brew' column
  final String? favoriteBrew;
  
  /// Timestamp when the profile was created
  final DateTime createdAt;
  
  /// Timestamp when the profile was last updated
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.favoriteBrew,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a UserProfile instance from a JSON map
  /// 
  /// Used to convert database records or API responses into UserProfile objects.
  /// 
  /// Parameters:
  /// - [json]: Map containing the user profile data with keys matching database columns
  /// 
  /// Returns a new UserProfile instance populated with the data from the map.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      favoriteBrew: json['favorite_brew'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this UserProfile instance to a JSON map
  /// 
  /// Used when sending profile data to the database or API.
  /// The keys in the returned map match the column names in the database.
  /// 
  /// Returns a Map with the user profile data in the correct format for storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'favorite_brew': favoriteBrew,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this UserProfile with specified fields replaced
  /// 
  /// Useful for updating specific fields while keeping others unchanged.
  /// 
  /// Parameters:
  /// - Optional parameters for each field that can be updated
  /// 
  /// Returns a new UserProfile instance with the updated fields.
  UserProfile copyWith({
    String? id,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? favoriteBrew,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      favoriteBrew: favoriteBrew ?? this.favoriteBrew,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
