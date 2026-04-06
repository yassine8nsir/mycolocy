import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet/core/constants/app_colors.dart';
import 'package:mon_projet/models/roommate_model.dart';
import 'package:mon_projet/providers/auth_provider.dart';
import 'package:mon_projet/providers/chat_provider.dart';
import 'package:mon_projet/providers/roommate_provider.dart';
import 'package:mon_projet/screens/chat_screen.dart';
import 'package:mon_projet/screens/roommate_preferences_screen.dart';

class RoommateScreen extends StatefulWidget {
  const RoommateScreen({super.key});

  @override
  State<RoommateScreen> createState() => _RoommateScreenState();
}

class _RoommateScreenState extends State<RoommateScreen> {
  int _minScore = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoommateProvider>().loadMatches();
    });
  }

  Future<void> _openPreferences() async {
    final reloaded = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => const RoommatePreferencesScreen()),
    );
    if (reloaded == true && mounted) {
      context.read<RoommateProvider>().loadMatches(minScore: _minScore);
    }
  }

  Future<void> _contactUser(RoommateMatch match) async {
    final chat = context.read<ChatProvider>();
    final nav = Navigator.of(context);
    final conv = await chat.startConversation(match.user.id, null);
    if (conv != null && mounted) {
      nav.push(MaterialPageRoute(
          builder: (_) => ChatScreen(conversation: conv)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoommateProvider>();
    final myId = context.watch<AuthProvider>().user?.id ?? '';
    final filtered = provider.matches
        .where((m) => m.score >= _minScore)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Find Roommates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'My preferences',
            onPressed: _openPreferences,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Score filter bar ─────────────────────────────
          _ScoreFilterBar(
            current: _minScore,
            onChanged: (v) => setState(() => _minScore = v),
          ),

          // ── Results count ────────────────────────────────
          if (!provider.isLoading)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(children: [
                Text(
                  '${filtered.length} match${filtered.length == 1 ? '' : 'es'} found',
                  style: const TextStyle(
                      color: AppColors.textLight, fontSize: 13),
                ),
              ]),
            ),

          // ── List ─────────────────────────────────────────
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? _EmptyState(onSetPrefs: _openPreferences)
                    : RefreshIndicator(
                        onRefresh: () => provider.loadMatches(
                            minScore: _minScore),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _MatchCard(
                            match: filtered[i],
                            myId: myId,
                            onContact: () => _contactUser(filtered[i]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Score filter chips ────────────────────────────────────────
class _ScoreFilterBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onChanged;

  const _ScoreFilterBar(
      {required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      (0, 'All'),
      (40, '40%+'),
      (60, '60%+'),
      (75, '75%+'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: options.map((opt) {
          final (score, label) = opt;
          final active = current == score;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(score),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Match card ────────────────────────────────────────────────
class _MatchCard extends StatelessWidget {
  final RoommateMatch match;
  final String myId;
  final VoidCallback onContact;

  const _MatchCard(
      {required this.match,
      required this.myId,
      required this.onContact});

  @override
  Widget build(BuildContext context) {
    final u = match.user;
    final b = match.breakdown;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    u.fullName.isNotEmpty
                        ? u.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + university
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textDark)),
                      if (u.university != null &&
                          u.university!.isNotEmpty)
                        Text(u.university!,
                            style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),

                // Score badge
                _ScoreBadge(score: match.score, color: match.scoreColor),
              ],
            ),
            const SizedBox(height: 12),

            // ── Compatibility label ──────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Color.fromARGB(
                    25,
                    (match.scoreColor.r * 255).round(),
                    (match.scoreColor.g * 255).round(),
                    (match.scoreColor.b * 255).round()),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                match.compatibilityLabel,
                style: TextStyle(
                    color: match.scoreColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 14),

            // ── Score breakdown bars ─────────────────────────
            _BreakdownBar('Budget', b.budget, 35),
            _BreakdownBar('Gender', b.gender, 25),
            _BreakdownBar('Smoking', b.smoking, 20),
            _BreakdownBar('Pets', b.pets, 15),
            _BreakdownBar('University', b.university, 5),
            const SizedBox(height: 14),

            // ── Preferences tags ─────────────────────────────
            Wrap(spacing: 6, runSpacing: 6, children: [
              if (u.preferences.budget > 0)
                _tag(Icons.wallet_outlined,
                    '${u.preferences.budget.toInt()} TND/mo'),
              _tag(
                  u.preferences.smoking
                      ? Icons.smoking_rooms
                      : Icons.smoke_free,
                  u.preferences.smoking ? 'Smoker' : 'Non-smoker'),
              _tag(
                  u.preferences.pets ? Icons.pets : Icons.pets_outlined,
                  u.preferences.pets ? 'Has pets' : 'No pets'),
              if (u.preferences.gender != 'any')
                _tag(Icons.person_outline,
                    '${u.preferences.gender[0].toUpperCase()}${u.preferences.gender.substring(1)} only'),
            ]),
            const SizedBox(height: 14),

            // ── Contact button ───────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onContact,
                icon: const Icon(Icons.message_outlined, size: 18),
                label: const Text('Send Message'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: AppColors.textLight),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMedium, fontSize: 12)),
        ]),
      );
}

// ── Score badge ───────────────────────────────────────────────
class _ScoreBadge extends StatelessWidget {
  final int score;
  final Color color;

  const _ScoreBadge({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 4,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        Text(
          '$score%',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color),
        ),
      ],
    );
  }
}

// ── Breakdown progress bar ────────────────────────────────────
class _BreakdownBar extends StatelessWidget {
  final String label;
  final int earned;
  final int max;

  const _BreakdownBar(this.label, this.earned, this.max);

  @override
  Widget build(BuildContext context) {
    final pct = max > 0 ? earned / max : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(
          width: 72,
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textLight, fontSize: 11)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                pct >= 1.0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$earned/$max',
            style: const TextStyle(
                color: AppColors.textLight, fontSize: 10)),
      ]),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onSetPrefs;

  const _EmptyState({required this.onSetPrefs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline,
                size: 72, color: AppColors.divider),
            const SizedBox(height: 16),
            const Text('No matches found',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMedium)),
            const SizedBox(height: 8),
            const Text(
              'Set your preferences so we can\nfind your best matches',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onSetPrefs,
              icon: const Icon(Icons.tune),
              label: const Text('Set Preferences'),
            ),
          ],
        ),
      ),
    );
  }
}
