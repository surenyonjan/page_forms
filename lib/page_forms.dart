library page_forms;

import 'package:flutter/material.dart';

const double _kProgressIndicatorHeight = 7.0;
final Color _kProgressIndicatorColor = Colors.white;
final Color _kProgressBackgroundColor = Colors.blueGrey;
const double _kFooterBarheight = 120.0;

enum PageFormStates { Initializing, InitializingError, Disabled, Enabled, Submiting, SubmitError, Submitted }

class PageForms<T> extends StatefulWidget {

  final List<PageField> pages;
  final int startIndex;
  final double progressIndicatorHeight;
  final double footerBarHeight;
  final void Function(T) onSubmit;
  final Stream<PageFormStates> stateStream;
  final Stream<T> dataStream;

  PageForms({
    this.pages,
    this.startIndex,
    this.footerBarHeight = _kFooterBarheight,
    this.progressIndicatorHeight = _kProgressIndicatorHeight,
    @required this.onSubmit,
    @required this.stateStream,
    @required this.dataStream,
  }) : assert(startIndex < pages.length, 'Page start index out of range');

  @override
  PageFormsState createState() => PageFormsState<T>(
    progressIndicatorHeight: _kProgressIndicatorHeight,
    progressIndicatorColor: _kProgressIndicatorColor,
    footerBarHeight: _kFooterBarheight,
    pages: pages,
    startIndex: startIndex,
    onSubmit: onSubmit,
    dataStream: dataStream,
    stateStream: stateStream,
  );
}

class PageFormsState<T> extends State<PageForms> with SingleTickerProviderStateMixin {

  final double progressIndicatorHeight;
  final Color progressIndicatorColor;
  final double footerBarHeight;
  final List<PageField> pages;
  final int startIndex;
  final void Function(T) onSubmit;
  final Stream<PageFormStates> stateStream;
  final Stream<T> dataStream;

  AnimationController _pageProgress;
  PageFormsState({
    @required this.progressIndicatorHeight,
    @required this.progressIndicatorColor,
    @required this.footerBarHeight,
    @required this.pages,
    @required this.startIndex,
    @required this.onSubmit,
    @required this.stateStream,
    @required this.dataStream,
  });

  @override
  void initState() {
    super.initState();
    _pageProgress = AnimationController(
      value: startIndex.toDouble(),
      lowerBound: 0.0,
      upperBound: (pages.length - 1).toDouble(),
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _pageProgress.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext cxt) {
    final ThemeData themeData = Theme.of(cxt);
    final MediaQueryData mediaQueryData = MediaQuery.of(cxt);
    final screenWidth = mediaQueryData.size.width;
    final screenHeight = mediaQueryData.size.height;
    final statusBarHeight = mediaQueryData.padding.top;
    return Scaffold(
      body: Theme(
        data: themeData.copyWith(
          cursorColor: Colors.white,
          dividerColor: Colors.white,
          textSelectionColor: Colors.white,
          textTheme: themeData.textTheme.copyWith(
            subhead: TextStyle(color: Colors.white, fontSize: 20.0),
            button: TextStyle(
              color: Colors.white,
              fontSize: 23.0,
              fontWeight: FontWeight.normal,
              wordSpacing: 1.5,
              decoration: TextDecoration.none,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.white),
            helperStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.grey),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        child: SizedBox.fromSize(
          size: Size(screenWidth, screenHeight),
          child: Stack(
            children: <Widget>[
              _PageControllers<T>(
                pageWidth: screenWidth,
                pageHeight: screenHeight,
                statusBarHeight: statusBarHeight,
                footerBarHeight: footerBarHeight,
                pages: pages,
                pageProgress: _pageProgress,
                startIndex: startIndex,
                onSubmit: onSubmit,
                stateStream: stateStream,
                dataStream: dataStream,
              ),
              // progress indicator background
              Positioned(
                top: statusBarHeight,
                left: 0.0,
                child: Opacity(
                  opacity: 0.3,
                  child: Container(
                    color: _kProgressBackgroundColor,
                    width: screenWidth,
                    height: progressIndicatorHeight,
                  ),
                ),
              ),
              // progress indicator
              Positioned(
                top: statusBarHeight,
                left: 0.0,
                child: Container(
                  color: progressIndicatorColor,
                  width: ((_pageProgress.value + 1) / pages.length) * screenWidth,
                  height: progressIndicatorHeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PageField<T> {

  final Color color;
  final Widget child;
  final Stream<T> fieldStream;

  PageField({
    @required this.color,
    @required this.child,
    @required this.fieldStream,
  });
}

class _PageControllers<T> extends StatefulWidget {

  final double pageWidth;
  final double pageHeight;
  final List<PageField> pages;
  final double statusBarHeight;
  final double footerBarHeight;
  final void Function(T) onSubmit;
  final Stream<PageFormStates> stateStream;
  final Stream<T> dataStream;
  int currentIndex;
  AnimationController pageProgress;

  _PageControllers({
    @required this.pageWidth,
    @required this.pageHeight,
    @required this.pages,
    @required this.statusBarHeight,
    @required this.footerBarHeight,
    @required this.pageProgress,
    @required this.onSubmit,
    @required this.stateStream,
    @required this.dataStream,
    int startIndex = 0,
  }) {
    currentIndex = startIndex;
  }

  @override
  _PageControllersState createState() => _PageControllersState<T>(
    pageWidth: pageWidth,
    pageHeight: pageHeight,
    pages: pages,
    statusBarHeight: statusBarHeight,
    footerBarHeight: footerBarHeight,
    currentIndex: currentIndex,
    pageProgress: pageProgress,
    onSubmit: onSubmit,
    dataStream: dataStream,
    stateStream: stateStream,
  );
}

class _PageControllersState<T> extends State<_PageControllers> with SingleTickerProviderStateMixin {

  final double pageWidth;
  final double pageHeight;
  final List<PageField> pages;
  final double statusBarHeight;
  final double footerBarHeight;
  final int currentIndex;
  final void Function(T) onSubmit;
  final Stream<PageFormStates> stateStream;
  final Stream<T> dataStream;
  AnimationController pageProgress;

  final double footerBarPadding = 10.0;

  _PageControllersState({
    @required this.pageWidth,
    @required this.pageHeight,
    @required this.pages,
    @required this.statusBarHeight,
    @required this.footerBarHeight,
    @required this.currentIndex,
    @required this.pageProgress,
    @required this.onSubmit,
    @required this.stateStream,
    @required this.dataStream,
  }) : assert(footerBarHeight > 100.0);

  Widget buildNextButton(Widget nextButton, AsyncSnapshot nextBtnSnapshot, int nextIndex) {
    return nextBtnSnapshot.hasData && !nextBtnSnapshot.hasError
      ? GestureDetector(
          onTapUp: (_) => pageProgress.animateTo(nextIndex.toDouble()),
          child: nextButton,
        )
      : Opacity(
          opacity: 0.5,
          child: nextButton,
        );
  }

  Widget buildSubmitButton(Widget nextButton) {
    return StreamBuilder(
      stream: dataStream,
      builder: (BuildContext dataContext, AsyncSnapshot<T> dataSnapshot) {
        return StreamBuilder(
          stream: stateStream,
          builder: (BuildContext stateCxt, AsyncSnapshot<PageFormStates> stateSnapshot) {
            return stateSnapshot.hasData && !stateSnapshot.hasError
              ? GestureDetector(
                  onTapUp: (_) => onSubmit(dataSnapshot.data),
                  child: nextButton,
                )
              : Opacity(
                  opacity: 0.5,
                  child: nextButton,
                );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext cxt) {
    final ThemeData themeData = Theme.of(cxt);
    return Container(
      width: pageWidth * 2,
      height: pageHeight,
      child: CustomMultiChildLayout(
        delegate: _PagesLayoutDelegate(
          pageWidth: pageWidth,
          pageHeight: pageHeight,
          pageCount: pages.length,
          pageProgress: pageProgress.value,
        ),
        children: List.generate(pages.length, (int pageIndex) {
          final bool shouldShowBackButton = pageIndex > 0;
          final bool isLastPage = pageIndex == pages.length - 1;

          List<Widget> footerActions = [];
          final double footerActionButtonHeight = footerBarHeight - (footerBarPadding * 7);

          if (shouldShowBackButton) {
            footerActions.add(Padding(
              padding: EdgeInsets.symmetric(vertical: footerBarPadding, horizontal: footerBarPadding),
              child: GestureDetector(
                onTapUp: (_) => pageProgress.animateTo((pageIndex - 1).toDouble()),
                child: Container(
                  width: 120.0,
                  height: footerActionButtonHeight,
                  child: Center(
                    child: Text(
                      'Back',
                      style: themeData.textTheme.button,
                    ),
                  ),
                ),
              ),
            ));
          }

          Widget _nextButton = Container(
            width: 120.0,
            height: footerActionButtonHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(6.0))
            ),
            child: Center(
              child: Text(
                isLastPage ? 'Submit' : 'Next',
                style: themeData.textTheme.button.copyWith(color: pages[pageIndex].color),
              ),
            ),
          );

          footerActions.add(Padding(
            padding: EdgeInsets.symmetric(vertical: footerBarPadding, horizontal: footerBarPadding),
            child: isLastPage
              ? buildSubmitButton(_nextButton)
              : StreamBuilder(
                  stream: pages[pageIndex].fieldStream,
                  builder: (BuildContext nextBtnContext, AsyncSnapshot nextBtnSnapshot) {
                    return buildNextButton(_nextButton, nextBtnSnapshot, pageIndex + 1);
                  }
                ),
          ));

          return LayoutId(
            id: 'page$pageIndex',
            child: Container(
              color: pages[pageIndex].color,
              child: Column(
                children: <Widget>[
                  Container(
                    height: pageHeight - 120.0,
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
                  Container(
                    height: footerBarHeight,
                    child: Row(
                      mainAxisAlignment: !shouldShowBackButton
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.spaceBetween,
                      children: footerActions,
                    ),
                  )
                ],
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
  final double pageProgress;

  _PagesLayoutDelegate({
    @required this.pageWidth,
    @required this.pageHeight,
    @required this.pageCount,
    @required this.pageProgress,
  });

  @override
  void performLayout(Size size) {
    final int transitioningTo = pageProgress.ceil();
    List.generate(this.pageCount, (int pageIndex) {
      final String currentPageId = 'page$pageIndex';
      layoutChild(currentPageId, BoxConstraints.tightFor(width: pageWidth, height: pageHeight));
      if (pageIndex > transitioningTo) {
        positionChild(currentPageId, Offset(pageWidth, 0));
      } else if(pageIndex == transitioningTo) {
        final double progressOffset = transitioningTo - pageProgress;
        positionChild(currentPageId, Offset(progressOffset * pageWidth, 0));
      } else {
        positionChild(currentPageId, Offset(0, 0));
      }
    });
  }

  @override shouldRelayout(_PagesLayoutDelegate oldDelegate) {
    return this.pageProgress.ceil() != oldDelegate.pageProgress;
  }
}