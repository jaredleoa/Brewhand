import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/services.dart';

class DialogflowService {
  DialogFlowtter? _dialogFlowtter;
  bool _isInitialized = false;

  // Singleton pattern
  static final DialogflowService _instance = DialogflowService._internal();
  factory DialogflowService() => _instance;
  DialogflowService._internal();

  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        // Initialize DialogFlowtter with your Dialogflow credentials
        // You'll need to place your Dialogflow credentials JSON file in the assets folder
        _dialogFlowtter = await DialogFlowtter.fromAsset(
          'assets/dialogflow_credentials.json',
        );
        _isInitialized = true;
        print('Dialogflow service initialized successfully');
      } catch (e) {
        print('Error initializing Dialogflow service: $e');
        _isInitialized = false;
      }
    }
  }

  Future<DialogResponse?> getCoffeeRecommendation(String message) async {
    if (!_isInitialized || _dialogFlowtter == null) {
      await initialize();
      if (!_isInitialized) {
        return null;
      }
    }

    try {
      // Send the user message to Dialogflow
      final response = await _dialogFlowtter!.detectIntent(
        queryInput: QueryInput(text: TextInput(text: message, languageCode: 'en')),
      );
      
      return response;
    } catch (e) {
      print('Error getting coffee recommendation: $e');
      return null;
    }
  }

  // Helper method to extract the recommendation text from the Dialogflow response
  String extractRecommendationText(DialogResponse? response) {
    if (response == null || response.message == null) {
      return "I'm sorry, I couldn't process your request. Please try again.";
    }

    final message = response.message!;
    if (message.text != null && message.text!.isNotEmpty) {
      return message.text!.first;
    }

    return "I'm sorry, I couldn't understand that. Could you please try again?";
  }
}
