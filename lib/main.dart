import 'package:flutter/material.dart';
import 'screens/home_shell.dart';

void main() => runApp(const DexApp());

class DexApp extends StatelessWidget {
  const DexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DexDisplay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const HomeShell(),
    );
  }
}
