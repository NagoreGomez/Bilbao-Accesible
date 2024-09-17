import 'package:bilbao_accesible/view/origen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true
      ),
      home: Origen(),
    );
  }
}

// iconos: https://github.com/bigbadbob2003/flutter_tabler_icons
// codigo: https://blog.codemagic.io/creating-a-route-calculator-using-google-maps/