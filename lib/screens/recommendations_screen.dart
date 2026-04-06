import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet/core/constants/app_colors.dart';
import 'package:mon_projet/core/constants/app_constants.dart';
import 'package:mon_projet/models/recommendation_model.dart';
import 'package:mon_projet/providers/recommendation_provider.dart';
import 'package:mon_projet/screens/housing_detail_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationProvider>().loadRecommendations();
    });
  }

  String _imgUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${AppConstants.baseUrl.replaceAll('/api', '')}$path';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecommendationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('For You'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<RecommendationProvider>().loadRecommendations(),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.recommendations.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: () => context
                      .read<RecommendationProvider>()
                      .loadRecommendations(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 32),
                    itemCount: provider.recommendations.length,
                    itemBuilder: (_, i) => _RecommendationCard(
                      rec: provider.recommendations[i],
                      imgUrl: _imgUrl,
                      onTap: () {
                        provider.recordView(
                            provider.recommendations[i].housing.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HousingDetailScreen(
                              housing: provider.recommendations[i].housing,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome,
                  size: 72, color: AppColors.divider),
              const SizedBox(height: 16),
              const Text('No recommendations yet',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMedium)),
              const SizedBox(height: 8),
              const Text(
                'Set your budget and university in your profile\nto get personalised suggestions',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () =>
                    context.read<RecommendationProvider>().loadRecommendations(),
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
}

// ── Recommendation card ───────────────────────────────────────
class _RecommendationCard extends StatelessWidget {
  final RecommendationModel rec;
  final String Function(String) imgUrl;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.rec,
    required this.imgUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final h = rec.housing;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image + score overlay ──────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18)),
                  child: h.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imgUrl(h.images.first),
                          height: 170,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                              height: 170,
                              color: AppColors.primaryLight),
                          errorWidget: (_, __, ___) => Container(
                            height: 170,
                            color: AppColors.primaryLight,
                            child: const Icon(Icons.home,
                                size: 60, color: AppColors.primary),
                          ),
                        )
                      : Container(
                          height: 170,
                          color: AppColors.primaryLight,
                          child: const Center(
                              child: Icon(Icons.home,
                                  size: 60, color: AppColors.primary)),
                        ),
                ),

                // Match score badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _scoreColor(rec.score),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${rec.score}% match',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(h.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text('${h.price.toInt()} TND/mo',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.textLight),
                    const SizedBox(width: 3),
                    Text(h.city,
                        style: const TextStyle(
                            color: AppColors.textLight, fontSize: 12)),
                    if (h.university != null && h.university!.isNotEmpty)
                      Expanded(
                        child: Text(' · ${h.university!}',
                            style: const TextStyle(
                                color: AppColors.textLight, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                  ]),
                  const SizedBox(height: 10),

                  // Why this was recommended
                  if (rec.reasons.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: rec.reasons
                          .map((r) => _reasonChip(r))
                          .toList(),
                    ),
                  const SizedBox(height: 10),

                  // Score breakdown mini-bars
                  _BreakdownRow(breakdown: rec.breakdown),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reasonChip(String reason) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_outline,
              size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(reason,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ]),
      );

  Color _scoreColor(int score) {
    if (score >= 75) return AppColors.success;
    if (score >= 55) return AppColors.primary;
    if (score >= 35) return AppColors.warning;
    return AppColors.textLight;
  }
}

// ── Mini breakdown bar row ────────────────────────────────────
class _BreakdownRow extends StatelessWidget {
  final RecommendationBreakdown breakdown;
  const _BreakdownRow({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Budget', breakdown.budget, 35),
      ('Uni', breakdown.university, 25),
      ('Gender', breakdown.gender, 20),
      ('Recent', breakdown.recency, 12),
      ('Furnished', breakdown.furnished, 8),
    ];

    return Column(
      children: items
          .where((i) => i.$2 > 0)
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(children: [
                  SizedBox(
                    width: 58,
                    child: Text(item.$1,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textLight)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: item.$2 / item.$3,
                        minHeight: 5,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('${item.$2}/${item.$3}',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textLight)),
                ]),
              ))
          .toList(),
    );
  }
}
