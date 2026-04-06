import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet/core/constants/app_colors.dart';
import 'package:mon_projet/core/constants/app_constants.dart';
import 'package:mon_projet/models/housing_model.dart';
import 'package:mon_projet/providers/auth_provider.dart';
import 'package:mon_projet/providers/housing_provider.dart';
import 'package:mon_projet/providers/recommendation_provider.dart';
import 'package:mon_projet/screens/create_housing_screen.dart';
import 'package:mon_projet/screens/housing_detail_screen.dart';
import 'package:mon_projet/screens/recommendations_screen.dart';
import 'package:mon_projet/screens/roommate_screen.dart';
import 'package:mon_projet/screens/searchscreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HousingProvider>().loadListings(refresh: true);
      context.read<RecommendationProvider>().loadTrending();
      context.read<RecommendationProvider>().loadRecommendations();
    });
  }

  String _imgUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${AppConstants.baseUrl.replaceAll('/api', '')}$path';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final housing = context.watch<HousingProvider>();
    final recs = context.watch<RecommendationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              context.read<HousingProvider>().loadListings(refresh: true),
          child: CustomScrollView(
            slivers: [
              // ── Header ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, ${auth.user?.fullName.split(' ').first ?? 'there'} 👋',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark),
                          ),
                          const Text('Find your perfect coloc',
                              style: TextStyle(color: AppColors.textLight)),
                        ],
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          (auth.user?.fullName[0] ?? 'U').toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Search bar ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SearchScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: AppColors.shadow, blurRadius: 8,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: const Row(children: [
                        Icon(Icons.search, color: AppColors.textLight),
                        SizedBox(width: 10),
                        Text('Search by city, university...',
                            style: TextStyle(color: AppColors.textLight)),
                      ]),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Roommate banner ────────────────────────────
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RoommateScreen()),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3068E6), Color(0xFF5B8DF6)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(children: [
                      const Icon(Icons.people_outline,
                          color: Colors.white, size: 36),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Find a Roommate',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            SizedBox(height: 2),
                            Text('See your compatibility scores',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white70, size: 16),
                    ]),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── For You section ────────────────────────────
              if (recs.recommendations.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(children: [
                          Icon(Icons.auto_awesome,
                              color: AppColors.primary, size: 18),
                          SizedBox(width: 6),
                          Text('For You',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark)),
                        ]),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const RecommendationsScreen()),
                          ),
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: recs.recommendations.length.clamp(0, 6),
                      itemBuilder: (_, i) {
                        final rec = recs.recommendations[i];
                        final h = rec.housing;
                        return GestureDetector(
                          onTap: () {
                            recs.recordView(h.id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      HousingDetailScreen(housing: h)),
                            );
                          },
                          child: Container(
                            width: 190,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 6,
                                    offset: Offset(0, 2))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    child: h.images.isNotEmpty
                                        ? Image.network(
                                            _imgUrl(h.images.first),
                                            height: 110,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                    height: 110,
                                                    color:
                                                        AppColors.primaryLight),
                                          )
                                        : Container(
                                            height: 110,
                                            color: AppColors.primaryLight,
                                            child: const Center(
                                                child: Icon(Icons.home,
                                                    color: AppColors.primary))),
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text('${rec.score}%',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ]),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(h.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: AppColors.textDark),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 2),
                                      Text('${h.price.toInt()} TND/mo',
                                          style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],

              // ── Section title ──────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Available Listings',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── Listings ───────────────────────────────────
              if (housing.isLoading && housing.listings.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (housing.listings.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_outlined,
                            size: 64, color: AppColors.textLight),
                        SizedBox(height: 12),
                        Text('No listings yet',
                            style: TextStyle(color: AppColors.textLight)),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == housing.listings.length) {
                        return housing.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                    child: CircularProgressIndicator()),
                              )
                            : housing.hasMore
                                ? TextButton(
                                    onPressed: () => context
                                        .read<HousingProvider>()
                                        .loadListings(),
                                    child: const Text('Load more'),
                                  )
                                : const SizedBox(height: 80);
                      }
                      return _HousingCard(
                        housing: housing.listings[index],
                        imgUrl: _imgUrl,
                      );
                    },
                    childCount: housing.listings.length + 1,
                  ),
                ),
            ],
          ),
        ),
      ),

      // ── FAB — publish a listing ────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateHousingScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Publish'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ── Reusable card widget ──────────────────────────────────────
class _HousingCard extends StatelessWidget {
  final HousingModel housing;
  final String Function(String) imgUrl;

  const _HousingCard({required this.housing, required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    final h = housing;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => HousingDetailScreen(housing: h)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 8,
                offset: Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: h.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imgUrl(h.images.first),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                          height: 180, color: AppColors.primaryLight),
                      errorWidget: (_, __, ___) => Container(
                        height: 180,
                        color: AppColors.primaryLight,
                        child: const Icon(Icons.home,
                            size: 60, color: AppColors.primary),
                      ),
                    )
                  : Container(
                      height: 180,
                      color: AppColors.primaryLight,
                      child: const Center(
                          child: Icon(Icons.home,
                              size: 60, color: AppColors.primary)),
                    ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(h.title,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text('${h.price.toInt()} TND/mo',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.textLight),
                    const SizedBox(width: 3),
                    Text(h.city,
                        style: const TextStyle(
                            color: AppColors.textLight, fontSize: 13)),
                    if (h.university != null &&
                        h.university!.isNotEmpty) ...[
                      const Text(' · ',
                          style: TextStyle(color: AppColors.textLight)),
                      Expanded(
                        child: Text(h.university!,
                            style: const TextStyle(
                                color: AppColors.textLight, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    _tag(Icons.bed_outlined, '${h.rooms} rooms'),
                    const SizedBox(width: 8),
                    _tag(Icons.groups_outlined,
                        '${h.roommatesNeeded} needed'),
                    if (h.furnished) ...[
                      const SizedBox(width: 8),
                      _tag(Icons.chair_outlined, 'Furnished'),
                    ],
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textLight),
          const SizedBox(width: 3),
          Text(label,
              style:
                  const TextStyle(color: AppColors.textLight, fontSize: 12)),
        ],
      );
}
