import 'package:flutter/material.dart';

/// Messages tab showing user conversations (placeholder for now).
class Messagescreen extends StatefulWidget {
  const Messagescreen({super.key});

  @override
  State<Messagescreen> createState() => _MessagescreenState();
}

class _MessagescreenState extends State<Messagescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      // Replace this with a list of conversations when messaging is implemented.
      body: const Center(
        child: Text(
          'No messages yet',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

