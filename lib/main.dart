import 'package:flutter/material.dart';
import 'upload.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuTranscriptor',
      theme: ThemeData(
        colorScheme: ColorScheme.light().copyWith(
          primary: Color.fromRGBO(15, 95, 138, 1),
          secondary: Color.fromRGBO(15, 95, 138, 1),
        ),
        textTheme: const TextTheme(
          button: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark().copyWith(
          primary: Colors.black45,
        ),
        textTheme: const TextTheme(
          button: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      themeMode: ThemeMode.light,
      home: Upload(),
    );
  }
}
