import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

mixin CanRun {
  int get speed;
  void running() {
    "Speed is $speed".log();
  }
}

class Cat with CanRun {
  @override
  int speed = 10;
}

void test() {
  final cat = Cat();
  cat.speed.log();
  cat.running();
  cat.speed = 20;
  cat.speed.log();
}

void main() {
  runApp(
    MaterialApp(
      title: "abstract in dart",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    test();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Abstract Methods",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
