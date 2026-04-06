import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet/core/utils/validators.dart';
import 'package:mon_projet/providers/auth_provider.dart';
import 'package:mon_projet/providers/chat_provider.dart';
import 'package:mon_projet/screens/navigation.dart';
import 'package:mon_projet/screens/registerscreen.dart';
import 'package:mon_projet/screens/forgetpasswordscreen.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Capture providers before any await to avoid BuildContext across async gaps
    final auth = context.read<AuthProvider>();
    final chat = context.read<ChatProvider>();
    final nav = Navigator.of(context);

    final ok = await auth.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;
    if (ok) {
      // Connect Socket.io as soon as we have a valid token
      final token = await auth.getToken();
      if (token != null) chat.connect(token);

      nav.pushReplacement(
        MaterialPageRoute(builder: (_) => const Navigation()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login failed'),
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
              const SizedBox(height: 16),
              Image.asset('assets/logo.png', height: 120, width: 160),
              const SizedBox(height: 12),
              const Text(
                'Welcome back',
                style: TextStyle(
                  color: Color(0xFF1E2235),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Log in to continue finding your next coloc.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8A90A6)),
              ),
              const SizedBox(height: 28),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Email ──────────────────────────────────
                    const Text('Email',
                        style: TextStyle(color: Color(0xFF1E2235), fontSize: 16)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email, color: primary),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Password ───────────────────────────────
                    const Text('Password',
                        style: TextStyle(color: Color(0xFF1E2235), fontSize: 16)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Password is required' : null,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock, color: primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: primary,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),

                    // ── Forgot password ────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgetPassword()),
                        ),
                        child: Text('Forgot password?',
                            style: TextStyle(color: primary)),
                      ),
                    ),
                    const SizedBox(height: 16),

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
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Sign up link ───────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const Registerscreen()),
                          ),
                          child:
                              Text('Sign up', style: TextStyle(color: primary)),
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
