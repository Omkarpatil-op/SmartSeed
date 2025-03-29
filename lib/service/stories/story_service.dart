import 'dart:convert';
import 'package:flutter/services.dart';

class StoryService {
  Future<List<dynamic>> loadStories() async {
    final String response =
        await rootBundle.loadString('assets/stories/moral_story.json');
    final List<dynamic> data = json.decode(response);
    return data;
  }
}
