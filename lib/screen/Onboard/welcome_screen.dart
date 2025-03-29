import 'package:flutter/material.dart';
import 'package:smartseed/screen/Onboard/signin_screen.dart';
import 'package:smartseed/screen/Onboard/registerparent_screen.dart';
import 'package:smartseed/service/auth/authService.dart';
import 'package:smartseed/widgets/custom_scaffold.dart';
import 'package:smartseed/widgets/welcome_button.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  const SignIn({required this.toggleView, super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  String email = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Welcome Back!\n',
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleLarge?.color ?? Colors.white, // Heading text color
                        ),
                      ),
                      TextSpan(
                        text:
                        '\nSmartSeed - Modern Problem requires Modern Solution ',
                        style: TextStyle(
                          fontSize: 20,
                          color: theme.textTheme.bodyMedium?.color ?? Colors.white70, // Subtext color
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children:[

                const Expanded(
                  child: WelcomeButton(
                    buttonText: 'Sign in',
                    onTap: SignInScreen(),
                    color: Colors.transparent, // Transparent background
                    textColor: Colors.white, // White text
                  ),
                ),

                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign up',
                      color: Colors.black,
                      onTap: RegisterParent(toggleView: (view) => {}), // Black background

                      textColor: Colors.blueAccent, // Purple text
                    ),
                  ),
                ]



              ),
            ),
          ),
        ],
      ),

    );
  }
}
