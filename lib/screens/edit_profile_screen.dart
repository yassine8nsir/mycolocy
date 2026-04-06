import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet/core/constants/app_colors.dart';
import 'package:mon_projet/core/utils/validators.dart';
import 'package:mon_projet/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _universityCtrl;
  late final TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _universityCtrl = TextEditingController(text: user?.university ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _universityCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final ok = await auth.updateProfile({
      'fullName': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'university': _universityCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
    });

    if (!mounted) return;
    if (ok) {
      nav.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Update failed'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar placeholder ───────────────────────
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        _nameCtrl.text.isNotEmpty
                            ? _nameCtrl.text[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 36,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Fields ───────────────────────────────────
              _label('Full Name'),
              TextFormField(
                controller: _nameCtrl,
                validator: (v) => Validators.required(v, field: 'Full name'),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon:
                      Icon(Icons.person_outline, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),

              _label('Phone'),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '+216 XX XXX XXX',
                  prefixIcon:
                      Icon(Icons.phone_outlined, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),

              _label('University'),
              TextFormField(
                controller: _universityCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. University of Tunis',
                  prefixIcon:
                      Icon(Icons.school_outlined, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),

              _label('Bio'),
              TextFormField(
                controller: _bioCtrl,
                maxLines: 3,
                maxLength: 300,
                decoration: const InputDecoration(
                  hintText: 'Tell roommates a bit about yourself...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: isLoading ? null : _save,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Changes'),
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
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.textDark)),
      );
}
