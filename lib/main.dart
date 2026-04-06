import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet/core/constants/app_constants.dart';
import 'package:mon_projet/core/theme/app_theme.dart';
import 'package:mon_projet/providers/auth_provider.dart';
import 'package:mon_projet/providers/chat_provider.dart';
import 'package:mon_projet/providers/housing_provider.dart';
import 'package:mon_projet/providers/recommendation_provider.dart';
import 'package:mon_projet/providers/roommate_provider.dart';
import 'package:mon_projet/screens/splashscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HousingProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => RoommateProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const Splashscreen(),
      ),
    );
  }
}
