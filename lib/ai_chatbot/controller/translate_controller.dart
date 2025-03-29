import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../apis/apis.dart';

enum Status { none, loading, complete }

class TranslateController extends GetxController {
  // Controllers for input and output text
  final textC = TextEditingController();
  final resultC = TextEditingController();

  final from = ''.obs;
  final to = ''.obs;

  final status = Status.none.obs;

  // Method to reset the translation state
  void resetTranslation() {
    textC.clear();
    resultC.clear();
    from.value = '';
    to.value = '';
    status.value = Status.none;
  }
  // List of supported languages
  late final lang = jsonLang.keys.toList();

  // JSON mapping of language names to language codes
  final jsonLang = const {
    'English': 'en',
    'Hindi': 'hi', // हिंदी
    'Marathi': 'mr', // मराठी
    'French': 'fr',
    'German': 'de',
    'Turkish': 'tr',
  };

  // Swap the 'from' and 'to' languages
  void swapLanguages() {
    if (to.isNotEmpty && from.isNotEmpty) {
      final t = to.value;
      to.value = from.value;
      from.value = t;
    }
  }

  // Perform Google Translate API call
  Future<void> googleTranslate() async {
    print("googleTranslate called"); // Debugging
    if (textC.text
        .trim()
        .isNotEmpty && to.isNotEmpty) {
      status.value = Status.loading;
      print("Translation started"); // Debugging

      resultC.text = await APIs.googleTranslate(
        from: jsonLang[from.value] ?? 'auto',
        to: jsonLang[to.value] ?? 'mr',
        text: textC.text,
      );

      print("Translation completed: ${resultC.text}"); // Debugging
      status.value = Status.complete;
    } else {
      print("Translation not triggered: text or language not set"); // Debugging
    }
  }
}