import 'dart:io';
import 'package:brewhand/models/brew_history.dart';
import 'package:brewhand/models/user_profile.dart';
import 'package:brewhand/models/brew_post.dart';
import 'package:brewhand/models/user_stats.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  
  factory SupabaseService() {
    return _instance;
  }
  
  SupabaseService._internal();
  
  // Initialize Supabase
  Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  // Get Supabase client
  SupabaseClient get client => Supabase.instance.client;
  
  // Authentication methods
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }
  
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  // Get current user
  User? get currentUser => client.auth.currentUser;
  
  // Check if user is signed in
  bool get isSignedIn => currentUser != null;
  
  // Brew History methods
  Future<List<BrewHistory>> getBrewHistory() async {
    if (!isSignedIn) return [];
    
    try {
      final response = await client
          .from(SupabaseTables.brewHistory)
          .select()
          .eq('user_id', currentUser!.id)
          .order('brew_date', ascending: false);
      
      return response.map((item) => BrewHistory.fromJson({
        'id': item['id'],
        'brewMethod': item['brew_method'],
        'beanType': item['bean_type'],
        'grindSize': item['grind_size'],
        'waterAmount': item['water_amount'],
        'coffeeAmount': item['coffee_amount'],
        'brewDate': item['brew_date'],
        'rating': item['rating'],
        'notes': item['notes'] ?? '',
      })).toList();
    } catch (e) {
      debugPrint('Error in getBrewHistory: $e');
      return [];
    }
  }
  
  Future<void> addBrewHistory(BrewHistory brew) async {
    debugPrint('Checking authentication: ${isSignedIn ? 'User is signed in' : 'User is NOT signed in!'}');
    if (currentUser != null) {
      debugPrint('Current user ID: ${currentUser!.id}');
    } else {
      debugPrint('Current user is NULL!');
    }
    
    if (!isSignedIn) {
      debugPrint('Cannot add brew history: User not signed in');
      return;
    }
    
    // Convert to database format with snake_case keys
    final Map<String, dynamic> dbData = {
      'id': brew.id,
      'user_id': currentUser!.id,
      'brew_method': brew.brewMethod,
      'bean_type': brew.beanType,
      'grind_size': brew.grindSize,
      'water_amount': brew.waterAmount,
      'coffee_amount': brew.coffeeAmount,
      'brew_date': brew.brewDate.toIso8601String(),
      'rating': brew.rating,
      'notes': brew.notes,
    };
    
    try {
      debugPrint('Inserting brew history with ID: ${brew.id}');
      debugPrint('Into table: ${SupabaseTables.brewHistory}');
      await client.from(SupabaseTables.brewHistory).insert(dbData);
      debugPrint('Brew history inserted successfully');
      // Update user stats
      await _updateUserStats(brew);
    } catch (e) {
      debugPrint('Error in addBrewHistory: $e');
      rethrow;
    }
  }
  
  // Upload image to Supabase Storage
  Future<String?> uploadImage(File imageFile, String folder) async {
    if (!isSignedIn) return null;
    
    try {
      final fileExt = path.extension(imageFile.path);
      final fileName = '${const Uuid().v4()}$fileExt';
      final filePath = '$folder/$fileName';
      
      // Read file bytes
      final bytes = await imageFile.readAsBytes();
      
      await client.storage.from('brewhand').uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      
      // Get public URL
      final imageUrl = client.storage.from('brewhand').getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
  
  // Brew Social methods
  Future<List<BrewPost>> getBrewPosts() async {
    try {
      final response = await client
          .from(SupabaseTables.brewPosts)
          .select()
          .order('post_date', ascending: false)
          .limit(50);
      
      return (response as List).map((item) => BrewPost.fromJson({
        'id': item['id'],
        'userId': item['user_id'],
        'postDate': item['post_date'],
        'brewMethod': item['brew_method'],
        'beanType': item['bean_type'],
        'grindSize': item['grind_size'],
        'waterAmount': item['water_amount'],
        'coffeeAmount': item['coffee_amount'],
        'likes': item['likes'],
        'comments': item['comments'],
        'image': item['image'],
      })).toList();
    } catch (e) {
      debugPrint('Error getting brew posts: $e');
      return [];
    }
  }
  
  Future<void> addBrewPost(BrewPost post) async {
    if (!isSignedIn) return;
    
    try {
      // Convert from camelCase to snake_case for database
      final Map<String, dynamic> dbData = {
        'id': post.id,
        'user_id': currentUser!.id,
        'post_date': post.postDate.toIso8601String(),
        'brew_method': post.brewMethod,
        'bean_type': post.beanType,
        'grind_size': post.grindSize,
        'water_amount': post.waterAmount,
        'coffee_amount': post.coffeeAmount,
        'likes': post.likes,
        'comments': post.comments,
        'image': post.image,
      };
      
      await client.from(SupabaseTables.brewPosts).insert(dbData);
      debugPrint('Brew post added successfully');
    } catch (e) {
      debugPrint('Error adding brew post: $e');
      rethrow;
    }
  }
  
  // User Stats methods
  Future<UserStats?> getUserStats() async {
    if (!isSignedIn) return null;
    
    try {
      final response = await client
          .from(SupabaseTables.userStats)
          .select()
          .eq('user_id', currentUser!.id)
          .maybeSingle();
      
      if (response == null) {
        // Create initial stats
        final initialStats = UserStats(
          coffeeStreak: 0,
          coffeesMade: 0,
          uniqueDrinks: 0,
          uniqueBeans: 0,
          beansUsed: [],
          methodsUsed: [],
        );
        
        await _saveUserStats(initialStats);
        return initialStats;
      }
      
      // Convert from snake_case DB columns to camelCase properties
      return UserStats.fromJson({
        'coffeeStreak': response['coffee_streak'],
        'coffeesMade': response['coffees_made'],
        'uniqueDrinks': response['unique_drinks'],
        'uniqueBeans': response['unique_beans'],
        'beansUsed': response['beans_used'] ?? [],
        'methodsUsed': response['methods_used'] ?? [],
      });
    } catch (e) {
      debugPrint('Error getting user stats: $e');
      return null;
    }
  }
  
  Future<void> _updateUserStats(BrewHistory brew) async {
    final stats = await getUserStats();
    if (stats == null) return;
    
    stats.updateWithNewBrew(brew);
    await _saveUserStats(stats);
  }
  
  Future<void> _saveUserStats(UserStats stats) async {
    if (!isSignedIn) {
      debugPrint('Cannot save user stats: User not signed in');
      return;
    }
    
    try {
      // Convert from camelCase properties to snake_case DB columns
      final Map<String, dynamic> dbData = {
        'user_id': currentUser!.id,
        'coffee_streak': stats.coffeeStreak,
        'coffees_made': stats.coffeesMade,
        'unique_drinks': stats.uniqueDrinks,
        'unique_beans': stats.uniqueBeans,
        // Important fix: These need to be ARRAYS in Postgres format
        'beans_used': stats.beansUsed.isEmpty ? [] : stats.beansUsed,
        'methods_used': stats.methodsUsed.isEmpty ? [] : stats.methodsUsed,
      };
      
      debugPrint('Saving user stats with user_id: ${currentUser!.id}');
      debugPrint('Database data: $dbData');
      
      // Check if the stats already exist for this user
      final existingStats = await client
        .from(SupabaseTables.userStats)
        .select()
        .eq('user_id', currentUser!.id)
        .maybeSingle();
      
      if (existingStats != null) {
        // Stats exist, update them
        await client
          .from(SupabaseTables.userStats)
          .update(dbData)
          .eq('user_id', currentUser!.id);
        debugPrint('Updated existing user stats');
      } else {
        // Stats don't exist, insert them
        await client
          .from(SupabaseTables.userStats)
          .insert(dbData);
        debugPrint('Inserted new user stats');
      }
      
      debugPrint('User stats saved successfully');
    } catch (e) {
      debugPrint('Error saving user stats: $e');
      // Don't rethrow to avoid crashing the app
    }
  }
  
  // Public method to update user stats
  Future<void> updateUserStats(UserStats stats) async {
    await _saveUserStats(stats);
  }
  
  // User Profile methods
  Future<UserProfile?> getUserProfile() async {
    if (!isSignedIn) return null;
    
    try {
      final response = await client
          .from(SupabaseTables.profiles)
          .select()
          .eq('id', currentUser!.id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }
  
  Future<void> createUserProfile({
    required String username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? favoriteBrew, // Combined favorite order/bean into single field
  }) async {
    if (!isSignedIn) return;
    
    try {
      final now = DateTime.now();
      
      // Create new profile using model that matches database schema exactly
      final profile = UserProfile(
        id: currentUser!.id,
        username: username,
        fullName: fullName ?? username, // Default to username if no full name provided
        avatarUrl: avatarUrl,
        bio: bio,
        favoriteBrew: favoriteBrew,
        createdAt: now,
        updatedAt: now,
      );
      
      // Use a simple upsert now that our model matches the database
      await client
          .from('profiles')
          .upsert(profile.toJson());
      
      debugPrint('User profile created successfully');
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }
  
  Future<void> updateUserProfile({
    String? username,
    String? displayName,
    String? profileImageUrl,
    String? favoriteOrder,
    String? favoriteBean,
  }) async {
    if (!isSignedIn) return;
    
    try {
      final existing = await getUserProfile();
      if (existing == null) {
        throw Exception('Profile not found');
      }
      
      final updates = {
        if (username != null) 'username': username,
        if (displayName != null) 'display_name': displayName,
        if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
        if (favoriteOrder != null) 'favorite_order': favoriteOrder,
        if (favoriteBean != null) 'favorite_bean': favoriteBean,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await client
          .from(SupabaseTables.profiles)
          .update(updates)
          .eq('id', currentUser!.id);
      
      debugPrint('User profile updated successfully');
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }
  
  Future<bool> isUsernameAvailable(String username) async {
    final response = await client
        .from(SupabaseTables.profiles)
        .select('username')
        .eq('username', username)
        .maybeSingle();
    
    return response == null; // Username is available if no record found
  }
  
  // For handling email confirmation resend
  Future<void> resendConfirmationEmail(String email) async {
    await client.auth.resend(email: email, type: OtpType.signup);
  }
  
  // Clear user data (for testing or account deletion)
  Future<void> clearUserData() async {
    if (!isSignedIn) return;
    
    final userId = currentUser!.id;
    
    // Delete user's brew history
    await client
        .from(SupabaseTables.brewHistory)
        .delete()
        .eq('user_id', userId);
    
    // Delete user's posts
    await client
        .from(SupabaseTables.brewPosts)
        .delete()
        .eq('user_id', userId);
    
    // Reset user stats (don't delete, just reset to defaults)
    final initialStats = UserStats(
      coffeeStreak: 0,
      coffeesMade: 0,
      uniqueDrinks: 0,
      uniqueBeans: 0,
      beansUsed: [],
      methodsUsed: [],
    );
    
    await updateUserStats(initialStats);
  }
  
  // Coffee Regions
  Future<List<Map<String, dynamic>>> getCoffeeRegions() async {
    final response = await client
        .from(SupabaseTables.coffeeRegions)
        .select()
        .order('region_name');
    
    return response;
  }
}
