import 'package:flttr/glitch.dart';
import 'package:flttr/pixel.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Package examples in Flutter web',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Examples(),
    );
  }
}

class Examples extends StatelessWidget {
  const Examples({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text("Examples"),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: const [
              SizedBox(height: 20,),
              Pixel(),
              SizedBox(height: 20,),
              Glitch(),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}
