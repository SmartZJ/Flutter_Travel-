import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'navigator/tab_navigator.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TabNavigator(),
  ));
}


