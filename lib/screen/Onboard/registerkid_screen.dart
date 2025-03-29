import 'package:flutter/material.dart';
import 'package:smartseed/screen/wrapper.dart';
import 'package:smartseed/service/auth/authService.dart';
import 'package:smartseed/widgets/custom_scaffold.dart';

class RegisterKid extends StatefulWidget {
  const RegisterKid({super.key});

  @override
  State<RegisterKid> createState() => _RegisterKidState();
}

class _RegisterKidState extends State<RegisterKid> {
  final AuthService _auth = AuthService();
  bool agreePersonalData = true;
  bool isLoading = false;

  // Separate form keys
  final _childFormKey = GlobalKey<FormState>();
  final _parentFormKey = GlobalKey<FormState>();

  final PageController _pageController = PageController();

  String firstName = "";
  String email = "";
  int birthYear = DateTime.now().year - 5;
  String gradeLevel = "";
  String parentEmail = "";
  String password = "";
  String parentPassword = "";
  String error = "";
  String mothertongue = "Marathi";

  void nextPage() {
    if (_childFormKey.currentState!.validate()) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void registerKid() async {
    if (_parentFormKey.currentState!.validate() && agreePersonalData) {
      setState(() => isLoading = true);

      var result = await _auth.registerKid(
        firstName,
        birthYear,
        gradeLevel,
        email,
        parentEmail,
        password,
        mothertongue,
        parentPassword,
      );

      setState(() => isLoading = false);

      if (result == null) {
        setState(() => error = "Registration failed. Try again.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration failed. Try again.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Wrapper()),
        );
      }
    } else if (!agreePersonalData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please agree to personal data processing")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: Colors.black,
      child: CustomScaffold(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildChildDetailsScreen(theme),
            _buildParentDetailsScreen(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildChildDetailsScreen(ThemeData theme) {
    return Column(
      children: [
        const Expanded(flex: 1, child: SizedBox(height: 10)),
        Expanded(
          flex: 7,
          child: Container(
            padding: const EdgeInsets.fromLTRB(25.0, 150.0, 25.0, 20.0),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(100.0),
                topRight: Radius.circular(100.0),
              ),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _childFormKey,
                child: Column(
                  children: [
                    Text(
                      'Add Your Kid',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    _buildTextField('First Name', (val) => firstName = val),
                    _buildTextField('Email', (val) => email = val),
                    _buildDropdownField(
                      'Birth Year',
                      List.generate(20,
                          (index) => (DateTime.now().year - index).toString()),
                      (val) => birthYear = int.parse(val!),
                      birthYear.toString(), // Pass selected value as String
                    ),
                    _buildTextField('Grade Level', (val) => gradeLevel = val),
                    _buildDropdownField(
                      'Mother Tongue',
                      ['Marathi', 'Hindi'],
                      (val) => mothertongue = val!,
                      mothertongue,
                    ),
                    _buildTextField('Password', (val) => password = val,
                        obscureText: true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: nextPage,
                      child: const Text("Next"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParentDetailsScreen(ThemeData theme) {
    return Column(
      children: [
        const Expanded(flex: 1, child: SizedBox(height: 10)),
        Expanded(
          flex: 7,
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
            child: SingleChildScrollView(
              child: Form(
                key: _parentFormKey,
                child: Column(
                  children: [
                    _buildTextField('Parent Email', (val) => parentEmail = val),
                    _buildTextField(
                        'Parent Password', (val) => parentPassword = val,
                        obscureText: true),
                    Row(
                      children: [
                        Checkbox(
                          value: agreePersonalData,
                          onChanged: (bool? value) {
                            setState(() => agreePersonalData = value!);
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
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: registerKid,
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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

  Widget _buildDropdownField(String label, List<String> items,
      Function(String?) onChanged, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: items.contains(value)
              ? value
              : null, // Ensure value exists in items
          items: items.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: _inputDecoration(label, 'Select $label'),
          validator: (value) => value == null ? 'Please select $label' : null,
        ),
        const SizedBox(height: 25.0),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      label: Text(label),
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
