import 'package:flutter/material.dart';
import 'package:mon_projet/screens/forgetpasswordscreen.dart';
import 'package:mon_projet/screens/navigation.dart';

/// Email/password login screen used after onboarding.
class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerPassword = TextEditingController();
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Brand logo at the top.
              Image.asset(
                "assets/logo.jpeg",
                height: 120,
                width: 160,
              ),
              const SizedBox(height: 12),
              const Text(
                "Welcome back",
                style: TextStyle(
                  color: Color(0xFF1E2235),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Log in to continue finding your next coloc.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8A90A6)),
              ),
              const SizedBox(height: 28),
              // Main login form with validation.
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Email",
                      style: TextStyle(
                        color: Color(0xFF1E2235),
                        fontSize: 19,
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
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        prefixIcon: Icon(Icons.email, color: primary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Password",
                      style: TextStyle(
                        color: Color(0xFF1E2235),
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: controllerPassword,
                      obscureText: obscurePassword,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Password is empty";
                        }
                        final passwordRegex = RegExp(
                          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
                        );
                        if (!passwordRegex.hasMatch(value)) {
                          return "Enter a valid password";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        prefixIcon: Icon(Icons.lock, color: primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: primary,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Link to go to the password reset flow.
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgetPassword(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(
                            color: primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      height: 54,
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // On successful login we replace the stack with the main navigation.
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Navigation(),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Simple prompt for users who do not yet have an account.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            // Navigate to sign up screen (to be implemented)
                          },
                          child: Text(
                            "Sign up",
                            style: TextStyle(color: primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
