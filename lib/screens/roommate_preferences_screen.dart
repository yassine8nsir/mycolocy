import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet/core/constants/app_colors.dart';
import 'package:mon_projet/providers/auth_provider.dart';
import 'package:mon_projet/providers/roommate_provider.dart';

class RoommatePreferencesScreen extends StatefulWidget {
  const RoommatePreferencesScreen({super.key});

  @override
  State<RoommatePreferencesScreen> createState() =>
      _RoommatePreferencesScreenState();
}

class _RoommatePreferencesScreenState
    extends State<RoommatePreferencesScreen> {
  final _budgetCtrl = TextEditingController();
  String _gender = 'any';
  bool _smoking = false;
  bool _pets = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill from current user preferences
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _budgetCtrl.text = user.preferences.budget > 0
          ? user.preferences.budget.toInt().toString()
          : '';
      _gender = user.preferences.gender;
      _smoking = user.preferences.smoking;
      _pets = user.preferences.pets;
    }
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<RoommateProvider>();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final ok = await provider.savePreferences({
      'budget': double.tryParse(_budgetCtrl.text.trim()) ?? 0,
      'gender': _gender,
      'smoking': _smoking,
      'pets': _pets,
    });

    if (!mounted) return;
    if (ok) {
      // Reload auth user so preferences reflect everywhere
      await context.read<AuthProvider>().checkAuth();
      nav.pop(true); // signal caller to reload matches
      messenger.showSnackBar(
        const SnackBar(content: Text('Preferences saved!')),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to save'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<RoommateProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(title: const Text('My Roommate Preferences')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info banner ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'These preferences are used to calculate your '
                    'compatibility score with other users.',
                    style: TextStyle(
                        color: AppColors.primary, fontSize: 13),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 28),

            // ── Budget ───────────────────────────────────────
            _label('Monthly budget (TND)'),
            TextFormField(
              controller: _budgetCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 400',
                prefixIcon:
                    Icon(Icons.wallet_outlined, color: AppColors.primary),
                suffixText: 'TND/mo',
              ),
            ),
            const SizedBox(height: 24),

            // ── Gender preference ────────────────────────────
            _label('Preferred roommate gender'),
            _SegmentRow(
              options: const ['any', 'male', 'female'],
              labels: const ['Any', 'Male', 'Female'],
              selected: _gender,
              onSelect: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 24),

            // ── Lifestyle ────────────────────────────────────
            _label('Lifestyle'),
            _ToggleTile(
              icon: Icons.smoking_rooms,
              title: 'I smoke',
              subtitle: 'Match me with other smokers',
              value: _smoking,
              onChanged: (v) => setState(() => _smoking = v),
            ),
            const SizedBox(height: 10),
            _ToggleTile(
              icon: Icons.pets,
              title: 'I have pets',
              subtitle: 'Match me with pet-friendly roommates',
              value: _pets,
              onChanged: (v) => setState(() => _pets = v),
            ),
            const SizedBox(height: 36),

            // ── Save ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: isSaving ? null : _save,
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save & Find Matches'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.textDark)),
      );
}

class _SegmentRow extends StatelessWidget {
  final List<String> options;
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onSelect;

  const _SegmentRow({
    required this.options,
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(options.length, (i) {
        final active = selected == options[i];
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(options[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i < options.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? AppColors.primary : AppColors.divider,
                ),
              ),
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: active ? Colors.white : AppColors.textMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? AppColors.primary : AppColors.divider,
          width: value ? 1.5 : 1,
        ),
      ),
      child: SwitchListTile(
        secondary: Icon(icon,
            color: value ? AppColors.primary : AppColors.textLight),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.textDark)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                color: AppColors.textLight, fontSize: 12)),
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}
