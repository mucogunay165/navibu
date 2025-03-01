// lib/widgets/navibu_logo.dart
import 'package:flutter/material.dart';

class NavibuLogo extends StatelessWidget {
  final double width;
  final double height;
  
  const NavibuLogo({
    Key? key, 
    this.width = 218, 
    this.height = 187,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/navibu_logo.png',
      width: width,
      height: height,
    );
  }
}