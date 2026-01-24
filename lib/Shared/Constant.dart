import 'package:flutter/material.dart';

class Constant {
  static late double screenWidth;
  static late double screenHeight;

  // UI Variables
  static void initializeScreenSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
  }

  static var scaffoldColor = Color(0xff212121);

  static final String mediaURL = baseAppURL.substring(
    0,
    Constant.baseAppURL.length - 5,
  );

  // Backend URL
  static final String baseAppURL = 'http://localhost:8081/api/';

  // Validation Regex
  static final String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$';

  static final String passwordRegex =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$&*])\S{8,}$';
}
