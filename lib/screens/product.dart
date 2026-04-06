import 'package:flutter/material.dart';

/// Placeholder screen for a future products/offers section.
class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep the same neutral scaffold background as the rest of the app.
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: const Center(
        child: Text(
          'Products screen placeholder',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}