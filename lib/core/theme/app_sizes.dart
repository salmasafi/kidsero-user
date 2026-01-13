import 'package:flutter/material.dart';

class AppSizes {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;

  static double padding(BuildContext context) => width(context) * 0.06;
  static double spacing(BuildContext context) => height(context) * 0.02;
  
  static double buttonHeight(BuildContext context) => 64.0;
  static double inputHeight(BuildContext context) => 56.0;
  
  static double headingSize(BuildContext context) => width(context) * 0.07;
  static double subHeadingSize(BuildContext context) => width(context) * 0.04;
  static double bodySize(BuildContext context) => width(context) * 0.04;
  static double smallSize(BuildContext context) => width(context) * 0.035;
  
  static double radiusLarge = 24.0;
  static double radiusMedium = 16.0;
  static double radiusSmall = 8.0;
}
