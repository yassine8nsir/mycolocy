import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet/core/constants/app_colors.dart';
import 'package:mon_projet/providers/housing_provider.dart';

class CreateHousingScreen extends StatefulWidget {
  const CreateHousingScreen({super.key});

  @override
  State<CreateHousingScreen> createState() => _CreateHousingScreenState();
}

class _CreateHousingScreenState extends State<CreateHousingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _universityCtrl = TextEditingController();
  final _roomsCtrl = TextEditingController(text: '2');
  final _bathroomsCtrl = TextEditingController(text: '1');
  final _areaCtrl = TextEditingController();
  final _roommatesCtrl = TextEditingController(text: '1');

  String _type = 'apartment';
  bool _furnished = false;
  String _gender = 'any';

  // Amenities state
  bool _wifi = false;
  bool _parking = false;
  bool _ac = false;
  bool _heating = false;
  bool _washing = false;
  bool _elevator = false;

  final List<File> _images = [];
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _universityCtrl.dispose();
    _roomsCtrl.dispose();
    _bathroomsCtrl.dispose();
    _areaCtrl.dispose();
    _roommatesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 70);
    if (picked.isNotEmpty) {
      setState(() {
        _images.addAll(
          picked.take(6 - _images.length).map((x) => File(x.path)),
        );
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one photo')),
      );
      return;
    }

    final amenities = {
      'wifi': _wifi, 'parking': _parking, 'airConditioning': _ac,
      'heating': _heating, 'washingMachine': _washing, 'elevator': _elevator,
    };

    final fields = <String, String>{
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': _priceCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'university': _universityCtrl.text.trim(),
      'rooms': _roomsCtrl.text.trim(),
      'bathrooms': _bathroomsCtrl.text.trim(),
      'area': _areaCtrl.text.trim(),
      'type': _type,
      'furnished': '$_furnished',
      'amenities': jsonEncode(amenities),
      'roommatesNeeded': _roommatesCtrl.text.trim(),
      'genderPreference': _gender,
    };

    final ok = await context.read<HousingProvider>().create(
          fields: fields,
          images: _images,
        );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing published!')),
      );
    } else {
      final err = context.read<HousingProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(err ?? 'Failed to create listing'),
            backgroundColor: Colors.red.shade700),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<HousingProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('New Listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Images ──────────────────────────────────────
              _section('Photos'),
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._images.map(
                      (f) => Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                  image: FileImage(f), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 14,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _images.remove(f)),
                              child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.close,
                                      size: 12, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_images.length < 6)
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: AppColors.primary, size: 30),
                              SizedBox(height: 4),
                              Text('Add photo',
                                  style: TextStyle(
                                      color: AppColors.primary, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Basic info ───────────────────────────────────
              _section('Basic Information'),
              _field('Title', _titleCtrl, hint: 'e.g. Modern apartment near campus'),
              _field('Description', _descCtrl,
                  hint: 'Describe the place...', maxLines: 4),
              _field('Price (TND/month)', _priceCtrl,
                  hint: '350', type: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty || double.tryParse(v) == null
                      ? 'Enter a valid price'
                      : null),
              const SizedBox(height: 8),

              // Type dropdown
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
                  DropdownMenuItem(value: 'studio', child: Text('Studio')),
                  DropdownMenuItem(value: 'house', child: Text('House')),
                  DropdownMenuItem(value: 'room', child: Text('Room')),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 20),

              // ── Location ─────────────────────────────────────
              _section('Location'),
              _field('City', _cityCtrl, hint: 'e.g. Tunis'),
              _field('Address', _addressCtrl, hint: 'Street address (optional)'),
              _field('Nearest University', _universityCtrl,
                  hint: 'e.g. University of Tunis'),
              const SizedBox(height: 8),

              // ── Details ──────────────────────────────────────
              _section('Details'),
              Row(children: [
                Expanded(
                    child: _field('Rooms', _roomsCtrl,
                        type: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(
                    child: _field('Bathrooms', _bathroomsCtrl,
                        type: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(
                    child: _field('Area (m²)', _areaCtrl,
                        type: TextInputType.number, required: false)),
              ]),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _furnished,
                onChanged: (v) => setState(() => _furnished = v),
                title: const Text('Furnished'),
                contentPadding: EdgeInsets.zero,
              ),

              // ── Amenities ────────────────────────────────────
              _section('Amenities'),
              Wrap(
                spacing: 8,
                runSpacing: 0,
                children: [
                  _amenityChip('Wi-Fi', Icons.wifi, _wifi,
                      (v) => setState(() => _wifi = v)),
                  _amenityChip('Parking', Icons.local_parking, _parking,
                      (v) => setState(() => _parking = v)),
                  _amenityChip('A/C', Icons.ac_unit, _ac,
                      (v) => setState(() => _ac = v)),
                  _amenityChip('Heating', Icons.thermostat, _heating,
                      (v) => setState(() => _heating = v)),
                  _amenityChip('Washing', Icons.local_laundry_service, _washing,
                      (v) => setState(() => _washing = v)),
                  _amenityChip('Elevator', Icons.elevator, _elevator,
                      (v) => setState(() => _elevator = v)),
                ],
              ),

              // ── Roommate preferences ─────────────────────────
              _section('Roommate Info'),
              _field('Roommates needed', _roommatesCtrl,
                  type: TextInputType.number),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration:
                    const InputDecoration(labelText: 'Gender preference'),
                items: const [
                  DropdownMenuItem(value: 'any', child: Text('Any')),
                  DropdownMenuItem(value: 'male', child: Text('Male only')),
                  DropdownMenuItem(value: 'female', child: Text('Female only')),
                ],
                onChanged: (v) => setState(() => _gender = v!),
              ),
              const SizedBox(height: 32),

              // ── Submit ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Publish Listing'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 4),
        child: Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark)),
      );

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
    TextInputType type = TextInputType.text,
    bool required = true,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: type,
          validator: validator ??
              (required
                  ? (v) => v == null || v.trim().isEmpty ? '$label is required' : null
                  : null),
          decoration: InputDecoration(labelText: label, hintText: hint),
        ),
      );

  Widget _amenityChip(
    String label,
    IconData icon,
    bool value,
    ValueChanged<bool> onChange,
  ) =>
      FilterChip(
        label: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14,
              color: value ? Colors.white : AppColors.textMedium),
          const SizedBox(width: 4),
          Text(label),
        ]),
        selected: value,
        onSelected: onChange,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
            color: value ? Colors.white : AppColors.textMedium),
        showCheckmark: false,
      );
}
