class RecommendationService {
  // Singleton pattern
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  // Get a coffee recommendation
  Future<Map<String, dynamic>> getCoffeeRecommendation(String message) async {
    return _getRecommendation(message);
  }

  // Local recommendation system
  Map<String, dynamic> _getRecommendation(String message) {
    message = message.toLowerCase();
    
    // Check for "brew again" command
    if (message.contains('brew again') || 
        message.contains('repeat brew') || 
        message.contains('same brew') || 
        message.contains('brew the same')) {
      return {
        'text': "I've heard you want to brew again with your previous settings. I'll help you with that! Just tap the button below to start brewing with your last brew's settings.",
        'isError': false,
        'action': 'brew_again'
      };
    }
    
    // Available beans in the app
    final List<String> availableBeans = [
      "Kenya", "Ethiopia", "Rwanda", "Uganda", "Tanzania", 
      "Colombia", "Brazil", "Costa Rica", "Guatemala", 
      "Panama", "Honduras", "Peru", "Indonesia (Sumatra)", 
      "Vietnam", "Thailand"
    ];
    
    // Available brewing methods in the app
    final List<Map<String, dynamic>> availableBrewingMethods = [
      {
        'name': 'French Press',
        'description': 'Rich, full-bodied coffee with a simple brewing process',
        'grind': 'Coarse',
        'flavor': 'Full-bodied with high extraction'
      },
      {
        'name': 'Pour Over',
        'description': 'Clean, bright coffee with clear flavors',
        'grind': 'Medium-Fine',
        'flavor': 'Clean with bright acidity'
      },
      {
        'name': 'AeroPress',
        'description': 'Smooth coffee with versatile brewing options',
        'grind': 'Fine',
        'flavor': 'Versatile with low acidity'
      },
      {
        'name': 'Espresso',
        'description': 'Concentrated coffee with rich crema',
        'grind': 'Extra Fine',
        'flavor': 'Concentrated with rich crema'
      },
      {
        'name': 'Moka Pot',
        'description': 'Stovetop coffee with rich, robust flavor',
        'grind': 'Fine',
        'flavor': 'Strong with intense body'
      },
      {
        'name': 'Cold Brew',
        'description': 'Smooth, refreshing coffee brewed cold over hours',
        'grind': 'Coarse',
        'flavor': 'Smooth with very low acidity'
      }
    ];
    
    // Bean characteristics for recommendations
    final Map<String, List<String>> beanCharacteristics = {
      'fruity': ['Kenya', 'Ethiopia', 'Rwanda', 'Panama'],
      'chocolate': ['Brazil', 'Colombia', 'Guatemala', 'Honduras'],
      'nutty': ['Brazil', 'Colombia', 'Peru'],
      'earthy': ['Indonesia (Sumatra)', 'Vietnam'],
      'floral': ['Ethiopia', 'Kenya', 'Rwanda'],
      'spicy': ['Indonesia (Sumatra)', 'Uganda', 'Vietnam'],
      'citrus': ['Kenya', 'Ethiopia', 'Costa Rica'],
      'berry': ['Ethiopia', 'Kenya', 'Rwanda'],
      'caramel': ['Brazil', 'Colombia', 'Guatemala', 'Costa Rica'],
      'strong': ['Vietnam', 'Indonesia (Sumatra)', 'Brazil']
    };
    
    // Brewing method characteristics for recommendations
    final Map<String, List<String>> methodCharacteristics = {
      'strong': ['Espresso', 'Moka Pot'],
      'smooth': ['AeroPress', 'Cold Brew'],
      'clean': ['Pour Over'],
      'rich': ['French Press', 'Moka Pot'],
      'quick': ['Espresso', 'AeroPress'],
      'easy': ['French Press', 'Cold Brew', 'AeroPress'],
      'complex': ['Pour Over', 'Espresso']
    };
    
    // Educational coffee information
    Map<String, String> coffeeEducation = {
      'espresso': "Espresso is a concentrated form of coffee brewed by forcing hot water through finely-ground coffee beans. It's the base for many coffee drinks and is characterized by its rich flavor, thick consistency, and crema (the golden foam on top).",
      
      'latte': "A latte is a coffee drink made with espresso and steamed milk, topped with a small amount of milk foam. The standard ratio is 1/3 espresso, 2/3 steamed milk, and a thin layer of microfoam on top. It's known for its mild, creamy flavor.",
      
      'cappuccino': "A cappuccino is an espresso-based drink with equal parts espresso, steamed milk, and milk foam (1/3 each). It has a stronger coffee flavor than a latte with a rich, creamy texture from the foam.",
      
      'americano': "An Americano is made by adding hot water to espresso, giving it a similar strength to drip coffee but with a different flavor profile. It was named after American soldiers in WWII who diluted espresso to resemble the coffee they were used to back home.",
      
      'macchiato': "A macchiato is an espresso 'stained' or 'marked' with a small amount of milk or milk foam. The traditional version is simply espresso with a dollop of milk foam on top, creating a stronger coffee experience than a cappuccino or latte.",
      
      'mocha': "A mocha (or caffè mocha) combines espresso, steamed milk, and chocolate. It's essentially a latte with chocolate syrup or cocoa powder added, creating a sweet, chocolatey coffee drink.",
      
      'flat white': "A flat white consists of espresso with steamed milk, similar to a latte but with a higher ratio of coffee to milk and minimal foam. Originating from Australia and New Zealand, it has a stronger coffee flavor than a latte.",
      
      'pour over': "Pour over is a manual brewing method where hot water is poured over ground coffee in a filter. The water drains through the coffee and filter into a carafe or mug. This method allows for precise control over brewing variables, often resulting in a clean, flavorful cup.",
      
      'french press': "French press is an immersion brewing method where coarsely ground coffee steeps in hot water before being separated by pressing a metal filter down. This method produces a full-bodied coffee with rich mouthfeel as it doesn't filter out the coffee oils.",
      
      'cold brew': "Cold brew coffee is made by steeping coffee grounds in cold water for 12-24 hours. The result is a smooth, less acidic coffee concentrate that can be diluted with water or milk and served over ice.",
      
      'aeropress': "The AeroPress is a manual brewing device that uses pressure to force hot water through coffee grounds. It combines elements of immersion brewing and pressure extraction, creating a smooth, rich cup with low acidity.",
      
      'moka pot': "A Moka pot is a stovetop coffee maker that brews coffee by passing boiling water pressurized by steam through ground coffee. It produces a strong, rich coffee similar to espresso, though technically not true espresso.",
    };
    
    // Check if the message is asking what something is
    if (message.toLowerCase().contains("what is") || message.toLowerCase().contains("what's")) {
      for (var term in coffeeEducation.keys) {
        if (message.toLowerCase().contains(term)) {
          return {
            'text': coffeeEducation[term],
            'isError': false,
          };
        }
      }
    }
    
    // Simple responses for common questions
    if (message.contains('hello') || message.contains('hi')) {
      return {
        'text': "Hello! I'm BrewBot, your coffee assistant. How can I help you today?",
        'isError': false,
      };
    } else if (message.contains('who are you')) {
      return {
        'text': "I'm BrewBot, your coffee recommendation assistant in the BrewHand app. I can suggest coffee beans and brewing methods based on your preferences.",
        'isError': false,
      };
    } else if (message.contains('thank')) {
      return {
        'text': "You're welcome! Happy brewing!",
        'isError': false,
      };
    }
    
    // Recommend beans based on flavor preferences
    for (var flavor in beanCharacteristics.keys) {
      if (message.contains(flavor)) {
        final recommendations = beanCharacteristics[flavor];
        if (recommendations != null && recommendations.isNotEmpty) {
          final bean = recommendations[DateTime.now().millisecond % recommendations.length];
          return {
            'text': "For $flavor notes, I recommend trying $bean beans. They're known for their $flavor characteristics and are available in your bean collection.",
            'isError': false,
          };
        }
      }
    }
    
    // Check for specific bean brewing method questions
    for (var bean in availableBeans) {
      String beanLower = bean.toLowerCase();
      if (message.toLowerCase().contains(beanLower) && 
          (message.contains("brewing") || message.contains("method") || message.contains("brew"))) {
        // Map beans to appropriate brewing methods
        Map<String, List<String>> beanToMethod = {
          'kenya': ['Pour Over', 'AeroPress'],
          'ethiopia': ['Pour Over', 'AeroPress'],
          'rwanda': ['Pour Over', 'French Press'],
          'uganda': ['French Press', 'Moka Pot'],
          'tanzania': ['Pour Over', 'French Press'],
          'colombia': ['Pour Over', 'French Press', 'AeroPress'],
          'brazil': ['Espresso', 'French Press', 'Moka Pot'],
          'costa rica': ['Pour Over', 'AeroPress'],
          'guatemala': ['Espresso', 'Pour Over'],
          'panama': ['Pour Over', 'AeroPress'],
          'honduras': ['Pour Over', 'French Press'],
          'peru': ['Pour Over', 'French Press'],
          'indonesia': ['French Press', 'Cold Brew'],
          'sumatra': ['French Press', 'Cold Brew'],
          'vietnam': ['Moka Pot', 'French Press'],
          'thailand': ['Cold Brew', 'French Press']
        };
        
        // Find the matching bean key
        String matchedBean = '';
        for (var key in beanToMethod.keys) {
          if (beanLower.contains(key)) {
            matchedBean = key;
            break;
          }
        }
        
        if (matchedBean.isEmpty) {
          matchedBean = beanLower;
        }
        
        // Get recommended methods for this bean
        List<String> recommendedMethods = beanToMethod[matchedBean] ?? 
            ['Pour Over', 'French Press']; // default if not found
        
        String recommendedMethod = recommendedMethods[DateTime.now().millisecond % recommendedMethods.length];
        
        final methodDetails = availableBrewingMethods.firstWhere(
          (m) => m['name'] == recommendedMethod,
          orElse: () => availableBrewingMethods[0],
        );
        
        return {
          'text': "For $bean beans, I recommend the ${methodDetails['name']} brewing method. ${methodDetails['description']}. Use a ${methodDetails['grind']} grind for best results.",
          'isError': false,
        };
      }
    }
    
    // Recommend brewing methods based on preferences
    for (var characteristic in methodCharacteristics.keys) {
      if (message.contains(characteristic)) {
        final recommendations = methodCharacteristics[characteristic];
        if (recommendations != null && recommendations.isNotEmpty) {
          final method = recommendations[DateTime.now().millisecond % recommendations.length];
          final methodDetails = availableBrewingMethods.firstWhere(
            (m) => m['name'] == method,
            orElse: () => availableBrewingMethods[0],
          );
          return {
            'text': "For a $characteristic coffee experience, I recommend the ${methodDetails['name']} brewing method. ${methodDetails['description']}. Use a ${methodDetails['grind']} grind for best results.",
            'isError': false,
          };
        }
      }
    }
    
    // Check if the message is coffee-related
    List<String> coffeeKeywords = [
      'coffee', 'bean', 'brew', 'roast', 'grind', 'espresso', 'latte', 'cappuccino',
      'aeropress', 'pour over', 'french press', 'moka', 'cold brew', 'flavor', 'taste',
      'cup', 'caffeine', 'barista', 'drink', 'cafe', 'arabica', 'robusta'
    ];
    
    bool isCoffeeRelated = false;
    for (var keyword in coffeeKeywords) {
      if (message.contains(keyword)) {
        isCoffeeRelated = true;
        break;
      }
    }
    
    // If the message doesn't seem coffee-related, provide a clarification response
    if (!isCoffeeRelated && message.length > 5) {
      return {
        'text': "I'm BrewBot, a coffee recommendation assistant. I can help with coffee bean suggestions, brewing methods, and flavor profiles. If you have any coffee-related questions, feel free to ask!",
        'isError': false,
      };
    }
    
    // Default recommendation if no specific preferences detected but message is coffee-related
    final randomBean = availableBeans[DateTime.now().millisecond % availableBeans.length];
    final randomMethod = availableBrewingMethods[DateTime.now().millisecond % availableBrewingMethods.length];
    
    return {
      'text': "I recommend trying $randomBean beans with the ${randomMethod['name']} brewing method. ${randomMethod['description']}. Use a ${randomMethod['grind']} grind size for the best results.",
      'isError': false,
    };
  }
}
