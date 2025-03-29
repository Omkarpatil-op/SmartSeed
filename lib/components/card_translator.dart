import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../ai_chatbot/controller/translate_controller.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CardTranslator extends StatelessWidget {
  final TranslateController _c = Get.find<TranslateController>();

  CardTranslator({super.key});

  @override
  Widget build(BuildContext context) {
    print("CardTranslator build called"); // Debugging
    return Obx(() {
      if (_c.status.value == Status.complete) {
        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Translation:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _c.resultC.text,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ],
                ),

                // Speaker icon at the bottom right
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.volume_up, size: 30, color: Colors.blue),
                    onPressed: () async {
                      final FlutterTts flutterTts = FlutterTts();
                      await flutterTts.setLanguage("mr-IN"); // Set language to Marathi
                      await flutterTts.speak(_c.resultC.text); // Speak the translated text
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return const SizedBox(); // Return an empty widget if no translation is available
      }
    });
  }
}