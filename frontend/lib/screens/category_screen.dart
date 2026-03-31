import 'package:flutter/material.dart';

/// Screen shown when a category is tapped on the Home page.
/// Each category (Roommate, Publish, University, Favorites) has its own screen.
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _getDescription(title),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDescription(String title) {
    switch (title) {
      case 'Roommate':
        return 'Find or post roommate offers near universities.';
      case 'Publish':
        return 'Publish your accommodation listing here.';
      case 'University':
        return 'Browse housing near universities in Tunisia.';
      case 'Favorites':
        return 'Your saved listings will appear here.';
      default:
        return 'Content for $title';
    }
  }
}
