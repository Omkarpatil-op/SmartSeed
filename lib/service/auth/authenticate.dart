import 'package:flutter/material.dart';
import 'package:smartseed/screen/Onboard/registerkid_screen.dart';
import 'package:smartseed/screen/Onboard/registerparent_screen.dart';
import 'package:smartseed/screen/Onboard/welcome_screen.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  String showScreen = "signin";

  void toggleView(String view) {
    setState(() => showScreen = view);
  }

  @override
  Widget build(BuildContext context) {
    if (showScreen == "signin") {
      return SignIn(toggleView: toggleView);
    } else if (showScreen == "register-parent") {
      return RegisterParent(toggleView: toggleView);
    } else {
      return const RegisterKid();
    }
  }
}
