import 'package:flutter/material.dart';

/// Simple placeholder screen for choosing a location.
class Locationscreen extends StatefulWidget {
  const Locationscreen({super.key});

  @override
  _LocationscreenState createState() => _LocationscreenState();
}

class _LocationscreenState extends State<Locationscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose location'),
      ),
      // For now we just show a centered placeholder; can be replaced by a map
      // or list of cities later.
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.location_on_outlined,
              size: 64,
              color: Colors.deepOrange,
            ),
            SizedBox(height: 12),
            Text(
              'Location screen placeholder',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}