import 'package:brewhand/models/brew_history.dart';
import 'package:brewhand/models/user_stats.dart';
import 'package:brewhand/models/brew_post.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class BrewDataService {
  static const String _brewHistoryKey = 'brew_history';
  static const String _userStatsKey = 'user_stats';
  static const String _brewSocialPostsKey = 'brew_social_posts';

  final Uuid _uuid = Uuid();

  // Singleton pattern
  static final BrewDataService _instance = BrewDataService._internal();

  factory BrewDataService() {
    return _instance;
  }

  BrewDataService._internal();

  // Brew History Methods
  Future<List<BrewHistory>> getBrewHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_brewHistoryKey);

    if (historyJson == null) {
      return [];
    }

    List<dynamic> historyList = jsonDecode(historyJson);
    return historyList.map((item) => BrewHistory.fromJson(item)).toList();
  }

  Future<void> saveBrewHistory(BrewHistory brew) async {
    final prefs = await SharedPreferences.getInstance();
    List<BrewHistory> history = await getBrewHistory();

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

    history.add(brewWithId);

    // Update user stats
    await _updateUserStats(brewWithId);

    // Create social post
    await _createSocialPost(brewWithId);

    // Save updated history
    await prefs.setString(
        _brewHistoryKey, jsonEncode(history.map((e) => e.toJson()).toList()));

    return;
  }

  // User Stats Methods
  Future<UserStats> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? statsJson = prefs.getString(_userStatsKey);

    if (statsJson == null) {
      return UserStats();
    }

    return UserStats.fromJson(jsonDecode(statsJson));
  }

  Future<void> saveUserStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userStatsKey, jsonEncode(stats.toJson()));
  }

  Future<void> _updateUserStats(BrewHistory brew) async {
    UserStats stats = await getUserStats();
    stats.updateWithNewBrew(brew);
    await saveUserStats(stats);
  }

  // Social Post Methods
  Future<List<BrewPost>> getSocialPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? postsJson = prefs.getString(_brewSocialPostsKey);

    if (postsJson == null) {
      return [];
    }

    List<dynamic> postsList = jsonDecode(postsJson);
    return postsList.map((item) => BrewPost.fromJson(item)).toList();
  }

  Future<void> _createSocialPost(BrewHistory brew) async {
    // In a real app, you would get this from user data
    const String userId = "user123";
    const String username = "jaredcoffee";

    BrewPost post = BrewPost(
      id: _uuid.v4(),
      userId: userId,
      username: username,
      brewMethod: brew.brewMethod,
      beanType: brew.beanType,
      postDate: DateTime.now(),
      likes: 0,
      comments: [],
    );

    List<BrewPost> posts = await getSocialPosts();
    posts.add(post);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _brewSocialPostsKey, jsonEncode(posts.map((e) => e.toJson()).toList()));
  }

  Future<void> likePost(String postId) async {
    List<BrewPost> posts = await getSocialPosts();

    for (int i = 0; i < posts.length; i++) {
      if (posts[i].id == postId) {
        BrewPost updatedPost = BrewPost(
          id: posts[i].id,
          userId: posts[i].userId,
          username: posts[i].username,
          brewMethod: posts[i].brewMethod,
          beanType: posts[i].beanType,
          postDate: posts[i].postDate,
          likes: posts[i].likes + 1,
          comments: posts[i].comments,
          image: posts[i].image,
        );

        posts[i] = updatedPost;
        break;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _brewSocialPostsKey, jsonEncode(posts.map((e) => e.toJson()).toList()));
  }

  Future<void> addComment(String postId, String comment) async {
    List<BrewPost> posts = await getSocialPosts();

    for (int i = 0; i < posts.length; i++) {
      if (posts[i].id == postId) {
        List<String> updatedComments = List.from(posts[i].comments);
        updatedComments.add(comment);

        BrewPost updatedPost = BrewPost(
          id: posts[i].id,
          userId: posts[i].userId,
          username: posts[i].username,
          brewMethod: posts[i].brewMethod,
          beanType: posts[i].beanType,
          postDate: posts[i].postDate,
          likes: posts[i].likes,
          comments: updatedComments,
          image: posts[i].image,
        );

        posts[i] = updatedPost;
        break;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _brewSocialPostsKey, jsonEncode(posts.map((e) => e.toJson()).toList()));
  }

  // Mock data generation for testing
  Future<void> generateMockData() async {
    // Clear existing data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_brewHistoryKey);
    await prefs.remove(_userStatsKey);
    await prefs.remove(_brewSocialPostsKey);

    // Create some mock brew history entries
    List<BrewHistory> mockHistory = [
      BrewHistory(
        id: _uuid.v4(),
        brewMethod: 'French Press',
        beanType: 'Ethiopian Yirgacheffe',
        grindSize: 'Coarse',
        waterAmount: 350,
        coffeeAmount: 21,
        brewDate: DateTime.now().subtract(Duration(days: 3)),
        rating: 4,
        notes: 'Rich and fruity with hints of blueberry. Very nice!',
      ),
      BrewHistory(
        id: _uuid.v4(),
        brewMethod: 'Pour Over',
        beanType: 'Colombian Supremo',
        grindSize: 'Medium-Fine',
        waterAmount: 300,
        coffeeAmount: 18,
        brewDate: DateTime.now().subtract(Duration(days: 2)),
        rating: 5,
        notes: 'Perfect balance of acidity and sweetness.',
      ),
      BrewHistory(
        id: _uuid.v4(),
        brewMethod: 'AeroPress',
        beanType: 'Kenya AA',
        grindSize: 'Fine',
        waterAmount: 250,
        coffeeAmount: 17,
        brewDate: DateTime.now().subtract(Duration(days: 1)),
        rating: 3,
        notes: 'A bit too acidic for my taste, but still good.',
      ),
    ];

    // Save mock history
    await prefs.setString(_brewHistoryKey,
        jsonEncode(mockHistory.map((e) => e.toJson()).toList()));

    // Create mock user stats
    UserStats mockStats = UserStats(
      coffeeStreak: 3,
      coffeesMade: 746,
      uniqueDrinks: 23,
      uniqueBeans: 7,
      beansUsed: [
        'Ethiopian Yirgacheffe',
        'Colombian Supremo',
        'Kenya AA',
        'Sumatra Mandheling',
        'Brazil Santos',
        'Guatemala Antigua',
        'Costa Rica Tarrazu'
      ],
      methodsUsed: [
        'French Press',
        'Pour Over',
        'AeroPress',
        'Espresso',
        'Cold Brew'
      ],
    );

    // Save mock stats
    await prefs.setString(_userStatsKey, jsonEncode(mockStats.toJson()));

    // Create mock social posts
    List<BrewPost> mockPosts = [
      BrewPost(
        id: _uuid.v4(),
        userId: 'user456',
        username: 'coffeemaster',
        brewMethod: 'Espresso',
        beanType: 'Italian Roast',
        postDate: DateTime.now().subtract(Duration(hours: 5)),
        likes: 12,
        comments: ['Looks delicious!', 'What machine did you use?'],
      ),
      BrewPost(
        id: _uuid.v4(),
        userId: 'user789',
        username: 'brewqueen',
        brewMethod: 'Cold Brew',
        beanType: 'Sumatra Mandheling',
        postDate: DateTime.now().subtract(Duration(hours: 3)),
        likes: 8,
        comments: ['Perfect for summer!'],
      ),
      BrewPost(
        id: _uuid.v4(),
        userId: 'user123',
        username: 'jaredcoffee',
        brewMethod: 'Pour Over',
        beanType: 'Colombian Supremo',
        postDate: DateTime.now().subtract(Duration(hours: 2)),
        likes: 5,
        comments: [],
      ),
    ];

    // Save mock social posts
    await prefs.setString(_brewSocialPostsKey,
        jsonEncode(mockPosts.map((e) => e.toJson()).toList()));
  }
}
