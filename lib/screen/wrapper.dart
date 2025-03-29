import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartseed/model/user.dart';
import 'package:smartseed/screen/Main/mainKids.dart';
import 'package:smartseed/screen/Main/mainParent.dart';
import 'package:smartseed/service/auth/authService.dart';
import 'package:smartseed/service/auth/authenticate.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final AuthService _auth = AuthService();
  // static const platform = MethodChannel('screen_pinning');

  // /// Function to enable screen pinning (Android Kiosk Mode)
  // Future<void> _enableScreenPinning() async {
  //   try {
  //     await platform.invokeMethod('enableScreenPinning');
  //   } on PlatformException catch (e) {
  //     print("Failed to enable screen pinning: ${e.message}");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);

    // If user is not logged in, show authentication screen
    if (user == null) {
      return const Authenticate();
    }

    // Check if UID is null or empty
    if (user.uid == null || user.uid!.isEmpty) {
      return const Center(child: Text("Invalid Welcome+Regis"));
    }

    return FutureBuilder<String?>(
      future: _auth.getUserTypeByUID(user.uid!), // Get user type
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Authenticate();
        } else {
          String userType = snapshot.data!;
          bool isKid = userType == "kid";

          // If the user is a kid, enable screen pinning
          // if (isKid) {
          //   WidgetsBinding.instance.addPostFrameCallback((_) {
          //     _enableScreenPinning();
          //   });
          // }

          return FutureBuilder<Map<String, dynamic>?>(
            future: _auth.getUserByUID(user.uid!),
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (userDataSnapshot.hasError) {
                return Center(child: Text("Error: ${userDataSnapshot.error}"));
              } else if (!userDataSnapshot.hasData ||
                  userDataSnapshot.data == null) {
                return const Authenticate();
              } else {
                return isKid
                    ? MainKid(userData: userDataSnapshot.data!, currentIndex: 0,)
                    : MainParent(userData: userDataSnapshot.data!);
              }
            },
          );
        }
      },
    );
  }
}
