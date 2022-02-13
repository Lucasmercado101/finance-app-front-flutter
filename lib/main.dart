import 'dart:async';

import 'package:finance_app_front_flutter/pages/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_app_front_flutter/providers/preferences.dart';
import 'package:finance_app_front_flutter/wallet.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();
  final Brightness brightness =
      SchedulerBinding.instance!.window.platformBrightness;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Wallet>(
          create: (context) => Wallet(),
        ),
        ChangeNotifierProvider<Preferences>(
          create: (context) => Preferences(
              prefs.getBool("darkMode") ?? (brightness == Brightness.dark)),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: context.watch<Preferences>().darkMode
            ? Brightness.dark
            : Brightness.light,
      ),
      home: const MyHomePage(),
    );
  }
}
