import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet/core/utils/validators.dart';
import 'package:mon_projet/providers/auth_provider.dart';
import 'package:mon_projet/screens/navigation.dart';

class Registerscreen extends StatefulWidget {
  const Registerscreen({super.key});

  @override
  State<Registerscreen> createState() => _RegisterscreenState();
}

class _RegisterscreenState extends State<Registerscreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _universityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    _universityCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      fullName: _fullNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      university: _universityCtrl.text.trim().isEmpty
          ? null
          : _universityCtrl.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Navigation()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Registration failed'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Image.asset('assets/logo.png', height: 100, width: 120),
              const SizedBox(height: 10),
              const Text(
                'Create Account',
                style: TextStyle(
                  color: Color(0xFF1E2235),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Join MyColocy and find your perfect coloc',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8A90A6)),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Full Name ──────────────────────────────
                    _label('Full Name'),
                    TextFormField(
                      controller: _fullNameCtrl,
                      validator: (v) => Validators.required(v, field: 'Full name'),
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(Icons.person, color: primary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Email ──────────────────────────────────
                    _label('Email'),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email, color: primary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Phone (optional) ───────────────────────
                    _label('Phone (optional)'),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '+216 XX XXX XXX',
                        prefixIcon: Icon(Icons.phone, color: primary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── University (optional) ──────────────────
                    _label('University (optional)'),
                    TextFormField(
                      controller: _universityCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. University of Tunis',
                        prefixIcon: Icon(Icons.school, color: primary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Password ───────────────────────────────
                    _label('Password'),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      validator: Validators.password,
                      decoration: InputDecoration(
                        hintText: 'Min 8 chars, 1 uppercase, 1 number',
                        prefixIcon: Icon(Icons.lock, color: primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: primary,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Confirm Password ───────────────────────
                    _label('Confirm Password'),
                    TextFormField(
                      controller: _confirmPassCtrl,
                      obscureText: _obscureConfirm,
                      validator: (v) =>
                          Validators.confirmPassword(v, _passwordCtrl.text),
                      decoration: InputDecoration(
                        hintText: 'Repeat your password',
                        prefixIcon: Icon(Icons.lock_outline, color: primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: primary,
                          ),
                          onPressed: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Submit ─────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Sign Up'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Back to login ──────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Login',
                              style: TextStyle(color: primary)),
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFF1E2235), fontSize: 15),
        ),
      );
}
