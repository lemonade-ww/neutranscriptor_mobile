import 'package:flutter/material.dart';
import 'upload.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: true,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top]);
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
        fontFamily: 'Raleway',
        brightness: Brightness.light,
        primaryColor: Color.fromRGBO(39, 86, 137, 1),
        scaffoldBackgroundColor: Color.fromRGBO(39, 86, 137, 1),
        textTheme: TextTheme(
          labelLarge: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Raleway',
        brightness: Brightness.dark,
        primaryColor: Color.fromRGBO(25, 28, 30, 1),
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          labelLarge: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: Upload(),
    );
  }
}
