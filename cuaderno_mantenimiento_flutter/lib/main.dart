import 'package:cuaderno_mantenimiento_flutter/config/router/app_routes.dart';
import 'package:cuaderno_mantenimiento_flutter/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MainApp(),
    ),);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

    @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Car Splash & Animated Login',
      theme: ThemeData(
        colorSchemeSeed: Colors.red, // matches your app palette (rojo, gris, blanco)
        brightness: Brightness.light,
        useMaterial3: true,
      ),
     routerConfig: appRouter,
    );
  }
}
