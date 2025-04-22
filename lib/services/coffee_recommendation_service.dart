import 'dart:math';

class CoffeeRecommendationService {
  // Singleton pattern
  static final CoffeeRecommendationService _instance = CoffeeRecommendationService._internal();
  factory CoffeeRecommendationService() => _instance;
  CoffeeRecommendationService._internal();
  
  // Coffee bean recommendations based on flavor profiles
  final Map<String, List<Map<String, dynamic>>> beanRecommendations = {
    'fruity': [
      {'name': 'Ethiopian Yirgacheffe', 'region': 'Africa', 'notes': 'Bright, fruity with berry and citrus notes'},
      {'name': 'Kenya AA', 'region': 'Africa', 'notes': 'Vibrant acidity with blackcurrant and berry notes'},
      {'name': 'Panama Geisha', 'region': 'Central America', 'notes': 'Floral with jasmine, bergamot, and peach notes'},
    ],
    'chocolatey': [
      {'name': 'Brazilian Santos', 'region': 'South America', 'notes': 'Nutty, chocolatey with low acidity'},
      {'name': 'Colombian Supremo', 'region': 'South America', 'notes': 'Balanced with chocolate and caramel notes'},
      {'name': 'Guatemala Antigua', 'region': 'Central America', 'notes': 'Rich chocolate with subtle spice notes'},
    ],
    'nutty': [
      {'name': 'Sumatra Mandheling', 'region': 'Asia', 'notes': 'Earthy, full-bodied with herbal notes'},
      {'name': 'Costa Rica Tarrazu', 'region': 'Central America', 'notes': 'Balanced with walnut and honey notes'},
      {'name': 'Honduras SHG', 'region': 'Central America', 'notes': 'Sweet with almond and caramel notes'},
    ],
    'floral': [
      {'name': 'Yemen Mocha', 'region': 'Middle East', 'notes': 'Winey, complex with dried fruit notes'},
      {'name': 'Rwanda Nyungwe', 'region': 'Africa', 'notes': 'Floral with tea-like body and citrus notes'},
      {'name': 'Ethiopia Sidamo', 'region': 'Africa', 'notes': 'Floral aroma with wine and berry notes'},
    ],
  };
  
  // Brewing method recommendations based on preferences
  final Map<String, List<Map<String, dynamic>>> methodRecommendations = {
    'strong': [
      {'method': 'Espresso', 'description': 'Concentrated coffee with rich crema'},
      {'method': 'Moka Pot', 'description': 'Stovetop coffee with robust flavor'},
      {'method': 'French Press', 'description': 'Full-bodied, rich coffee with oils preserved'},
    ],
    'balanced': [
      {'method': 'Pour Over', 'description': 'Clean, bright coffee with clear flavors'},
      {'method': 'AeroPress', 'description': 'Smooth coffee with low acidity'},
      {'method': 'Drip Coffee', 'description': 'Consistent, balanced everyday coffee'},
    ],
    'mild': [
      {'method': 'Cold Brew', 'description': 'Smooth, low-acid coffee with subtle sweetness'},
      {'method': 'Chemex', 'description': 'Clean, bright coffee with tea-like body'},
      {'method': 'Clever Dripper', 'description': 'Balanced coffee with medium body'},
    ],
    'unique': [
      {'method': 'Siphon', 'description': 'Clean, theatrical brewing with bright flavors'},
      {'method': 'Turkish Coffee', 'description': 'Strong, unfiltered coffee with fine grounds'},
      {'method': 'Vietnamese Phin', 'description': 'Strong, concentrated coffee often served with condensed milk'},
    ],
  };
  
  // Track previously recommended items to avoid repetition
  List<String> _recentBeanRecommendations = [];
  List<String> _recentMethodRecommendations = [];
  
  // Get a bean recommendation based on flavor preference
  Map<String, dynamic> getBeanRecommendation(String flavorPreference) {
    if (!beanRecommendations.containsKey(flavorPreference)) {
      // Default to a random category if preference not found
      final random = Random();
      final categories = beanRecommendations.keys.toList();
      flavorPreference = categories[random.nextInt(categories.length)];
    }
    
    final recommendations = beanRecommendations[flavorPreference]!;
    final random = Random();
    
    // Try to avoid recent recommendations
    List<Map<String, dynamic>> filteredRecs = List.from(recommendations);
    if (_recentBeanRecommendations.isNotEmpty && filteredRecs.length > 1) {
      filteredRecs.removeWhere((rec) => _recentBeanRecommendations.contains(rec['name']));
      // If we filtered everything, reset and use all recommendations
      if (filteredRecs.isEmpty) {
        filteredRecs = List.from(recommendations);
      }
    }
    
    // Get a random recommendation from the filtered list
    final recommendation = filteredRecs[random.nextInt(filteredRecs.length)];
    
    // Update recent recommendations list (keep last 3)
    _recentBeanRecommendations.add(recommendation['name']);
    if (_recentBeanRecommendations.length > 3) {
      _recentBeanRecommendations.removeAt(0);
    }
    
    return recommendation;
  }
  
  // Get a brewing method recommendation based on strength preference
  Map<String, dynamic> getMethodRecommendation(String strengthPreference) {
    if (!methodRecommendations.containsKey(strengthPreference)) {
      // Default to a random category if preference not found
      final random = Random();
      final categories = methodRecommendations.keys.toList();
      strengthPreference = categories[random.nextInt(categories.length)];
    }
    
    final recommendations = methodRecommendations[strengthPreference]!;
    final random = Random();
    
    // Try to avoid recent recommendations
    List<Map<String, dynamic>> filteredRecs = List.from(recommendations);
    if (_recentMethodRecommendations.isNotEmpty && filteredRecs.length > 1) {
      filteredRecs.removeWhere((rec) => _recentMethodRecommendations.contains(rec['method']));
      // If we filtered everything, reset and use all recommendations
      if (filteredRecs.isEmpty) {
        filteredRecs = List.from(recommendations);
      }
    }
    
    // Get a random recommendation from the filtered list
    final recommendation = filteredRecs[random.nextInt(filteredRecs.length)];
    
    // Update recent recommendations list (keep last 3)
    _recentMethodRecommendations.add(recommendation['method']);
    if (_recentMethodRecommendations.length > 3) {
      _recentMethodRecommendations.removeAt(0);
    }
    
    return recommendation;
  }
  
  // General questions and responses
  final Map<String, String> generalResponses = {
    'hello': "Hello! I'm BrewBot, your coffee assistant. How can I help you today?",
    'hi': "Hi there! I'm BrewBot, ready to help with your coffee questions.",
    'who are you': "I'm BrewBot, your coffee recommendation assistant in the BrewHand app. I can suggest coffee beans and brewing methods based on your preferences.",
    'what can you do': "I can recommend coffee beans based on flavor preferences, suggest brewing methods, and provide general coffee advice. Just ask me about beans, brewing methods, or coffee in general!",
    'help': "I can help with coffee recommendations! Ask me about beans (e.g., 'What beans have chocolate notes?'), brewing methods (e.g., 'Recommend a strong brewing method'), or just ask for a general recommendation.",
    'thanks': "You're welcome! Enjoy your coffee journey!",
    'thank you': "You're welcome! Happy brewing!",
    'how are you': "I'm brewing well, thanks for asking! How can I help with your coffee today?",
    'about app': "BrewHand is your complete coffee companion app. It helps you track your brewing history, learn new brewing methods, get personalized recommendations, and connect with other coffee enthusiasts.",
    'weather': "I'm just a coffee assistant, so I can't check the weather. But I can tell you that any weather is perfect for a good cup of coffee!",
    'time': "I don't have access to the current time, but it's always coffee o'clock somewhere!",
    'joke': "Why did the coffee file a police report? It got mugged! ☕",
    'coffee joke': "How does a coffee go to bed? It filters out!",
  };

  // Process a user query and generate a recommendation
  String processQuery(String query) {
    query = query.toLowerCase();
    
    // Check if it's a general question first
    for (var key in generalResponses.keys) {
      if (query.contains(key) || query == key) {
        return generalResponses[key]!;
      }
    }
    
    // Check if query is about beans or brewing methods
    bool isAboutBeans = query.contains('bean') || 
                        query.contains('origin') || 
                        query.contains('flavor') ||
                        query.contains('taste');
                        
    bool isAboutMethods = query.contains('method') || 
                          query.contains('brew') || 
                          query.contains('make') ||
                          query.contains('prepare');
    
    // If it's not about coffee at all, provide a friendly response
    if (!query.contains('coffee') && 
        !query.contains('bean') && 
        !query.contains('brew') && 
        !query.contains('espresso') && 
        !query.contains('drink') &&
        !query.contains('cup') &&
        !isAboutBeans &&
        !isAboutMethods) {
      return "I'm a coffee recommendation bot, so I specialize in coffee-related questions. Feel free to ask me about coffee beans, brewing methods, or for general coffee recommendations!";
    }
    
    // Determine flavor preference
    String flavorPreference = 'balanced'; // default
    if (query.contains('fruit') || query.contains('berry') || query.contains('citrus')) {
      flavorPreference = 'fruity';
    } else if (query.contains('chocolate') || query.contains('cocoa') || query.contains('sweet')) {
      flavorPreference = 'chocolatey';
    } else if (query.contains('nut') || query.contains('earthy')) {
      flavorPreference = 'nutty';
    } else if (query.contains('floral') || query.contains('tea') || query.contains('jasmine')) {
      flavorPreference = 'floral';
    }
    
    // Determine strength preference
    String strengthPreference = 'balanced'; // default
    if (query.contains('strong') || query.contains('bold') || query.contains('intense')) {
      strengthPreference = 'strong';
    } else if (query.contains('mild') || query.contains('light') || query.contains('smooth')) {
      strengthPreference = 'mild';
    } else if (query.contains('unique') || query.contains('special') || query.contains('different')) {
      strengthPreference = 'unique';
    }
    
    // For generic queries with no specific preferences, randomize the preferences
    // to get more varied responses
    if (query == "coffee" || 
        query == "recommend" || 
        query == "recommendation" || 
        query == "suggest something" ||
        query == "what should i try") {
      final random = Random();
      final flavorCategories = beanRecommendations.keys.toList();
      final strengthCategories = methodRecommendations.keys.toList();
      flavorPreference = flavorCategories[random.nextInt(flavorCategories.length)];
      strengthPreference = strengthCategories[random.nextInt(strengthCategories.length)];
    }
    
    // Generate recommendation with varied response formats
    if (isAboutBeans) {
      final recommendation = getBeanRecommendation(flavorPreference);
      final random = Random().nextInt(3);
      switch (random) {
        case 0:
          return "Based on your preference for ${flavorPreference} flavors, I recommend trying ${recommendation['name']} from ${recommendation['region']}. It has ${recommendation['notes']}.";
        case 1:
          return "You might enjoy ${recommendation['name']} from ${recommendation['region']} with its ${recommendation['notes']}. It's an excellent choice for ${flavorPreference} flavor lovers.";
        case 2:
          return "For a delicious ${flavorPreference} coffee experience, I suggest ${recommendation['name']} from ${recommendation['region']}. You'll notice ${recommendation['notes']}.";
        default:
          return "I recommend ${recommendation['name']} from ${recommendation['region']} for its wonderful ${recommendation['notes']}.";
      }
    } else if (isAboutMethods) {
      final recommendation = getMethodRecommendation(strengthPreference);
      final random = Random().nextInt(3);
      switch (random) {
        case 0:
          return "For a ${strengthPreference} coffee experience, I recommend the ${recommendation['method']} brewing method. ${recommendation['description']}.";
        case 1:
          return "Try the ${recommendation['method']} method for a ${strengthPreference} brew. ${recommendation['description']}.";
        case 2:
          return "The ${recommendation['method']} is perfect for a ${strengthPreference} coffee. What makes it special: ${recommendation['description']}.";
        default:
          return "I suggest brewing with the ${recommendation['method']} method. ${recommendation['description']}.";
      }
    } else {
      // General recommendation with both bean and method
      final beanRec = getBeanRecommendation(flavorPreference);
      final methodRec = getMethodRecommendation(strengthPreference);
      final random = Random().nextInt(3);
      switch (random) {
        case 0:
          return "I recommend trying ${beanRec['name']} from ${beanRec['region']} brewed with the ${methodRec['method']} method. The beans offer ${beanRec['notes']}, and this brewing method will give you ${methodRec['description']}.";
        case 1:
          return "For a delightful coffee experience, pair ${beanRec['name']} beans from ${beanRec['region']} with the ${methodRec['method']} brewing technique. You'll enjoy the ${beanRec['notes']} from the beans, complemented by the ${methodRec['description']}.";
        case 2:
          return "Try this combination: ${beanRec['name']} from ${beanRec['region']} prepared using the ${methodRec['method']}. The ${beanRec['notes']} of these beans works beautifully with this method, which ${methodRec['description']}.";
        default:
          return "Here's a great coffee to try: ${beanRec['name']} from ${beanRec['region']} using the ${methodRec['method']} brewing method. You'll love it!";
      }
    }
  }
}
