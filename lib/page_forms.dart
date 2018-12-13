
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

  final List<PageField> pages;
  final int startIndex;

  PageForms({
    this.pages,
    this.startIndex,
  }) : assert(startIndex < pages.length, 'Page start index out of range');

  @override
  PageFormsState createState() => PageFormsState(
    themeData: _kThemeData,
    progressIndicatorHeight: _kProgressIndicatorHeight,
    progressIndicatorColor: _kProgressIndicatorColor,
    pages: pages,
    startIndex: startIndex,
  );
}

class PageFormsState extends State<PageForms> with SingleTickerProviderStateMixin {

  final ThemeData themeData;
  final double progressIndicatorHeight;
  final Color progressIndicatorColor;
  final List<PageField> pages;
  final int startIndex;

  PageFormsState({
    @required this.themeData,
    @required this.progressIndicatorHeight,
    @required this.progressIndicatorColor,
    @required this.pages,
    @required this.startIndex,
  });

  @override
  Widget build(BuildContext cxt) {
    final MediaQueryData mediaQueryData = MediaQuery.of(cxt);
    final screenWidth = mediaQueryData.size.width;
    final screenHeight = mediaQueryData.size.height;
    final statusBarHeight = mediaQueryData.padding.top;
    return SizedBox.expand(
      child: Stack(
        children: <Widget>[
          _PageControllers(
            pageWidth: screenWidth,
            pageHeight: screenHeight,
            statusBarHeight: statusBarHeight,
            pages: pages,
            startIndex: startIndex,
          ),
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

class PageField {

  final Color color;
  final Widget child;

  PageField({
    @required this.color,
    @required this.child,
  });
}

class _PageControllers extends StatefulWidget {

  final double pageWidth;
  final double pageHeight;
  final List<PageField> pages;
  final double statusBarHeight;
  int currentIndex;

  _PageControllers({
    @required this.pageWidth,
    @required this.pageHeight,
    @required this.pages,
    @required this.statusBarHeight,
    int startIndex = 0,
  }) {
    currentIndex = startIndex;
  }

  @override
  _PageControllersState createState() => _PageControllersState(
    pageWidth: pageWidth,
    pageHeight: pageHeight,
    pages: pages,
    statusBarHeight: statusBarHeight,
    currentIndex: currentIndex,
  );
}

class _PageControllersState extends State<_PageControllers> with SingleTickerProviderStateMixin {

  final double pageWidth;
  final double pageHeight;
  final List<PageField> pages;
  final double statusBarHeight;
  final int currentIndex;

  _PageControllersState({
    @required this.pageWidth,
    @required this.pageHeight,
    @required this.pages,
    @required this.statusBarHeight,
    @required this.currentIndex,
  });

  @override
  Widget build(BuildContext cxt) {
    return Container(
      width: pageWidth * 2,
      height: pageHeight,
      child: CustomMultiChildLayout(
        delegate: _PagesLayoutDelegate(
          pageWidth: pageWidth,
          pageHeight: pageHeight,
          pageCount: pages.length,
          currentIndex: currentIndex,
        ),
        children: List.generate(pages.length, (int pageIndex) {
          return LayoutId(
            id: 'page$pageIndex',
            child: Container(
              color: pages[pageIndex].color,
              child: Padding(
                padding: EdgeInsets.only(
                  top: statusBarHeight,
                  left: 12.0,
                  right: 12.0,
                  bottom: 30.0,
                ),
                child: pages[pageIndex].child,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PagesLayoutDelegate extends MultiChildLayoutDelegate {

  final double pageWidth;
  final double pageHeight;
  final int pageCount;
  final int currentIndex;

  _PagesLayoutDelegate({
    @required this.pageWidth,
    @required this.pageHeight,
    @required this.pageCount,
    @required this.currentIndex,
  });

  @override
  void performLayout(Size size) {
    List.generate(this.pageCount, (int pageIndex) {
      final String currentPageId = 'page$pageIndex';
      layoutChild(currentPageId, BoxConstraints.tightFor(width: pageWidth, height: pageHeight));
      if (pageIndex > currentIndex) {
        positionChild(currentPageId, Offset(pageWidth, 0));
      } else {
        positionChild(currentPageId, Offset(0, 0));
      }
    });
  }

  @override shouldRelayout(_PagesLayoutDelegate oldDelegate) {
    return this.currentIndex != oldDelegate.currentIndex;
  }
}