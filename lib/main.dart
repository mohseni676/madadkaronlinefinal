import 'package:flutter/material.dart';
import 'package:madadkaronline/pages/main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'مددکار آنلاین',
        theme: ThemeData(
          fontFamily: 'Yekan',
          primarySwatch: Colors.deepOrange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MainPage());
  }
}
