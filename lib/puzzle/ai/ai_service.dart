import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyCBzL5FUn1B0PJGX0C_9wQ3d2_cWOdkM5I',
  );

  Future<String> generateIntroduction(String topic,int birth_year) async {
    final String age = (DateTime.now().year - birth_year).toString();
    final String prompt = """
      "Create a simple and fun introduction to the topic: '$topic'.
      for the age group:'$age'
       Use very easy, everyday words that a 5-10-year-old can understand.
        Keep it super short, hardly 5 to 6 words . 
        Make it exciting and relatable for kids by using examples from their daily life. 
        Avoid complex words and keep it playful!
        and show that mathematical expression"
        
        
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "Let's learn about $topic! It's going to be fun!";
    } catch (e) {
      return "Error generating introduction: $e";
    }
  }

  Future<String> generateQuestion(String topic) async {
    final String prompt = """
       I have very bad volabulary,
      Provide a simple and fun introduction to the topic: "$topic".
      use day to day examples and
      Use easy words and keep it very short, like 1 sentences.
      Make it exciting for kids aged 5-10!
      Format the question as: 
      "Question: [Your question] || Yes/No || [Correct answer]".
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "Is $topic fun to learn about? || Yes/No || Yes";
    } catch (e) {
      return "Error generating question: $e";
    }
  }

  Future<String> evaluateResponse(
      String topic, String question, String userAnswer) async {
    final String prompt = """
      The child was asked: "$question".
      They answered: "$userAnswer".
      Provide a short and simple feedback for kids aged 5-10.
      Explain if their answer is correct or not in 1-2 sentences.
      Topic: "$topic".
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "Great job! Your answer is being checked.";
    } catch (e) {
      return "Error evaluating response: $e";
    }
  }
}
