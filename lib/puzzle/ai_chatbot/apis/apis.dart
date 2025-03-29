import 'dart:developer';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:translator_plus/translator_plus.dart';
import '../helper/global.dart';

class APIs {


  static Future<String> getAnswer(String question)

  async {

    try {

      log('api key: $apiKey');
      
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: 'AIzaSyCBzL5FUn1B0PJGX0C_9wQ3d2_cWOdkM5I',
      );

      final content = [Content.text(question)];

      final response = await model.generateContent(content, safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),


       
      ]);

      log('res: ${response.text}');
      return response.text!;
    } 
    
    catch (e) {
      log('getAnswerGeminiE: $e');
      return 'Something went wrong (Try again in sometime)';
    }
  }



  static Future<String> googleTranslate({required String from, required String to, required String text}) 
  async {

    try {

      final res = await GoogleTranslator().translate(text, from: from, to: to);
      return res.text;
    } 
    
    catch (e) {

      log('googleTranslateE: $e ');

      return 'Something went wrong!';
    }
  }
}
