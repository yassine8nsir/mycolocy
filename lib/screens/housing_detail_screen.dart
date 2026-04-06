import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet/core/constants/app_colors.dart';
import 'package:mon_projet/core/constants/app_constants.dart';
import 'package:mon_projet/models/housing_model.dart';
import 'package:mon_projet/providers/auth_provider.dart';
import 'package:mon_projet/providers/chat_provider.dart';
import 'package:mon_projet/providers/housing_provider.dart';
import 'package:mon_projet/providers/recommendation_provider.dart';
import 'package:mon_projet/screens/chat_screen.dart';

class HousingDetailScreen extends StatefulWidget {
  final HousingModel housing;
  const HousingDetailScreen({super.key, required this.housing});

  @override
  State<HousingDetailScreen> createState() => _HousingDetailScreenState();
}

class _HousingDetailScreenState extends State<HousingDetailScreen> {
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fire-and-forget: record this listing as viewed for recommendations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationProvider>().recordView(widget.housing.id);
    });
  }

  String _imgUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${AppConstants.baseUrl.replaceAll('/api', '')}$path';
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete listing?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final ok =
        await context.read<HousingProvider>().delete(widget.housing.id);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.housing;
    final currentUserId = context.watch<AuthProvider>().user?.id;
    final isOwner = currentUserId == h.owner?.id;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Image header ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            actions: [
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: _delete,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  if (h.images.isNotEmpty)
                    PageView.builder(
                      itemCount: h.images.length,
                      onPageChanged: (i) => setState(() => _imageIndex = i),
                      itemBuilder: (_, i) => CachedNetworkImage(
                        imageUrl: _imgUrl(h.images[i]),
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                            color: AppColors.primaryLight),
                        errorWidget: (_, __, ___) =>
                            Container(color: AppColors.primaryLight,
                              child: const Icon(Icons.home, size: 60,
                                  color: AppColors.primary)),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.primaryLight,
                      child: const Center(
                        child: Icon(Icons.home, size: 80, color: AppColors.primary),
                      ),
                    ),
                  // Image counter
                  if (h.images.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_imageIndex + 1}/${h.images.length}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(h.title,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark)),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${h.price.toInt()} TND/mo',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.textLight, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      [h.city, h.address].where((s) => s != null && s.isNotEmpty).join(', '),
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                  ]),
                  if (h.university != null && h.university!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.school_outlined,
                          color: AppColors.textLight, size: 16),
                      const SizedBox(width: 4),
                      Text(h.university!,
                          style: const TextStyle(color: AppColors.textLight)),
                    ]),
                  ],
                  const SizedBox(height: 16),

                  // Quick stats chips
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _chip(Icons.bed_outlined, '${h.rooms} rooms'),
                    _chip(Icons.bathtub_outlined, '${h.bathrooms} bath'),
                    if (h.area != null)
                      _chip(Icons.square_foot, '${h.area!.toInt()} m²'),
                    _chip(Icons.home_outlined,
                        h.type[0].toUpperCase() + h.type.substring(1)),
                    if (h.furnished)
                      _chip(Icons.chair_outlined, 'Furnished'),
                  ]),
                  const SizedBox(height: 20),

                  // Description
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Text(h.description,
                      style: const TextStyle(
                          color: AppColors.textMedium, height: 1.5)),
                  const SizedBox(height: 20),

                  // Amenities
                  const Text('Amenities',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  _amenitiesGrid(h.amenities),
                  const SizedBox(height: 20),

                  // Owner card
                  if (h.owner != null) _ownerCard(h),
                  const SizedBox(height: 20),

                  // Roommates needed badge
                  if (h.roommatesNeeded > 0)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(children: [
                        const Icon(Icons.groups_outlined,
                            color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text(
                          '${h.roommatesNeeded} roommate(s) needed · '
                          '${h.genderPreference == 'any' ? 'Any gender' : h.genderPreference}',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500),
                        ),
                      ]),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),

      // Contact button (shown to non-owners)
      bottomNavigationBar: isOwner
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () async {
                    final chat = context.read<ChatProvider>();
                    final nav = Navigator.of(context);
                    final conv = await chat.startConversation(
                      widget.housing.owner!.id,
                      widget.housing.id,
                    );
                    if (conv != null) {
                      nav.push(MaterialPageRoute(
                        builder: (_) => ChatScreen(conversation: conv),
                      ));
                    }
                  },
                  icon: const Icon(Icons.message_outlined),
                  label: const Text('Contact Owner'),
                ),
              ),
            ),
    );
  }

  Widget _chip(IconData icon, String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: AppColors.primary, fontSize: 13)),
        ]),
      );

  Widget _amenitiesGrid(HousingAmenities a) {
    final items = [
      if (a.wifi) _amenityItem(Icons.wifi, 'Wi-Fi'),
      if (a.parking) _amenityItem(Icons.local_parking, 'Parking'),
      if (a.airConditioning) _amenityItem(Icons.ac_unit, 'A/C'),
      if (a.heating) _amenityItem(Icons.thermostat, 'Heating'),
      if (a.washingMachine) _amenityItem(Icons.local_laundry_service, 'Washing'),
      if (a.elevator) _amenityItem(Icons.elevator, 'Elevator'),
    ];

    if (items.isEmpty) {
      return const Text('No amenities listed.',
          style: TextStyle(color: AppColors.textLight));
    }
    return Wrap(spacing: 10, runSpacing: 10, children: items);
  }

  Widget _amenityItem(IconData icon, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accent, size: 18),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: AppColors.textMedium)),
        ],
      );

  Widget _ownerCard(HousingModel h) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              h.owner!.fullName[0].toUpperCase(),
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.owner!.fullName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                  if (h.owner!.university != null)
                    Text(h.owner!.university!,
                        style: const TextStyle(
                            color: AppColors.textLight, fontSize: 12)),
                ]),
          ),
        ]),
      );
}
