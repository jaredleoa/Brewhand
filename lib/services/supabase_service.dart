/// Backend Service Layer for BrewHand
/// 
/// This service provides a centralized interface for all interactions with the
/// Supabase backend, including authentication, database operations, and storage.
/// It follows the Singleton pattern to ensure a single instance throughout the app.

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

/// Service for interacting with Supabase backend
/// 
/// Implements the Singleton pattern to ensure a single instance is used
/// throughout the application. Provides methods for authentication, database
/// operations, and file storage.
class SupabaseService {
  /// Singleton instance
  static final SupabaseService _instance = SupabaseService._internal();
  
  /// Factory constructor that returns the singleton instance
  factory SupabaseService() {
    return _instance;
  }
  
  /// Private constructor for singleton implementation
  SupabaseService._internal();
  
  /// Initializes the Supabase client
  /// 
  /// Must be called before any other Supabase operations.
  /// Uses configuration values from supabase_config.dart.
  /// 
  /// Example:
  /// ```dart
  /// final supabaseService = SupabaseService();
  /// await supabaseService.initialize();
  /// ```
  Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  /// Returns the Supabase client instance
  /// 
  /// Provides access to the underlying Supabase client for direct API calls.
  /// Should only be used when the service doesn't provide a specific method
  /// for the required operation.
  SupabaseClient get client => Supabase.instance.client;
  
  /// Authentication methods
  
  /// Registers a new user with email and password
  /// 
  /// Creates a new user account in Supabase Auth.
  /// 
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password (must meet security requirements)
  /// 
  /// Returns an [AuthResponse] with the result of the operation.
  /// Throws an exception if the registration fails.
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }
  
  /// Signs in a user with email and password
  /// 
  /// Authenticates an existing user with their credentials.
  /// 
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// 
  /// Returns an [AuthResponse] with the authentication result and session.
  /// Throws an exception if authentication fails.
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// Signs out the current user
  /// 
  /// Terminates the user's session and removes their authentication token.
  /// After calling this method, the user will need to sign in again to
  /// access protected resources.
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
          lastBrewDate: null,
        );
        
        await _saveUserStats(initialStats);
        return initialStats;
      }
      
      // Convert from snake_case DB columns to camelCase properties
      // Handle arrays properly by ensuring they're converted to List<String>
      List<String> beansUsed = [];
      List<String> methodsUsed = [];
      
      if (response['beans_used'] != null) {
        if (response['beans_used'] is List) {
          beansUsed = List<String>.from(response['beans_used']);
        } else {
          debugPrint('Warning: beans_used is not a list: ${response['beans_used']}');
        }
      }
      
      if (response['methods_used'] != null) {
        if (response['methods_used'] is List) {
          methodsUsed = List<String>.from(response['methods_used']);
        } else {
          debugPrint('Warning: methods_used is not a list: ${response['methods_used']}');
        }
      }
      
      final userStats = UserStats.fromJson({
        'coffeeStreak': response['coffee_streak'],
        'coffeesMade': response['coffees_made'],
        'uniqueDrinks': response['unique_drinks'],
        'uniqueBeans': response['unique_beans'],
        'beansUsed': beansUsed,
        'methodsUsed': methodsUsed,
        'lastBrewDate': response['last_brew_date'],
      });
      
      // Check if streak should be reset due to missed days
      userStats.checkStreakReset();
      
      // If streak was reset, save the updated stats
      if (userStats.coffeeStreak == 0 && response['coffee_streak'] > 0) {
        debugPrint('Coffee streak reset detected. Saving updated stats.');
        await _saveUserStats(userStats);
      }
      
      return userStats;
    } catch (e) {
      debugPrint('Error getting user stats: $e');
      return null;
    }
  }
  
  Future<void> _updateUserStats(BrewHistory brew) async {
    try {
      if (!isSignedIn) {
        debugPrint('Cannot update user stats: User not signed in');
        return;
      }

      debugPrint('Updating user stats with new brew: ${brew.brewMethod}, ${brew.beanType}');
      
      // Date tracking will be added in the future when the last_brew_date column exists
      
      // First get current user stats to determine what needs to be updated
      final response = await client
          .from(SupabaseTables.userStats)
          .select()
          .eq('user_id', currentUser!.id)
          .maybeSingle();
      
      if (response == null) {
        // No stats yet, create initial stats
        debugPrint('No existing stats found, creating new stats record');
        
        await client.from(SupabaseTables.userStats).insert({
          'user_id': currentUser!.id,
          'coffee_streak': 1, // First brew starts streak at 1
          'coffees_made': 1,
          'unique_drinks': 1,
          'unique_beans': 1,
          'beans_used': [brew.beanType],
          'methods_used': [brew.brewMethod],
          // Don't include last_brew_date as it's missing from the schema
        });
        
        debugPrint('Created initial user stats');
        return;
      }
      
      // Get existing values
      int coffeesMade = response['coffees_made'] ?? 0;
      int coffeeStreak = response['coffee_streak'] ?? 0;
      int uniqueDrinks = response['unique_drinks'] ?? 0;
      int uniqueBeans = response['unique_beans'] ?? 0;
      List<String> beansUsed = response['beans_used'] != null ? 
        List<String>.from(response['beans_used']) : [];
      List<String> methodsUsed = response['methods_used'] != null ? 
        List<String>.from(response['methods_used']) : [];
      
      // Update coffees made (always increments)
      coffeesMade++;
      
      // Check if the user already has a brew for today to prevent multiple streak increases in one day
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(Duration(days: 1));
      
      // Query brew history to check if there are any brews from today (excluding the current one)
      final todayBrews = await client
          .from(SupabaseTables.brewHistory)
          .select()
          .eq('user_id', currentUser!.id)
          .gte('brew_date', todayStart.toIso8601String())
          .lt('brew_date', todayEnd.toIso8601String())
          .neq('id', brew.id)  // Exclude current brew
          .count();
      
      debugPrint('Found ${todayBrews.count} other brews from today');
      
      // Only increment streak if this is the first brew of the day
      if (todayBrews.count == 0) {
        coffeeStreak++;
        debugPrint('First brew of the day! Incrementing streak to: $coffeeStreak');
      } else {
        debugPrint('Already brewed today, keeping streak at: $coffeeStreak');
      }
      
      // Check for new bean
      bool isNewBean = !beansUsed.contains(brew.beanType);
      if (isNewBean) {
        beansUsed.add(brew.beanType);
        uniqueBeans = beansUsed.length;
        debugPrint('Added new bean: ${brew.beanType}, total unique beans: $uniqueBeans');
      }
      
      // Check for new method
      bool isNewMethod = !methodsUsed.contains(brew.brewMethod);
      if (isNewMethod) {
        methodsUsed.add(brew.brewMethod);
        uniqueDrinks = methodsUsed.length;
        debugPrint('Added new method: ${brew.brewMethod}, total unique drinks: $uniqueDrinks');
      }
      
      // Log the values we'll be updating with
      debugPrint('Updating with values:');
      debugPrint('Coffees made: $coffeesMade');
      debugPrint('Coffee streak: $coffeeStreak');
      debugPrint('Unique drinks: $uniqueDrinks');
      debugPrint('Unique beans: $uniqueBeans');
      debugPrint('Beans used: $beansUsed');
      debugPrint('Methods used: $methodsUsed');
      
      // Update the stats in Supabase
      await client
        .from(SupabaseTables.userStats)
        .update({
          'coffees_made': coffeesMade,
          'coffee_streak': coffeeStreak,
          'unique_drinks': uniqueDrinks,
          'unique_beans': uniqueBeans,
          'beans_used': beansUsed,
          'methods_used': methodsUsed,
          // Don't include last_brew_date as it's missing from the schema
        })
        .eq('user_id', currentUser!.id);
      
      // Verify update was successful
      final verifyResponse = await client
          .from(SupabaseTables.userStats)
          .select()
          .eq('user_id', currentUser!.id)
          .maybeSingle();
          
      if (verifyResponse != null) {
        debugPrint('Verification - updated stats:');
        debugPrint('Coffees made: ${verifyResponse['coffees_made']}');
        debugPrint('Unique drinks: ${verifyResponse['unique_drinks']}');
        debugPrint('Unique beans: ${verifyResponse['unique_beans']}');
      }
      
      debugPrint('User stats successfully updated');
    } catch (e) {
      debugPrint('Error updating user stats: $e');
    }
  }
  
  Future<void> _saveUserStats(UserStats stats) async {
    if (!isSignedIn) {
      debugPrint('Cannot save user stats: User not signed in');
      return;
    }
    
    try {
      // Make sure the arrays are properly formatted for Postgres
      List<String> cleanBeansUsed = List<String>.from(stats.beansUsed);
      List<String> cleanMethodsUsed = List<String>.from(stats.methodsUsed);
      
      // Convert from camelCase properties to snake_case DB columns
      final Map<String, dynamic> dbData = {
        'user_id': currentUser!.id,
        'coffee_streak': stats.coffeeStreak,
        'coffees_made': stats.coffeesMade,
        'unique_drinks': stats.uniqueDrinks,
        'unique_beans': stats.uniqueBeans,
        'beans_used': cleanBeansUsed,
        'methods_used': cleanMethodsUsed,
        'last_brew_date': stats.lastBrewDate,
      };
      
      debugPrint('Saving user stats with user_id: ${currentUser!.id}');
      debugPrint('Database data: $dbData');
      debugPrint('Beans used (${cleanBeansUsed.length}): $cleanBeansUsed');
      debugPrint('Methods used (${cleanMethodsUsed.length}): $cleanMethodsUsed');
      
      // Check if the stats already exist for this user
      final existingStats = await client
        .from(SupabaseTables.userStats)
        .select()
        .eq('user_id', currentUser!.id)
        .maybeSingle();
      
      if (existingStats != null) {
        // Stats exist, update them
        final result = await client
          .from(SupabaseTables.userStats)
          .update(dbData)
          .eq('user_id', currentUser!.id);
          
        debugPrint('Updated existing user stats: $result');
      } else {
        // Stats don't exist, insert them
        final result = await client
          .from(SupabaseTables.userStats)
          .insert(dbData);
          
        debugPrint('Inserted new user stats: $result');
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
