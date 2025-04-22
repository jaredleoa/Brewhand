class UserFollowing {
  final String id;
  final String followerId; // The user who is following
  final String followingId; // The user being followed
  final DateTime createdAt;

  UserFollowing({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  // Factory constructor to create from JSON
  factory UserFollowing.fromJson(Map<String, dynamic> json) {
    return UserFollowing(
      id: json['id'] as String,
      followerId: json['follower_id'] as String,
      followingId: json['following_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'following_id': followingId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
