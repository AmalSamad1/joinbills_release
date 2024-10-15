import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

// This size work fine on my design, maybe you need some customization depends on your design

  // This isMobile, isTablet, isDesktop helep us later
  static bool isMobileDevice(BuildContext context) => MediaQuery.of(context).size.width < 750;

  static bool isTabletDevice(BuildContext context) => MediaQuery.of(context).size.width < 1200 && MediaQuery.of(context).size.width >= 750;

  static bool isDesktopDevice(BuildContext context) => MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      // If our width is more than 1100 then we consider it a desktop
        builder: (context,constrains){
          if(constrains.maxWidth<=767){
            return mobile;
          }
          else if(constrains.maxWidth <=1024){
            return tablet;
          }
          else{
            return desktop;
          }
        });
  }
}
