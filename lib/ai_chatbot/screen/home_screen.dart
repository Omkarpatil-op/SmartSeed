import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helper/global.dart';
import '../model/home_type.dart';
import '../widget/home_card.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(appName),
      ),

      // Body: Sayfanın ana içeriği.
      body: ListView(
        padding: EdgeInsets.symmetric(
            horizontal: mq.width * .05,
            vertical: mq.height * .025
        ),
        children: HomeType.values.map((e) => HomeCard(homeType: e)).toList(),
      ),
    );
  }
}
