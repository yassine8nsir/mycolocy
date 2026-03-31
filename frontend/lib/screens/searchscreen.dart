import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final Set<String> _favorites = <String>{};

  // Static in‑memory list of mocked properties used only to drive the UI.
  // In a real app this would come from an API or database.
  late final List<_Property> _all = <_Property>[
    const _Property(
      id: 'silver-house',
      status: 'FOR RENT',
      title: 'Silver House',
      address: '4211 W 29th New York, NYC',
      pricePerMonth: 5200,
      beds: 3,
      baths: 4,
      areaSqft: 1500,
      imageUrl:
          'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=800&q=60',
    ),
    const _Property(
      id: 'luxury-house',
      status: 'FOR RENT',
      title: 'Luxury House',
      address: '235 12TH New York, NYC',
      pricePerMonth: 4700,
      beds: 2,
      baths: 4,
      areaSqft: 1300,
      imageUrl:
          'https://images.unsplash.com/photo-1501183638710-841dd1904471?auto=format&fit=crop&w=800&q=60',
    ),
    const _Property(
      id: 'blue-star-house',
      status: 'FOR RENT',
      title: 'Blue Star House',
      address: '8562 W 34th New York, NYC',
      pricePerMonth: 4200,
      beds: 2,
      baths: 4,
      areaSqft: 1130,
      imageUrl:
          'https://images.unsplash.com/photo-1502672023488-70e25813eb80?auto=format&fit=crop&w=800&q=60',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Simple client‑side search: filter by title or address with case‑insensitive match.
    final String q = _controller.text.trim().toLowerCase();
    final List<_Property> results = q.isEmpty
        ? _all
        : _all
            .where((p) =>
                p.title.toLowerCase().contains(q) ||
                p.address.toLowerCase().contains(q))
            .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            // Search bar (location text field + filter icon button).
            _SearchBar(
              controller: _controller,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            const _PromoCard(),
            const SizedBox(height: 16),
            for (final _Property p in results) ...[
              _PropertyCard(
                property: p,
                isFavorite: _favorites.contains(p.id),
                onToggleFavorite: () {
                  setState(() {
                    if (_favorites.contains(p.id)) {
                      _favorites.remove(p.id);
                    } else {
                      _favorites.add(p.id);
                    }
                  });
                },
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // Row with expandable search text field and a square filter icon button.
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'New York, NYC',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune),
            tooltip: 'Filters',
          ),
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    // Highlight banner promoting the search feature.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2A06B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.home_outlined, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find your dream home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Browse curated listings and save your favorites.',
                  style: TextStyle(color: Colors.white70, height: 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({
    required this.property,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final _Property property;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    // Each card shows one property with image, status chip, title, address,
    // price per month, and a few compact specs (beds, baths, area).
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 98,
                  height: 98,
                  child: Image.network(
                    property.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => Container(
                      color: const Color(0xFFE9ECF5),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: const Color(0xFFE9ECF5),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F8),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            property.status,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8A90A6),
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onToggleFavorite,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite
                                  ? const Color(0xFFE85B5B)
                                  : const Color(0xFFB4B8C5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      property.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E2235),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.address,
                      style: const TextStyle(
                        color: Color(0xFF8A90A6),
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${property.pricePerMonth}',
                          style: const TextStyle(
                            color: Color(0xFFF08A4B),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Text(
                            '/month',
                            style: TextStyle(color: Color(0xFF8A90A6)),
                          ),
                        ),
                        const Spacer(),
                        _MiniSpec(
                          icon: Icons.bed_outlined,
                          text: '${property.beds}',
                        ),
                        const SizedBox(width: 10),
                        _MiniSpec(
                          icon: Icons.bathtub_outlined,
                          text: '${property.baths}',
                        ),
                        const SizedBox(width: 10),
                        _MiniSpec(
                          icon: Icons.square_foot_outlined,
                          text: '${property.areaSqft} sqft',
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

class _MiniSpec extends StatelessWidget {
  const _MiniSpec({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFB4B8C5)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF8A90A6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Property {
  const _Property({
    required this.id,
    required this.status,
    required this.title,
    required this.address,
    required this.pricePerMonth,
    required this.beds,
    required this.baths,
    required this.areaSqft,
    required this.imageUrl,
  });

  final String id;
  final String status;
  final String title;
  final String address;
  final int pricePerMonth;
  final int beds;
  final int baths;
  final int areaSqft;
  final String imageUrl;
}

