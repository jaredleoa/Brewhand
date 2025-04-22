import 'package:brewhand/models/brew_history.dart';
import 'package:brewhand/models/user_stats.dart';
import 'package:brewhand/models/brew_post.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class BrewDataService {
  final Uuid _uuid = Uuid();
  final SupabaseService _supabaseService = SupabaseService();

  // Singleton pattern
  static final BrewDataService _instance = BrewDataService._internal();

  factory BrewDataService() {
    return _instance;
  }

  BrewDataService._internal();

  // Brew History Methods using Supabase
  Future<List<BrewHistory>> getBrewHistory() async {
    try {
      return await _supabaseService.getBrewHistory();
    } catch (e) {
      debugPrint('Error getting brew history: $e');
      return [];
    }
  }

  Future<void> saveBrewHistory(BrewHistory brew) async {
    try {
      // Generate a unique ID if needed
      BrewHistory brewWithId = brew.id.isEmpty
          ? BrewHistory(
              id: _uuid.v4(),
              brewMethod: brew.brewMethod,
              beanType: brew.beanType,
              grindSize: brew.grindSize,
              waterAmount: brew.waterAmount,
              coffeeAmount: brew.coffeeAmount,
              brewDate: brew.brewDate,
              rating: brew.rating,
              notes: brew.notes,
            )
          : brew;

      // Add the brew to Supabase
      await _supabaseService.addBrewHistory(brewWithId);
      
      // Create social post if desired
      if (brewWithId.rating >= 4) { // Only share highly rated brews
        await _createSocialPost(brewWithId);
      }

      debugPrint("Saved brew history successfully!");
    } catch (e) {
      debugPrint("Error saving brew history: $e");
      // Consider showing an error dialog to user
      rethrow; // Let calling code handle the error
    }
  }

  // User Stats Methods using Supabase
  Future<UserStats?> getUserStats() async {
    try {
      return await _supabaseService.getUserStats();
    } catch (e) {
      debugPrint('Error getting user stats: $e');
      return null;
    }
  }

  // This method is now handled by Supabase triggers or directly in the saveBrewHistory method
  Future<void> _updateUserStats(BrewHistory brew) async {
    // Get current stats
    UserStats? stats = await getUserStats();
    if (stats == null) {
      stats = UserStats(); // Create new stats if none exist
    }
    
    // Update stats with new brew
    stats.updateWithNewBrew(brew);
    
    // Save updated stats to Supabase
    await _supabaseService.updateUserStats(stats);
  }

  // Social Post Methods using Supabase
  Future<List<BrewPost>> getSocialPosts() async {
    try {
      return await _supabaseService.getBrewPosts();
    } catch (e) {
      debugPrint('Error getting social posts: $e');
      return [];
    }
  }

  Future<void> _createSocialPost(BrewHistory brew) async {
    if (!_supabaseService.isSignedIn) return;
    
    // Get current user from Supabase
    final user = _supabaseService.currentUser;
    if (user == null) return;
    
    // Get user profile to get username
    final userProfile = await _supabaseService.getUserProfile();
    if (userProfile == null) return;
    
    // Create a post with the current user's information and brew details
    BrewPost post = BrewPost(
      id: _uuid.v4(),
      userId: user.id,
      username: userProfile.username,
      createdAt: DateTime.now(),
      postDate: DateTime.now(),
      brewMethod: brew.brewMethod,
      beanType: brew.beanType,
      grindSize: brew.grindSize,
      waterAmount: brew.waterAmount,
      coffeeAmount: brew.coffeeAmount,
      likes: 0,
      rating: brew.rating,
      comments: [],
      // You could add an image here if available
    );
    
    debugPrint('Creating social post for brew: ${brew.id}');
    
    try {
      await _supabaseService.addBrewPost(post);
      debugPrint('Social post created successfully');
    } catch (e) {
      debugPrint('Error creating social post: $e');
    }
  }

  // This would need to be updated to work with Supabase
  // You would need to implement this in the SupabaseService
  Future<void> likePost(String postId) async {
    // This would be implemented using Supabase's RPC or Row-Level Security features
    // For now, this is a placeholder
    debugPrint('Like post functionality will be implemented with Supabase');
  }

  // This would need to be updated to work with Supabase
  // You would need to implement this in the SupabaseService
  Future<void> addComment(String postId, String comment) async {
    // This would be implemented using Supabase's RPC or Row-Level Security features
    // For now, this is a placeholder
    debugPrint('Comment functionality will be implemented with Supabase');
  }

  // Mock data generation for testing with Supabase
  Future<void> generateMockData() async {
    if (!_supabaseService.isSignedIn) {
      debugPrint('User not signed in. Cannot generate mock data.');
      return;
    }
    
    // Clear any existing user data
    await _supabaseService.clearUserData();
    
    // Create some mock brew history entries
    final mockBrews = [
      BrewHistory(
        id: _uuid.v4(),
        brewMethod: 'V60',
        beanType: 'Ethiopia Yirgacheffe',
        grindSize: 'Medium-Fine',
        waterAmount: 300,
        coffeeAmount: 18,
        brewDate: DateTime.now().subtract(const Duration(days: 3)),
        rating: 4,
        notes: 'Good balance, fruity undertones',
      ),
      BrewHistory(
        id: _uuid.v4(),
        brewMethod: 'Chemex',
        beanType: 'Colombian Supremo',
        grindSize: 'Medium-Coarse',
        waterAmount: 400,
        coffeeAmount: 26,
        brewDate: DateTime.now().subtract(const Duration(days: 1)),
        rating: 5,
        notes: 'Excellent clarity, sweet finish',
      ),
      BrewHistory(
        id: _uuid.v4(),
        brewMethod: 'Aeropress',
        beanType: 'Sumatra Mandheling',
        grindSize: 'Fine',
        waterAmount: 220,
        coffeeAmount: 17,
        brewDate: DateTime.now().subtract(const Duration(days: 7)),
        rating: 3,
        notes: 'Earthy and bold, but a bit too intense',
      ),
    ];

    // Add each brew to the history
    for (var brew in mockBrews) {
      await _supabaseService.addBrewHistory(brew);
    }

    debugPrint('Generated mock data successfully!');
  }
}
