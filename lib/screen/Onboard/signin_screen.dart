import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:smartseed/screen/Onboard/registerparent_screen.dart';
import 'package:smartseed/widgets/custom_scaffold.dart';
import 'package:smartseed/service/auth/authService.dart';

import '../wrapper.dart'; // Make sure the AuthService is set up

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService _auth = AuthService();
  bool rememberPassword = true;
  String email = "";
  String password = "";
  String error = "";


  @override
  Widget build(BuildContext context) {
    // Accessing the current theme
    final theme = Theme.of(context);

    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor, // Use dark background color
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title Text
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: theme.primaryColor, // Use primary color from theme
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      // Email field
                      TextFormField(
                        onChanged: (val) => setState(() => email = val),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter Email',
                          hintStyle: TextStyle(
                            color: theme.textTheme.bodyMedium?.color ?? Colors.white70,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.dividerColor, // Use divider color for border
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.dividerColor, // Use divider color for border
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // Password field
                      TextFormField(
                        obscureText: true,
                        obscuringCharacter: '*',
                        onChanged: (val) => setState(() => password = val),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter Password',
                          hintStyle: TextStyle(
                            color: theme.textTheme.bodyMedium?.color ?? Colors.white70,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.dividerColor, // Use divider color for border
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.dividerColor, // Use divider color for border
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // Remember me and Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberPassword,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberPassword = value!;
                                  });
                                },
                                activeColor: theme.primaryColor,
                              ),
                              Text(
                                'Remember me',
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color ?? Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            child: Text(
                              'Forget password?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // Sign In button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                              var user = await _auth.signInWithEmailAndPassword(email, password);
                              if (user == null) {
                                setState(() {
                                  error = "Invalid login credentials";
                                });
                              } else {
                                // Navigate to home screen or next screen after successful login
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Wrapper()),
                                );

                              }

                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white, // Black text when pressed
                            side: const BorderSide(color: Colors.black), // Black border
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.black, // Black text for visibility
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // Error message display
                      Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // Sign In with social media logos divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            child: Text(
                              'Sign in with',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // Social media logos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Logo(Logos.google),
                          Logo(Logos.facebook_f),

                         // Logo(Logos.twitter),
                          //Logo(Logos.apple),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // Don't have an account section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color ?? Colors.white70,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => RegisterParent(toggleView: (view) => {}),
                                ),
                              );
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
