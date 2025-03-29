import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screen/feature/chatbot_feature.dart';
import '../screen/feature/translator_feature.dart';

enum HomeType { aiChatBot, aiTranslator } 

extension MyHomeType on HomeType {

  String get title => switch (this) {
        HomeType.aiChatBot => 'AI ChatBot',
        HomeType.aiTranslator => 'Translator',
      };

  String get lottie => switch (this) {
        HomeType.aiChatBot => 'chatbot.json',
        HomeType.aiTranslator => 'translator.json',
      };

  bool get leftAlign => switch (this) {
        HomeType.aiChatBot => true,
        HomeType.aiTranslator => false,
      };


  EdgeInsets get padding => switch (this) {
        HomeType.aiChatBot => EdgeInsets.zero,
        HomeType.aiTranslator => const EdgeInsets.all(20),
      };


  VoidCallback get onTap => switch (this) {
        HomeType.aiChatBot => () => Get.to(() => const ChatBotFeature()),
        HomeType.aiTranslator => () => Get.to(() => const TranslatorFeature()),
      };
}
