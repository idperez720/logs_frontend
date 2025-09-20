import 'package:flutter/material.dart';

void main() {
  runApp(const LogsApp());
}

class LogsApp extends StatelessWidget {
  const LogsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logs App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Welcome to Logs App!'),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
