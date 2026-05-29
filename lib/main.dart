import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/padi_provider.dart';
import 'providers/theme_provider.dart'; // ← BARU
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PadiProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // ← BARU
      ],
      child: const PadiTrackApp(),
    ),
  );
}

class PadiTrackApp extends StatelessWidget {
  const PadiTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Watch ThemeProvider untuk update tema real-time
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'PadiTrack',
      debugShowCheckedModeBanner: false,
      // ✅ Gunakan theme sesuai mode
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
