import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../apis/apis.dart';

enum Status { none, loading, complete }


class TranslateController extends GetxController {

  final textC = TextEditingController();


  final resultC = TextEditingController();


  final from = ''.obs, to = ''.obs;


  final status = Status.none.obs;



  void swapLanguages() {
    if (to.isNotEmpty && from.isNotEmpty) {
      final t = to.value;
      to.value = from.value;
      from.value = t;
    }
  }


  Future<void> googleTranslate() async {

    if (textC.text.trim().isNotEmpty && to.isNotEmpty) {

      status.value = Status.loading;


      resultC.text = await APIs.googleTranslate(
          from: jsonLang[from.value] ?? 'auto',
          to: jsonLang[to.value] ?? 'en',
          text: textC.text);

      status.value = Status.complete;
    }
  }


  late final lang = jsonLang.keys.toList();


  final jsonLang = const {
    'English': 'en',
    'Hindi': 'hi',     // हिंदी
    'Marathi': 'mr',   // मराठी
    'French': 'fr',
    'German': 'de',
    'Turkish': 'tr'
  };
}
