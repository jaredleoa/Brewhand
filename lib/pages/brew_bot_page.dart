import 'package:flutter/material.dart';
import 'package:brewhand/services/recommendation_service.dart';
import 'package:brewhand/services/brew_data_service.dart';
import 'package:brewhand/models/brew_history.dart';
import 'package:brewhand/pages/brew_master_page.dart';

class BrewBotPage extends StatefulWidget {
  @override
  _BrewBotPageState createState() => _BrewBotPageState();
}

class _BrewBotPageState extends State<BrewBotPage> {
  final Color darkBrown = Color(0xFF3E1F00);
  final Color mediumBrown = Color(0xFF60300F);
  final Color orangeBrown = Color(0xFFA95E04);
  final Color brightOrange = Color(0xFFFF9800);
  final Color lightBeige = Color(0xFFFFE7D3);
  
  final TextEditingController _messageController = TextEditingController();
  final RecommendationService _recommendationService = RecommendationService();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  
  @override
  void initState() {
    super.initState();
    
    // Add welcome message immediately
    _addBotMessage("Hi! I'm BrewBot, your coffee assistant. Ask me for coffee bean or brewing method recommendations based on your preferences!");
    
    // Add some example questions
    _addBotMessage("You can ask questions like:\n\n• What beans are good for a fruity flavor?\n• Recommend a strong brewing method\n• What coffee should I try if I like chocolate notes?");
  }
  
  void _addBotMessage(String message) {
    setState(() {
      _messages.add({
        'isUser': false,
        'message': message,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }
  
  void _addUserMessage(String message) {
    if (message.trim().isEmpty) return;
    
    setState(() {
      _messages.add({
        'isUser': true,
        'message': message,
        'timestamp': DateTime.now(),
      });
      _isTyping = true;
    });
    _scrollToBottom();
    
    // Clear the input field
    _messageController.clear();
    
    // Simulate bot thinking
    Future.delayed(Duration(milliseconds: 800), () async {
      // Process the user query and get a recommendation from our local service
      final response = await _recommendationService.getCoffeeRecommendation(message);
      
      setState(() {
        _isTyping = false;
        _messages.add({
          'isUser': false,
          'message': response['text'],
          'timestamp': DateTime.now(),
        });
      });
      _scrollToBottom();
      
      // Handle special actions
      if (response.containsKey('action') && response['action'] == 'brew_again') {
        // Add a slight delay to allow the message to be displayed
        Future.delayed(Duration(milliseconds: 1000), () {
          _handleBrewAgain();
        });
      }
    });
  }
  
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  // Handle the "brew again" command by fetching the last brew and navigating to BrewMasterPage
  Future<void> _handleBrewAgain() async {
    try {
      final BrewDataService dataService = BrewDataService();
      final history = await dataService.getBrewHistory();
      
      if (history.isEmpty) {
        // No previous brews found
        setState(() {
          _messages.add({
            'isUser': false,
            'message': "I couldn't find any previous brews in your history. Try brewing your first coffee in the Brew Master section!",
            'timestamp': DateTime.now(),
          });
        });
        _scrollToBottom();
        return;
      }
      
      // Sort by date to get the most recent brew
      history.sort((a, b) => b.brewDate.compareTo(a.brewDate));
      final lastBrew = history.first;
      
      // Navigate to BrewMasterPage with the last brew's settings
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BrewMasterPage(
            initialBrewMethod: lastBrew.brewMethod,
            initialBeanType: lastBrew.beanType,
            initialGrindSize: lastBrew.grindSize,
            initialWaterAmount: lastBrew.waterAmount,
            initialCoffeeAmount: lastBrew.coffeeAmount,
          ),
        ),
      );
    } catch (e) {
      print('Error handling brew again: $e');
      setState(() {
        _messages.add({
          'isUser': false,
          'message': "Sorry, I encountered an error trying to access your brew history. Please try again later.",
          'timestamp': DateTime.now(),
        });
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBrown,
      appBar: AppBar(
        title: Text(
          "BrewBot",
          style: TextStyle(color: brightOrange, fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkBrown,
        elevation: 0,
        iconTheme: IconThemeData(color: brightOrange),
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(
                  message['message'],
                  message['isUser'],
                );
              },
            ),
          ),
          
          // Typing indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mediumBrown,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTypingDot(),
                        SizedBox(width: 4),
                        _buildTypingDot(delay: 300),
                        SizedBox(width: 4),
                        _buildTypingDot(delay: 600),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Input area
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: mediumBrown,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Text input
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: lightBeige.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: brightOrange.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Ask for a recommendation...",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _addUserMessage,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Send button
                InkWell(
                  onTap: () => _addUserMessage(_messageController.text),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: brightOrange,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: darkBrown,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTypingDot({int delay = 0}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: brightOrange.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
    );
  }
  
  Widget _buildMessageBubble(String message, bool isUser) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: isUser ? 64 : 0,
        right: isUser ? 0 : 64,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                backgroundColor: brightOrange,
                radius: 16,
                child: Icon(
                  Icons.coffee,
                  color: darkBrown,
                  size: 18,
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? brightOrange : mediumBrown,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: isUser ? darkBrown : Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundColor: lightBeige,
                radius: 16,
                child: Icon(
                  Icons.person,
                  color: darkBrown,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
