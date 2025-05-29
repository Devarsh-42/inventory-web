import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visionapp/view/auth/login_screen.dart';
import 'package:visionapp/view/auth/splash_screen.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://fnpphxriqanxvwfxzdmv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZucHBoeHJpcWFueHZ3Znh6ZG12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYyODIwNTYsImV4cCI6MjA2MTg1ODA1Nn0.Gg5jJKeVJaKmCWl_4BtrpFqFa6oB9CUwlIwSMZkjzn4',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const SplashScreen(),
    );
  }
}