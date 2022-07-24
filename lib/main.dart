import 'package:flutter/material.dart';
import 'upload.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) => runApp(MyApp()));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuTranscriptor',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color.fromRGBO(39, 86, 137, 1),
        scaffoldBackgroundColor: Color.fromRGBO(39, 86, 137, 1),
        colorScheme: ColorScheme.light().copyWith(
          primary: Color.fromRGBO(39, 86, 137, 1),
        ),
        textTheme: TextTheme(
          button: TextStyle(
            fontSize: 17,
            color: Colors.white,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark().copyWith(
          primary: Colors.black,
        ),
        textTheme: const TextTheme(
          button: TextStyle(
            fontSize: 17,
            color: Colors.white,
          ),
        ),
      ),
      themeMode: ThemeMode.light,
      home: Upload(),
    );
  }
}
