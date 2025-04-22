// Supabase configuration for BrewHand
// Replace these values with your own Supabase project credentials
// from https://app.supabase.io dashboard

const String supabaseUrl = 'https://sdtgobyqekdygsgvoxju.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkdGdvYnlxZWtkeWdzZ3ZveGp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ1MzMxMTksImV4cCI6MjA2MDEwOTExOX0.3Izv5q6NVKlUf0iVDa2UtMrn4NOZxJTkMBatQHrxskM';

// For easier access to Supabase tables
class SupabaseTables {
  static const String users = 'users';
  static const String brewHistory = 'brew_history';
  static const String brewPosts = 'brew_posts';
  static const String userStats = 'user_stats';
  static const String coffeeRegions = 'coffee_regions';
  static const String profiles = 'profiles';
  static const String userFollowing = 'user_following';
  static const String brewComments = 'brew_comments';
}
