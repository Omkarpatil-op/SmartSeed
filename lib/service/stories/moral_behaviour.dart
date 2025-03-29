import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class MoralBehaviour {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _geminiApiKey = "AIzaSyC7PPJjAnP1MQbRntjSeNunv9TNaDT_-w8";

  Future<void> analyzeAndStoreBehaviour(
      String kidId, String parentId, Map<String, dynamic> resultJson) async {
    print(kidId + " " + parentId + " " + resultJson.toString());
    try {
      // Step 1: Send data to Gemini AI for analysis
      final Map<String, String> analysis =
          await _analyzeBehaviourWithAI(resultJson);

      // Step 2: Store the result in Firebase
      final CollectionReference moralBehavior =
          _firestore.collection('moral_behaviour');
      final QuerySnapshot kidMoralBehaviorSnapshot =
          await moralBehavior.where('kid_id', isEqualTo: kidId).get();

      if (kidMoralBehaviorSnapshot.docs.isNotEmpty) {
        // Update existing document
        await kidMoralBehaviorSnapshot.docs.first.reference.update({
          'summary': analysis['summary'],
          'suggestion': analysis['suggestion'],
          'note': analysis['note'],
          'created_at': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new document
        await moralBehavior.add({
          'kid_id': kidId,
          'parent_id': parentId,
          'summary': analysis['summary'],
          'suggestion': analysis['suggestion'],
          'note': analysis['note'],
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      print("✅ Moral behavior analysis stored successfully!");
    } catch (e) {
      print("❌ Error storing moral behavior: $e");
    }
  }

  Future<Map<String, String>> _analyzeBehaviourWithAI(
      Map<String, dynamic> resultJson) async {
    try {
      final model =
          GenerativeModel(model: 'gemini-1.5-flash', apiKey: _geminiApiKey);
      final prompt = """
    Analyze the following moral behavior data of a child and provide a short response for each:
    
    1. **Summary (1-2 lines)**: Briefly summarize the child's moral behavior.
    2. **Suggestion (1-2 lines)**: Provide a simple improvement tip.
    3. **Note (1-2 lines)**: A short message for the parents.

    Data: ${resultJson.toString()}

    Respond strictly in JSON format (no code block, no explanations):
    {
      "summary": "Concise summary here.",
      "suggestion": "Short improvement tip here.",
      "note": "Brief note for parents here."
    }
    """;

      final response = await model.generateContent([Content.text(prompt)]);
      String aiResponse = response.text ?? "{}";

      // Debugging AI response
      print("🔍 AI Response Before Cleanup: $aiResponse");

      // Clean and parse JSON
      aiResponse = _cleanJsonResponse(aiResponse);
      final Map<String, dynamic> parsedResponse = jsonDecode(aiResponse);

      print(
          "✅ Parsed AI Response: $parsedResponse"); // Debugging the parsed response

      return {
        "summary": parsedResponse["summary"] ?? "No summary available.",
        "suggestion":
            parsedResponse["suggestion"] ?? "No suggestion available.",
        "note": parsedResponse["note"] ?? "No note available."
      };
    } catch (e) {
      print("❌ Error with AI analysis: $e");
      return {
        "summary": "Error analyzing behavior.",
        "suggestion": "Please try again later.",
        "note": "AI analysis failed."
      };
    }
  }

  // Helper function to clean JSON response
  String _cleanJsonResponse(String response) {
    return response
        .replaceAll("```json", "") // Remove opening code block
        .replaceAll("```", "") // Remove closing code block
        .trim(); // Remove any leading or trailing spaces
  }

  Future<List<Map<String, dynamic>>> getMoralBehaviorByKidID(
      String kidId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('moral_behaviour')
          .where('kid_id', isEqualTo: kidId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching moral behavior: $e");
      return [];
    }
  }
}
