import 'package:google_generative_ai/google_generative_ai.dart';

class AIAssistant {
  static const String _apiKey = 'YOUR_GOOGLE_AI_KEY';
  late GenerativeModel _model;

  AIAssistant() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
  }

  Future<String> generateContent(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "Let's try that again!";
    } catch (e) {
      return "Oops! The AI is taking a break 🛌";
    }
  }
}
