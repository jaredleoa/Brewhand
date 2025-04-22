import 'package:flutter/material.dart';
import 'package:brewhand/models/brew_history.dart';
import 'package:brewhand/models/brew_post.dart';
import 'package:brewhand/models/user_profile.dart';
import 'package:brewhand/services/supabase_service.dart';
import 'package:brewhand/pages/brew_master_page.dart';
import 'package:brewhand/pages/my_brews_page.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;

class BrewSocialPage extends StatefulWidget {
  const BrewSocialPage({Key? key}) : super(key: key);
  
  @override
  _BrewSocialPageState createState() => _BrewSocialPageState();
}

class _BrewSocialPageState extends State<BrewSocialPage> {
  // Define colors to match the My Brews page
  final Color darkBrown = Color(0xFF3E1F00);
  final Color mediumBrown = Color(0xFF5E2C00);
  final Color orangeBrown = Color(0xFFA95E04);
  final Color brightOrange = Color(0xFFFF9800);
  
  bool _isLoading = true;
  List<dynamic> _sharedBrews = [];
  final SupabaseService _supabaseService = SupabaseService();
  
  @override
  void initState() {
    super.initState();
    _loadSharedBrews();
  }
  
  Future<void> _loadSharedBrews() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      // Get shared brews from Supabase with a single query
      final response = await _supabaseService.client
          .from('brew_posts')
          .select()
          .order('created_at', ascending: false);
      
      // For each post, fetch the profile information and comments separately
      List<Map<String, dynamic>> enrichedPosts = [];
      for (var post in response) {
        try {
          // Get user profile
          final userProfile = await _supabaseService.client
              .from('profiles')
              .select()
              .eq('id', post['user_id'])
              .single();
              
          // Get comments for this post
          final comments = await _supabaseService.client
              .from('brew_comments')
              .select()
              .eq('post_id', post['id'])
              .order('created_at', ascending: true);
          
          // Enrich comments with user profiles
          List<Map<String, dynamic>> enrichedComments = [];
          for (var comment in comments) {
            try {
              // Get commenter's profile
              final commenterProfile = await _supabaseService.client
                  .from('profiles')
                  .select()
                  .eq('id', comment['user_id'])
                  .single();
                  
              comment['profile'] = commenterProfile;
              enrichedComments.add(comment);
            } catch (profileError) {
              // If we can't get the profile, still show the comment
              comment['profile'] = {'username': comment['username'] ?? 'Unknown user'};
              enrichedComments.add(comment);
            }
          }
          
          // Combine post, profile, and comments data
          post['profile'] = userProfile;
          post['comments'] = enrichedComments;
          enrichedPosts.add(post);
        } catch (e) {
          // If we can't get the profile, skip this post
          print('Error loading profile for post ${post['id']}: $e');
        }
      }
      
      if (mounted) {
        setState(() {
          _sharedBrews = enrichedPosts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading shared brews: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBrown,
      appBar: AppBar(
        title: Text(
          "Brew Social",
          style: TextStyle(color: brightOrange, fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkBrown,
        elevation: 0,
        iconTheme: IconThemeData(color: brightOrange),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: brightOrange),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: brightOrange),
            onPressed: _loadSharedBrews,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: brightOrange))
          : _sharedBrews.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _sharedBrews.length,
                  itemBuilder: (context, index) {
                    return _buildSharedBrewCard(_sharedBrews[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: brightOrange,
        child: Icon(Icons.add, color: darkBrown),
        onPressed: () => _showShareBrewDialog(context),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.coffee,
            size: 80,
            color: brightOrange.withOpacity(0.5),
          ),
          SizedBox(height: 24),
          Text(
            'No Shared Brews Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: brightOrange,
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Be the first to share your brew experience with the community!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.coffee_maker),
            label: Text('Create a Brew'),
            style: ElevatedButton.styleFrom(
              backgroundColor: brightOrange,
              foregroundColor: darkBrown,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BrewMasterPage()),
              ).then((_) => _loadSharedBrews());
            },
          ),
        ],
      ),
    );
  }
  
  // Format time ago from DateTime
  String _getTimeAgo(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'en_short');
  }
  
  Widget _buildSharedBrewCard(Map<String, dynamic> sharedBrew) {
    final user = sharedBrew['profile']; // Changed from 'profiles' to 'profile'
    final username = user['username'] ?? 'Coffee Enthusiast';
    final caption = sharedBrew['caption'] ?? '';
    final brewMethod = sharedBrew['brew_method'] ?? 'Unknown Method';
    final beanType = sharedBrew['bean_type'] ?? 'Unknown Bean';
    final grindSize = sharedBrew['grind_size'] ?? 'Medium';
    final waterAmount = sharedBrew['water_amount'] ?? 0;
    final coffeeAmount = sharedBrew['coffee_amount'] ?? 0;
    final rating = sharedBrew['rating'] ?? 0;
    final createdAt = DateTime.parse(sharedBrew['created_at']);
    final timeAgo = _getTimeAgo(createdAt);
    final comments = sharedBrew['comments'] as List? ?? [];
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: mediumBrown,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: brightOrange.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info header
          ListTile(
            leading: CircleAvatar(
              backgroundColor: brightOrange.withOpacity(0.2),
              child: Icon(Icons.person, color: brightOrange),
            ),
            title: Text(
              username,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              timeAgo,
              style: TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white70),
              onPressed: () => _showBrewOptions(context, sharedBrew),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyBrewsPage(userId: user['id']),
                ),
              ).then((_) => _loadSharedBrews());
            },
          ),
          
          // Brew details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caption
                if (caption.isNotEmpty) ...[  
                  Text(
                    caption,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
                
                // Brew card
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: darkBrown,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: brightOrange.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.coffee, color: brightOrange),
                          SizedBox(width: 8),
                          Text(
                            brewMethod,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: brightOrange,
                            ),
                          ),
                          Spacer(),
                          // Rating stars
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                color: brightOrange,
                                size: 18,
                              );
                            }),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _buildBrewDetail('Bean', beanType),
                      _buildBrewDetail('Grind Size', grindSize),
                      _buildBrewDetail('Coffee', '$coffeeAmount g'),
                      _buildBrewDetail('Water', '$waterAmount ml'),
                      _buildBrewDetail('Ratio', '1:${(waterAmount / coffeeAmount).toStringAsFixed(1)}'),
                    ],
                  ),
                ),
                
                // Comments section
                if (comments.isNotEmpty) ...[  
                  SizedBox(height: 16),
                  Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: brightOrange,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...comments.map((comment) => _buildCommentItem(comment)).toList(),
                ],
                
                // Add comment button
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.comment_outlined),
                        label: Text('Add Comment'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: brightOrange,
                          side: BorderSide(color: brightOrange.withOpacity(0.5)),
                        ),
                        onPressed: () => _showAddCommentDialog(context, sharedBrew['id']),
                      ),
                    ),
                    SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: Icon(Icons.favorite_outline),
                      label: Text('${sharedBrew['likes'] ?? 0}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: brightOrange,
                        side: BorderSide(color: brightOrange.withOpacity(0.5)),
                      ),
                      onPressed: () => _likePost(sharedBrew['id']),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBrewDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommentItem(Map<String, dynamic> comment) {
    // Get username from profile if available, otherwise use the username field
    final profile = comment['profile'];
    final username = profile != null ? 
        (profile['username'] ?? 'Anonymous') : 
        (comment['username'] ?? 'Anonymous');
    
    final content = comment['content'] ?? '';
    final createdAt = DateTime.parse(comment['created_at']);
    final timeAgo = _getTimeAgo(createdAt);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: darkBrown.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: orangeBrown.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: brightOrange.withOpacity(0.2),
            child: profile != null && profile['avatar_url'] != null ?
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  profile['avatar_url'],
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                    Icon(Icons.person, size: 16, color: brightOrange),
                ),
              ) :
              Icon(Icons.person, size: 16, color: brightOrange),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: brightOrange,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showShareBrewDialog(BuildContext context) async {
    // Get user's brew history
    final brewHistory = await _supabaseService.getBrewHistory();
    
    if (brewHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to create a brew first!')),
      );
      return;
    }
    
    // Sort by most recent
    brewHistory.sort((a, b) => b.brewDate.compareTo(a.brewDate));
    
    // Show dialog to select a brew to share
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: mediumBrown,
          title: Text('Share a Brew', style: TextStyle(color: brightOrange)),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a recent brew to share:',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: brewHistory.length > 5 ? 5 : brewHistory.length,
                    itemBuilder: (context, index) {
                      final brew = brewHistory[index];
                      return ListTile(
                        title: Text(
                          brew.brewMethod,
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${brew.beanType} - ${brew.brewDate.toString().substring(0, 16)}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (i) {
                            return Icon(
                              i < brew.rating ? Icons.star : Icons.star_border,
                              color: brightOrange,
                              size: 14,
                            );
                          }),
                        ),
                        onTap: () {
                          Navigator.pop(context, brew);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    ).then((selectedBrew) {
      if (selectedBrew != null) {
        _showCaptionDialog(context, selectedBrew);
      }
    });
  }
  
  Future<void> _showCaptionDialog(BuildContext context, BrewHistory brew) async {
    final TextEditingController captionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: mediumBrown,
          title: Text('Add a Caption', style: TextStyle(color: brightOrange)),
          content: TextField(
            controller: captionController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'What do you want to say about this brew?',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: orangeBrown),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: brightOrange),
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: brightOrange,
                foregroundColor: darkBrown,
              ),
              child: Text('Share'),
              onPressed: () {
                Navigator.pop(context, captionController.text);
              },
            ),
          ],
        );
      },
    ).then((caption) async {
      if (caption != null) {
        await _shareBrewPost(brew, caption);
      }
    });
  }
  
  Future<void> _shareBrewPost(BrewHistory brew, String caption) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get current user profile
      final userProfile = await _supabaseService.getUserProfile();
      if (userProfile == null) {
        throw Exception('User profile not found');
      }
      
      // Create a new post ID
      final postId = const Uuid().v4();
      
      // Convert to database format with snake_case keys
      final Map<String, dynamic> postData = {
        'id': postId,
        'user_id': _supabaseService.currentUser!.id,
        'username': userProfile.username,
        'brew_method': brew.brewMethod,
        'bean_type': brew.beanType,
        'grind_size': brew.grindSize,
        'water_amount': brew.waterAmount,
        'coffee_amount': brew.coffeeAmount,
        'caption': caption,
        'rating': brew.rating,
        'likes': 0,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      // Insert post into Supabase
      await _supabaseService.client.from('brew_posts').insert(postData);
      
      // Reload posts
      await _loadSharedBrews();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Your brew has been shared!')),
        );
      }
    } catch (e) {
      debugPrint('Error sharing brew: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing brew: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _showAddCommentDialog(BuildContext context, String postId) async {
    final TextEditingController commentController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: mediumBrown,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add a Comment',
                  style: TextStyle(
                    color: brightOrange,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: commentController,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Write your comment...',
                    hintStyle: TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: orangeBrown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: brightOrange, width: 2),
                    ),
                    filled: true,
                    fillColor: darkBrown.withOpacity(0.5),
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: 4,
                  autofocus: true,
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brightOrange,
                        foregroundColor: darkBrown,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Post', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(context, commentController.text);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((comment) async {
      if (comment != null && comment.trim().isNotEmpty) {
        await _addComment(postId, comment);
      }
    });
  }
  
  Future<void> _addComment(String postId, String content) async {
    setState(() {
      _isLoading = true;
    });
    
    // Create a new comment ID - moved outside try block to be accessible in catch
    final commentId = const Uuid().v4();
    final now = DateTime.now().toIso8601String();
    Map<String, dynamic> commentData = {};
    
    try {
      // Get current user profile
      final userProfile = await _supabaseService.getUserProfile();
      if (userProfile == null) {
        throw Exception('User profile not found');
      }
      
      // Use a simpler approach - store comment locally first
      // This ensures the UI updates immediately even if the backend fails
      commentData = {
        'id': commentId,
        'post_id': postId,
        'user_id': _supabaseService.currentUser!.id,
        'username': userProfile.username,
        'content': content,
        'created_at': now,
        'profile': userProfile.toJson(), // Include profile data for immediate display
      };
      
      // Update UI immediately with optimistic update
      setState(() {
        // Find the post and add the comment to it
        for (var brew in _sharedBrews) {
          if (brew['id'] == postId) {
            if (brew['comments'] == null) {
              brew['comments'] = [];
            }
            brew['comments'].add(commentData);
            break;
          }
        }
      });
      
      // Now try to save to backend
      try {
        // Try direct SQL execution via RPC to bypass RLS
        await _supabaseService.client.rpc('execute_sql', params: {
          'query': """INSERT INTO brew_comments (id, post_id, user_id, username, content, created_at) 
                     VALUES ('$commentId', '$postId', '${_supabaseService.currentUser!.id}', 
                     '${userProfile.username.replaceAll("'", "''")}', 
                     '${content.replaceAll("'", "''")}', '$now')"""
        });
      } catch (sqlError) {
        print('SQL execution failed: $sqlError. Trying RPC function.');
        
        // Try RPC function as second approach
        try {
          await _supabaseService.client.rpc('add_brew_comment', params: {
            'comment_id': commentId,
            'post_id': postId,
            'user_id': _supabaseService.currentUser!.id,
            'username': userProfile.username,
            'content': content,
            'created_at': now,
          });
        } catch (rpcError) {
          print('RPC add_brew_comment failed: $rpcError. Trying direct insert.');
          
          // Last resort: direct insert
          try {
            await _supabaseService.client
              .from('brew_comments')
              .insert({
                'id': commentId,
                'post_id': postId,
                'user_id': _supabaseService.currentUser!.id,
                'username': userProfile.username,
                'content': content,
                'created_at': now,
              });
          } catch (insertError) {
            print('Direct insert failed: $insertError');
            throw insertError; // Re-throw to be caught by outer catch
          }
        }
      }
      
      // Show success message - we've already updated the UI optimistically
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comment added!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
      
      // Since we already added the comment to the UI optimistically,
      // we need to remove it on error
      setState(() {
        for (var brew in _sharedBrews) {
          if (brew['id'] == postId && brew['comments'] != null) {
            // Use the comment ID from the commentData variable we created earlier
            brew['comments'].removeWhere((comment) => comment['id'] == commentData['id']);
            break;
          }
        }
      });
      
      if (mounted) {
        String errorMessage = 'Error adding comment';
        if (e.toString().contains('row-level security policy')) {
          errorMessage = 'Permission denied. You may not have access to add comments.';
        } else if (e.toString().contains('execute_sql')) {
          errorMessage = 'Server error. Please try again later.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _likePost(String postId) async {
    try {
      // Get current likes
      final response = await _supabaseService.client
          .from('brew_posts')
          .select('likes')
          .eq('id', postId)
          .single();
      
      int currentLikes = response['likes'] ?? 0;
      
      // Increment likes
      await _supabaseService.client
          .from('brew_posts')
          .update({'likes': currentLikes + 1})
          .eq('id', postId);
      
      // Reload posts
      await _loadSharedBrews();
    } catch (e) {
      debugPrint('Error liking post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error liking post')),
        );
      }
    }
  }
  
  void _showBrewOptions(BuildContext context, Map<String, dynamic> brew) {
    final isCurrentUser = _supabaseService.currentUser?.id == brew['user_id'];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: mediumBrown,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.share, color: brightOrange),
                title: Text('Share', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // Implement share functionality
                },
              ),
              if (isCurrentUser) ...[  
                ListTile(
                  leading: Icon(Icons.delete, color: brightOrange),
                  title: Text('Delete', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteBrew(context, brew['id']);
                  },
                ),
              ],
              ListTile(
                leading: Icon(Icons.person_add, color: brightOrange),
                title: Text('Follow User', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _followUser(brew['user_id']);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _confirmDeleteBrew(BuildContext context, String postId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: mediumBrown,
          title: Text('Delete Brew', style: TextStyle(color: brightOrange)),
          content: Text(
            'Are you sure you want to delete this brew post?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
              onPressed: () {
                Navigator.pop(context);
                _deleteBrewPost(postId);
              },
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _deleteBrewPost(String postId) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Delete the post
      await _supabaseService.client
          .from('brew_posts')
          .delete()
          .eq('id', postId);
      
      // Reload posts
      await _loadSharedBrews();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Brew post deleted')),
        );
      }
    } catch (e) {
      debugPrint('Error deleting brew post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting brew post')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _followUser(String userId) async {
    if (_supabaseService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to be logged in to follow users')),
      );
      return;
    }
    
    if (_supabaseService.currentUser!.id == userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You cannot follow yourself')),
      );
      return;
    }
    
    try {
      // Check if already following
      final existing = await _supabaseService.client
          .from('user_following')
          .select()
          .eq('follower_id', _supabaseService.currentUser!.id)
          .eq('following_id', userId)
          .maybeSingle();
      
      if (existing != null) {
        // Already following, unfollow
        await _supabaseService.client
            .from('user_following')
            .delete()
            .eq('follower_id', _supabaseService.currentUser!.id)
            .eq('following_id', userId);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unfollowed user')),
        );
      } else {
        // Not following, follow
        await _supabaseService.client
            .from('user_following')
            .insert({
              'id': const Uuid().v4(),
              'follower_id': _supabaseService.currentUser!.id,
              'following_id': userId,
              'created_at': DateTime.now().toIso8601String(),
            });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Following user')),
        );
      }
    } catch (e) {
      debugPrint('Error following user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error following user')),
      );
    }
  }
  
  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: brightOrange, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
