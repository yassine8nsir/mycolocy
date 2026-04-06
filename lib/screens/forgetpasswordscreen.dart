import 'package:flutter/material.dart';
import 'package:mon_projet/screens/loginscreen.dart';

/// Screen that lets the user request a password‑reset email.
class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController controllerEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Forgot password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 16),

            Image.asset(
              "assets/logo.png",
              height: 220,
            ),

            const SizedBox(height: 12),

            const Text(
              "Reset your password",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Form to capture and validate the email address to reset.
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Email",
                    style: TextStyle(
                      color: primary,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: controllerEmail,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email is empty";
                      }

                      final emailRegex = RegExp(
                        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+",
                      );

                      if (!emailRegex.hasMatch(value)) {
                        return "Enter valid email";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Enter your email",
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 183, 186, 186),
                      ),
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Color.fromARGB(255, 183, 186, 186),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Primary action to send the reset link.
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Send reset link",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      onPressed: () {
                        if (_formKey.currentState!.validate()) {

                          // After "sending" the link we navigate back to login.
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Loginscreen(),
                            ),
                          );

                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Secondary action to just return to the login screen.
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Loginscreen(),
                          ),
                        );
                      },
                      child: const Text("Back to login"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}