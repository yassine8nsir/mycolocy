import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet/core/constants/app_colors.dart';
import 'package:mon_projet/providers/auth_provider.dart';
import 'package:mon_projet/providers/chat_provider.dart';
import 'package:mon_projet/providers/housing_provider.dart';
import 'package:mon_projet/screens/edit_profile_screen.dart';
import 'package:mon_projet/screens/loginscreen.dart';
import 'package:mon_projet/screens/my_listings_screen.dart';
import 'package:mon_projet/screens/roommate_preferences_screen.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HousingProvider>().loadMyListings();
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to log in again to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final auth = context.read<AuthProvider>();
    final chat = context.read<ChatProvider>();
    chat.disconnect();
    await auth.logout();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Loginscreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final myListings = context.watch<HousingProvider>().myListings;
    final conversations = context.watch<ChatProvider>().conversations;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit profile',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Avatar + name card ───────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 16,
                    offset: Offset(0, 6))
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    user.fullName[0].toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark),
                      ),
                      const SizedBox(height: 3),
                      Text(user.email,
                          style: const TextStyle(
                              color: AppColors.textLight, fontSize: 13)),
                      if (user.university != null &&
                          user.university!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(children: [
                          const Icon(Icons.school_outlined,
                              size: 13, color: AppColors.textLight),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(user.university!,
                                style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ]),
                      ],
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.role[0].toUpperCase() +
                              user.role.substring(1),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Stats row ────────────────────────────────────
          Row(children: [
            Expanded(
                child: _StatCard(
                    label: 'Listings',
                    value: '${myListings.length}',
                    icon: Icons.home_outlined)),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCard(
                    label: 'Chats',
                    value: '${conversations.length}',
                    icon: Icons.chat_bubble_outline)),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCard(
                    label: 'Budget',
                    value: user.preferences.budget > 0
                        ? '${user.preferences.budget.toInt()}'
                        : '—',
                    icon: Icons.wallet_outlined)),
          ]),
          const SizedBox(height: 22),

          // ── Account section ──────────────────────────────
          _sectionTitle('Account'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Personal information',
            subtitle: 'Name, phone, university',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          _SettingsTile(
            icon: Icons.home_outlined,
            title: 'My listings',
            subtitle: '${myListings.length} active listing${myListings.length == 1 ? '' : 's'}',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyListingsScreen()),
            ),
          ),
          _SettingsTile(
            icon: Icons.people_outline,
            title: 'Roommate preferences',
            subtitle: 'Budget, lifestyle, gender',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const RoommatePreferencesScreen()),
            ),
          ),
          const SizedBox(height: 10),

          // ── Preferences section ──────────────────────────
          _sectionTitle('Preferences'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About MyColocy',
            subtitle: 'Version 1.0.0',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'MyColocy',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2024 MyColocy',
            ),
          ),
          const SizedBox(height: 10),

          // ── Danger zone ──────────────────────────────────
          _DangerTile(
            icon: Icons.logout,
            title: 'Log out',
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textLight,
                letterSpacing: 0.5)),
      );
}

// ── Stat card ─────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Settings tile ─────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: const TextStyle(
                              color: AppColors.textLight, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.textLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Danger tile ───────────────────────────────────────────────
class _DangerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DangerTile(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE7E7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.error)),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
