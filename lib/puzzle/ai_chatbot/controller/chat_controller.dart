import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../apis/apis.dart';
import '../model/message.dart';

class ChatController extends GetxController {
  
  final textC = TextEditingController();

  final scrollC = ScrollController();

  final list = <Message>[
    
    Message(msg: 'Hello, How can I help you?', msgType: MessageType.bot)
  
  ].obs;

  Future<void> askQuestion() async {

    if (textC.text.trim().isNotEmpty) {


      list.add(Message(msg: textC.text, msgType: MessageType.user));
      list.add(Message(msg: '', msgType: MessageType.bot));
      _scrollDown();

      final res = await APIs.getAnswer(textC.text);



      list.removeLast();
      list.add(Message(msg: res, msgType: MessageType.bot));
      _scrollDown();

      textC.text = '';
    } 
  }

  
  void _scrollDown() {
    
    scrollC.animateTo(scrollC.position.maxScrollExtent,
        
        duration: const Duration(milliseconds: 500), curve: Curves.ease);}
}
