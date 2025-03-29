import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:smartseed/screen/wrapper.dart';
import 'package:smartseed/widgets/custom_scaffold.dart';
import 'package:smartseed/service/auth/authService.dart';

class RegisterParent extends StatefulWidget {
  final Function toggleView;
  const RegisterParent({required this.toggleView, super.key});

  @override
  State<RegisterParent> createState() => _RegisterParentState();
}

class _RegisterParentState extends State<RegisterParent> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  bool isLoading = false; // Loading state

  String fullName = "";
  String email = "";
  String password = "";
  String phone = "";
  String relationship = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 40.0),

                      // Input Fields
                      _buildTextField('Full Name', (val) => fullName = val),
                      _buildTextField('Email', (val) => email = val),
                      _buildTextField('Password', (val) => password = val,
                          obscureText: true),
                      //    _buildTextField('Phone', (val) => phone = val),
                      //    _buildTextField('Relationship to Kid', (val) => relationship = val),

                      // Checkbox for consent
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (bool? value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                            activeColor: theme.primaryColor,
                          ),
                          const Text('I agree to the processing of ',
                              style: TextStyle(color: Colors.white70)),
                          Text(
                            'Personal data',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate() &&
                                agreePersonalData) {
                              setState(() {
                                isLoading = true; // Show loader
                              });

                              var result = await _auth.registerParent(fullName,
                                  email, password, phone, relationship);

                              setState(() {
                                isLoading = false; // Hide loader
                              });

                              if (result == null) {
                                setState(() =>
                                    error = "Registration failed. Try again.");
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Registration failed. Try again.")));
                              } else {
                                print("Registration successful!");
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Registration Successful!")));

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Wrapper()),
                                );
                              }
                            } else if (!agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Please agree to personal data processing")));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.black),
                          ),
                          child: const Text('Sign up',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ),

                      Text(error, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 30.0),

                      // Sign-up options (Google/Facebook)
                      _buildSignUpWithOtherOptions(),
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

  Widget _buildTextField(String label, Function(String) onChanged,
      {bool obscureText = false}) {
    return Column(
      children: [
        TextFormField(
          obscureText: obscureText,
          validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
          decoration: _inputDecoration(label, 'Enter $label'),
          onChanged: onChanged,
        ),
        const SizedBox(height: 25.0),
      ],
    );
  }

  // Input decoration
  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      label: Text(label),
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // Sign-up with other options (Google/Facebook)
  Widget _buildSignUpWithOtherOptions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: Divider(
                    thickness: 0.7, color: Colors.grey.withOpacity(0.5))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child:
                  Text('Sign up with', style: TextStyle(color: Colors.white70)),
            ),
            Expanded(
                child: Divider(
                    thickness: 0.7, color: Colors.grey.withOpacity(0.5))),
          ],
        ),
        const SizedBox(height: 30.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [Logo(Logos.google), Logo(Logos.facebook_f)],
        ),
      ],
    );
  }
}
