import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart'; // Import GetX package
import 'package:provider/provider.dart';
import 'package:smartseed/Firebase/firebase.dart';
import 'package:smartseed/model/user.dart';
import 'package:smartseed/puzzle/provider/quiz_provider.dart';
import 'package:smartseed/screen/Onboard/registerkid_screen.dart';
import 'package:smartseed/service/auth/authService.dart';
import 'package:smartseed/widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<AppUser?>.value(
          initialData: null,
          value: AuthService().user,
        ),
        ChangeNotifierProvider(
            create: (context) => QuizProvider()), // ✅ Added this
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    _initializeFirebase(); // Firebase initializes in the background

    return GetMaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white),
        ),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/addkid': (context) => const RegisterKid(),
      },
      title: 'SmartSeed',
      home: const SplashScreen(),
    );
  }
}
