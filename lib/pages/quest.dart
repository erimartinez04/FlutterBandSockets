import 'package:flutter/material.dart';

class namePage extends StatefulWidget {
  @override
  State<namePage> createState() => _namePageState();
}

class _namePageState extends State<namePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Hola Mundo'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
