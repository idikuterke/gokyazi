import 'package:flutter/material.dart';

// Eğer 'Immersive' diye bir sınıf kullanacaksanız, onu tanımlayın veya ilgili paketi ekleyin.
// Örneğin, immersive özelliği için bir paket kullanıyorsanız:
// import 'package:immersive_mode/immersive_mode.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

// ...devamında HomePage widget'ınızı tanımlayın...
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: const Center(child: Text('Hoş geldiniz!')),
    );
  }
}
