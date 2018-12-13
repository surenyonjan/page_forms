
import 'package:flutter/material.dart';

final ThemeData _kThemeData = ThemeData(
  primarySwatch: Colors.blue,
  textTheme: TextTheme(
    button: TextStyle(
      color: Colors.white,
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      wordSpacing: 1.5,
      decoration: TextDecoration.none,
    ),
  ),
);
final double _kProgressIndicatorHeight = 10.0;
final Color _kProgressIndicatorColor = Colors.blue;

class PageForms extends StatefulWidget {

  @override
  PageFormsState createState() => PageFormsState(
    themeData: _kThemeData,
    progressIndicatorHeight: _kProgressIndicatorHeight,
    progressIndicatorColor: _kProgressIndicatorColor,
  );
}

class PageFormsState extends State<PageForms> with SingleTickerProviderStateMixin {

  final ThemeData themeData;
  final double progressIndicatorHeight;
  final Color progressIndicatorColor;

  PageFormsState({
    @required this.themeData,
    @required this.progressIndicatorHeight,
    @required this.progressIndicatorColor, 
  });

  @override
  Widget build(BuildContext cxt) {
    final MediaQueryData mediaQueryData = MediaQuery.of(cxt);
    final screenWidth = mediaQueryData.size.width;
    final statusBarHeight = mediaQueryData.padding.top;
    return SizedBox.expand(
      child: Stack(
        children: <Widget>[
          // progress indicator
          Positioned(
            top: statusBarHeight,
            left: 0.0,
            child: Container(
              color: progressIndicatorColor,
              width: screenWidth,
              height: progressIndicatorHeight,
            ),
          ),
        ],
      ),
    );
  }
}
