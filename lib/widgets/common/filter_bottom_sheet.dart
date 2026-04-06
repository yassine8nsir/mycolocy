import 'package:flutter/material.dart';
import 'package:mon_projet/core/constants/app_colors.dart';

/// Holds all active filter values.
class FilterState {
  final String? city;
  final String? type;
  final double minPrice;
  final double maxPrice;
  final int? minRooms;
  final bool? furnished;

  const FilterState({
    this.city,
    this.type,
    this.minPrice = 0,
    this.maxPrice = 2000,
    this.minRooms,
    this.furnished,
  });

  bool get hasActiveFilters =>
      city != null ||
      type != null ||
      minPrice > 0 ||
      maxPrice < 2000 ||
      minRooms != null ||
      furnished != null;

  FilterState copyWith({
    String? city,
    bool clearCity = false,
    String? type,
    bool clearType = false,
    double? minPrice,
    double? maxPrice,
    int? minRooms,
    bool clearRooms = false,
    bool? furnished,
    bool clearFurnished = false,
  }) =>
      FilterState(
        city: clearCity ? null : city ?? this.city,
        type: clearType ? null : type ?? this.type,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        minRooms: clearRooms ? null : minRooms ?? this.minRooms,
        furnished: clearFurnished ? null : furnished ?? this.furnished,
      );

  static const FilterState empty = FilterState();
}

/// Shows a modal bottom sheet with all search filters.
/// Returns the new [FilterState] via [onApply].
class FilterBottomSheet extends StatefulWidget {
  final FilterState current;
  final List<String> cities;
  final void Function(FilterState) onApply;

  const FilterBottomSheet({
    super.key,
    required this.current,
    required this.cities,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  const Text('Filters',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        setState(() => _state = FilterState.empty),
                    child: const Text('Reset all',
                        style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable filter content
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  // ── City ──────────────────────────────────
                  _label('City'),
                  if (widget.cities.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.cities.map((c) {
                        final selected = _state.city == c;
                        return ChoiceChip(
                          label: Text(c),
                          selected: selected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textMedium),
                          onSelected: (v) => setState(() =>
                              _state = v
                                  ? _state.copyWith(city: c)
                                  : _state.copyWith(clearCity: true)),
                        );
                      }).toList(),
                    )
                  else
                    TextField(
                      decoration: const InputDecoration(
                          hintText: 'e.g. Tunis',
                          prefixIcon: Icon(Icons.location_on_outlined)),
                      onChanged: (v) => setState(() =>
                          _state = _state.copyWith(city: v.isEmpty ? null : v)),
                    ),
                  const SizedBox(height: 20),

                  // ── Price range ───────────────────────────
                  _label(
                      'Price range: ${_state.minPrice.toInt()} – ${_state.maxPrice.toInt()} TND/mo'),
                  RangeSlider(
                    min: 0,
                    max: 2000,
                    divisions: 40,
                    values: RangeValues(_state.minPrice, _state.maxPrice),
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _state =
                        _state.copyWith(minPrice: v.start, maxPrice: v.end)),
                  ),
                  const SizedBox(height: 12),

                  // ── Rooms ─────────────────────────────────
                  _label('Minimum rooms'),
                  Wrap(
                    spacing: 8,
                    children: [1, 2, 3, 4, 5].map((r) {
                      final selected = _state.minRooms == r;
                      return ChoiceChip(
                        label: Text('$r${r == 5 ? '+' : ''}'),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textMedium),
                        onSelected: (v) => setState(() => _state = v
                            ? _state.copyWith(minRooms: r)
                            : _state.copyWith(clearRooms: true)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // ── Type ──────────────────────────────────
                  _label('Property type'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'apartment',
                      'studio',
                      'house',
                      'room',
                    ].map((t) {
                      final selected = _state.type == t;
                      return ChoiceChip(
                        label: Text(
                            t[0].toUpperCase() + t.substring(1)),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textMedium),
                        onSelected: (v) => setState(() => _state = v
                            ? _state.copyWith(type: t)
                            : _state.copyWith(clearType: true)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // ── Furnished ─────────────────────────────
                  _label('Furnished'),
                  Row(children: [
                    _toggleBtn('Yes', _state.furnished == true,
                        () => setState(() => _state = _state.furnished == true
                            ? _state.copyWith(clearFurnished: true)
                            : _state.copyWith(furnished: true))),
                    const SizedBox(width: 10),
                    _toggleBtn('No', _state.furnished == false,
                        () => setState(() => _state = _state.furnished == false
                            ? _state.copyWith(clearFurnished: true)
                            : _state.copyWith(furnished: false))),
                  ]),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Apply button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: FilledButton(
                onPressed: () {
                  widget.onApply(_state);
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters'),
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
                color: AppColors.textDark,
                fontSize: 15)),
      );

  Widget _toggleBtn(String label, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w600)),
        ),
      );
}
