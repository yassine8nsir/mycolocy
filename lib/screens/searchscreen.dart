import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet/core/constants/app_colors.dart';
import 'package:mon_projet/core/constants/app_constants.dart';
import 'package:mon_projet/models/housing_model.dart';
import 'package:mon_projet/providers/housing_provider.dart';
import 'package:mon_projet/screens/housing_detail_screen.dart';
import 'package:mon_projet/widgets/common/filter_bottom_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  FilterState _filters = FilterState.empty;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    // Load cities/types for filter chips
    context.read<HousingProvider>().loadMeta();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    context.read<HousingProvider>().clearSearch();
    super.dispose();
  }

  // Wait 500ms after the user stops typing before hitting the API
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _runSearch);
  }

  Future<void> _runSearch() async {
    setState(() => _hasSearched = true);
    await context.read<HousingProvider>().search(
          query: _searchCtrl.text.trim(),
          city: _filters.city,
          minPrice: _filters.minPrice > 0 ? _filters.minPrice : null,
          maxPrice: _filters.maxPrice < 2000 ? _filters.maxPrice : null,
          rooms: _filters.minRooms,
          type: _filters.type,
          furnished: _filters.furnished,
        );
  }

  void _openFilters() {
    final provider = context.read<HousingProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        current: _filters,
        cities: provider.availableCities,
        onApply: (newFilters) {
          setState(() => _filters = newFilters);
          _runSearch();
        },
      ),
    );
  }

  String _imgUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${AppConstants.baseUrl.replaceAll('/api', '')}$path';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HousingProvider>();
    final results = provider.searchResults;
    final activeFilters = _filters.hasActiveFilters;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                // ── Search field ───────────────────────────
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearchChanged,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _runSearch(),
                      decoration: InputDecoration(
                        hintText: 'City, university, keyword...',
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textLight),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close,
                                    color: AppColors.textLight, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _runSearch();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // ── Filter button ──────────────────────────
                GestureDetector(
                  onTap: _openFilters,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: activeFilters
                          ? AppColors.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(Icons.tune,
                              color: activeFilters
                                  ? Colors.white
                                  : AppColors.textMedium),
                        ),
                        if (activeFilters)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Active filter chips ────────────────────────────
          if (activeFilters)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (_filters.city != null)
                    _activeChip(_filters.city!, () => setState(() {
                          _filters = _filters.copyWith(clearCity: true);
                          _runSearch();
                        })),
                  if (_filters.type != null)
                    _activeChip(
                        _filters.type![0].toUpperCase() +
                            _filters.type!.substring(1),
                        () => setState(() {
                              _filters =
                                  _filters.copyWith(clearType: true);
                              _runSearch();
                            })),
                  if (_filters.minRooms != null)
                    _activeChip(
                        '${_filters.minRooms}+ rooms',
                        () => setState(() {
                              _filters =
                                  _filters.copyWith(clearRooms: true);
                              _runSearch();
                            })),
                  if (_filters.minPrice > 0 || _filters.maxPrice < 2000)
                    _activeChip(
                        '${_filters.minPrice.toInt()}–${_filters.maxPrice.toInt()} TND',
                        () => setState(() {
                              _filters = _filters.copyWith(
                                  minPrice: 0, maxPrice: 2000);
                              _runSearch();
                            })),
                  if (_filters.furnished != null)
                    _activeChip(
                        _filters.furnished! ? 'Furnished' : 'Unfurnished',
                        () => setState(() {
                              _filters =
                                  _filters.copyWith(clearFurnished: true);
                              _runSearch();
                            })),
                ],
              ),
            ),

          // ── Results count ──────────────────────────────────
          if (_hasSearched)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: provider.isSearching
                  ? const SizedBox.shrink()
                  : Text(
                      '${results.length} result${results.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: AppColors.textLight, fontSize: 13),
                    ),
            ),

          // ── Results body ───────────────────────────────────
          Expanded(child: _buildBody(provider, results)),
        ],
      ),
    );
  }

  Widget _buildBody(HousingProvider provider, List<HousingModel> results) {
    if (provider.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return _emptyState(
        icon: Icons.search,
        title: 'Search for a listing',
        subtitle: 'Type a keyword, city, or university name',
      );
    }

    if (results.isEmpty) {
      return _emptyState(
        icon: Icons.home_outlined,
        title: 'No listings found',
        subtitle: 'Try different keywords or adjust your filters',
        showReset: _filters.hasActiveFilters,
        onReset: () {
          setState(() => _filters = FilterState.empty);
          _runSearch();
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: results.length,
      itemBuilder: (_, i) =>
          _SearchResultCard(housing: results[i], imgUrl: _imgUrl),
    );
  }

  Widget _activeChip(String label, VoidCallback onRemove) => Container(
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close,
                  size: 14, color: AppColors.primary),
            ),
          ],
        ),
      );

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showReset = false,
    VoidCallback? onReset,
  }) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: AppColors.divider),
              const SizedBox(height: 16),
              Text(title,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMedium)),
              const SizedBox(height: 8),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textLight)),
              if (showReset) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: onReset,
                  child: const Text('Reset filters'),
                ),
              ]
            ],
          ),
        ),
      );
}

// ── Search result card ────────────────────────────────────────
class _SearchResultCard extends StatelessWidget {
  final HousingModel housing;
  final String Function(String) imgUrl;

  const _SearchResultCard(
      {required this.housing, required this.imgUrl});

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
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16)),
              child: h.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imgUrl(h.images.first),
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                          width: 110,
                          height: 110,
                          color: AppColors.primaryLight),
                      errorWidget: (_, __, ___) => Container(
                        width: 110,
                        height: 110,
                        color: AppColors.primaryLight,
                        child: const Icon(Icons.home,
                            color: AppColors.primary, size: 36),
                      ),
                    )
                  : Container(
                      width: 110,
                      height: 110,
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.home,
                          color: AppColors.primary, size: 36),
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
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.textLight),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(h.city,
                            style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    if (h.university != null &&
                        h.university!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.school_outlined,
                            size: 13, color: AppColors.textLight),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(h.university!,
                              style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ],
                    const SizedBox(height: 8),
                    Row(children: [
                      Text('${h.price.toInt()} TND/mo',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      _miniTag(Icons.bed_outlined, '${h.rooms}'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                            h.type[0].toUpperCase() +
                                h.type.substring(1),
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniTag(IconData icon, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textLight),
          const SizedBox(width: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textLight, fontSize: 12)),
        ],
      );
}
