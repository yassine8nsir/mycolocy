import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet/core/constants/app_colors.dart';
import 'package:mon_projet/core/constants/app_constants.dart';
import 'package:mon_projet/models/housing_model.dart';
import 'package:mon_projet/providers/housing_provider.dart';
import 'package:mon_projet/screens/create_housing_screen.dart';
import 'package:mon_projet/screens/housing_detail_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HousingProvider>().loadMyListings();
    });
  }

  String _imgUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${AppConstants.baseUrl.replaceAll('/api', '')}$path';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HousingProvider>();
    final listings = provider.myListings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Listings')),
      body: provider.isLoading && listings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : listings.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<HousingProvider>().loadMyListings(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listings.length,
                    itemBuilder: (_, i) => _MyListingCard(
                      housing: listings[i],
                      imgUrl: _imgUrl,
                      onDelete: () async {
                        final provider = context.read<HousingProvider>();
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await provider.delete(listings[i].id);
                        if (ok && mounted) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Listing deleted')),
                          );
                        }
                      },
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateHousingScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Listing'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_outlined, size: 72, color: AppColors.divider),
            const SizedBox(height: 16),
            const Text('No listings yet',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMedium)),
            const SizedBox(height: 8),
            const Text('Tap + to publish your first listing',
                style: TextStyle(color: AppColors.textLight)),
          ],
        ),
      );
}

class _MyListingCard extends StatelessWidget {
  final HousingModel housing;
  final String Function(String) imgUrl;
  final VoidCallback onDelete;

  const _MyListingCard({
    required this.housing,
    required this.imgUrl,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final h = housing;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HousingDetailScreen(housing: h)),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: h.images.isNotEmpty
                  ? Image.network(
                      imgUrl(h.images.first),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: AppColors.primaryLight,
                          child: const Icon(Icons.home,
                              color: AppColors.primary)),
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.home, color: AppColors.primary),
                    ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${h.price.toInt()} TND/mo · ${h.city}',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(
                        h.isAvailable ? Icons.check_circle : Icons.cancel,
                        size: 13,
                        color: h.isAvailable
                            ? AppColors.success
                            : AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        h.isAvailable ? 'Available' : 'Unavailable',
                        style: TextStyle(
                            fontSize: 12,
                            color: h.isAvailable
                                ? AppColors.success
                                : AppColors.textLight),
                      ),
                    ]),
                  ],
                ),
              ),
            ),

            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 20),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete listing?'),
                    content: const Text('This cannot be undone.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.error),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirm == true) onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
