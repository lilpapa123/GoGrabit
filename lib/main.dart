import 'package:flutter/material.dart';
import 'package:go_grabit/screens/auth/login_screen.dart';
import 'package:go_grabit/theme_provider.dart';
import 'package:go_grabit/providers/cart_provider.dart';
import 'package:go_grabit/providers/user_provider.dart';
import 'package:go_grabit/providers/currency_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'GoGrabit',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        fontFamily: 'Poppins', // Assuming a nicer font is available or default
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffF2762E),
          primary: const Color(0xffF2762E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[900],
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xffF2762E),
          primary: const Color(0xffF2762E),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
