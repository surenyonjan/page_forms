library page_forms;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const int _kStartIndex = 0;
const double _kProgressIndicatorHeight = 7.0;
const Color _kProgressIndicatorColor = Colors.white;
const Color _kProgressBackgroundColor = Colors.blueGrey;
const double _kFooterBarheight = 120.0;

enum PageFormStates { Initializing, InitializingError, Disabled, Enabled, Submiting, SubmitError, Submitted }

@immutable
class PageFormData<T> extends Diagnosticable {
  final int startIndex;
  final double progressIndicatorHeight;
  final Color progressIndicatorColor;
  final double footerBarHeight;
  final void Function(T) onSubmit;
  final VoidCallback onCancel;
  final Stream<PageFormStates> stateStream;
  final Stream<T> dataStream;

  PageFormData({
    this.startIndex = _kStartIndex,
    this.progressIndicatorHeight = _kProgressIndicatorHeight,
    this.progressIndicatorColor = _kProgressIndicatorColor,
    this.footerBarHeight = _kFooterBarheight,
    @required this.onSubmit,
    @required this.onCancel,
    @required this.stateStream,
    @required this.dataStream,
  }) : assert(startIndex != null),
       assert(footerBarHeight != null),
       assert(progressIndicatorHeight != null),
       assert(progressIndicatorColor != null),
       assert(onSubmit != null),
       assert(onCancel != null),
       assert(stateStream != null),
       assert(dataStream != null);
}

class _InheritedPageForm<T> extends InheritedWidget {

  _InheritedPageForm({
    Key key,
    @required this.data,
    @required Widget child,
    @required this.pageProgress,
  }): assert(data != null),
      super(key: key, child: child);

  final PageFormData<T> data;
  final AnimationController pageProgress;

  @override
  bool updateShouldNotify(_InheritedPageForm old) {
    return old.data.startIndex != this.data.startIndex
      || old.data.progressIndicatorColor != this.data.progressIndicatorColor
      || old.data.progressIndicatorHeight != this.data.progressIndicatorHeight
      || old.data.footerBarHeight != this.data.footerBarHeight;
  }
}

class PageForms<T> extends StatefulWidget {

  final List<PageField> pages;
  final PageFormData<T> data;

  PageForms({
    @required this.data,
    @required this.pages,
  }) : assert(pages != null),
       assert(data.startIndex < pages.length, 'Page start index out of range');

  static PageFormData of(BuildContext cxt) {
    final _InheritedPageForm inheritedPageForm = cxt.inheritFromWidgetOfExactType(_InheritedPageForm);
    return inheritedPageForm.data;
  }

  @override
  PageFormsState createState() => PageFormsState<T>();
}

class PageFormsState<T> extends State<PageForms> with SingleTickerProviderStateMixin {

  AnimationController _pageProgress;

  @override
  void initState() {
    super.initState();
    final startValue = widget.data.startIndex.toDouble();
    _pageProgress = AnimationController(
      value: startValue,
      lowerBound: 0.0,
      upperBound: (widget.pages.length - 1).toDouble(),
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
    return _InheritedPageForm(
      data: widget.data,
      pageProgress: _pageProgress,
      child: Scaffold(
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
                  pages: widget.pages,
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
                      height: widget.data.progressIndicatorHeight,
                    ),
                  ),
                ),
                // progress indicator
                Positioned(
                  top: statusBarHeight,
                  left: 0.0,
                  child: Container(
                    color: widget.data.progressIndicatorColor,
                    width: ((_pageProgress.value + 1) / widget.pages.length) * screenWidth,
                    height: widget.data.progressIndicatorHeight,
                  ),
                ),
              ],
            ),
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

  _PageControllers({
    @required this.pageWidth,
    @required this.pageHeight,
    @required this.pages,
    @required this.statusBarHeight,
  });

  @override
  _PageControllersState createState() => _PageControllersState<T>();
}

class _PageControllersState<T> extends State<_PageControllers> with SingleTickerProviderStateMixin {

  final double footerBarPadding = 10.0;

  _PageControllersState();

  Widget _buildNextButton(Widget nextButton, AsyncSnapshot nextBtnSnapshot, AnimationController pageProgressController, int nextIndex) {
    return nextBtnSnapshot.hasData && !nextBtnSnapshot.hasError
      ? GestureDetector(
          onTapUp: (_) => pageProgressController.animateTo(nextIndex.toDouble()),
          child: nextButton,
        )
      : Opacity(
          opacity: 0.5,
          child: nextButton,
        );
  }

  Widget _buildSubmitButton(Widget nextButton, PageFormData<T> formData) {
    return StreamBuilder<T>(
      stream: formData.dataStream,
      builder: (BuildContext dataContext, AsyncSnapshot<T> dataSnapshot) {
        return StreamBuilder<PageFormStates>(
          stream: formData.stateStream,
          builder: (BuildContext stateCxt, AsyncSnapshot<PageFormStates> stateSnapshot) {
            return stateSnapshot.hasData && !stateSnapshot.hasError
              ? GestureDetector(
                  onTapUp: (_) => formData.onSubmit(dataSnapshot.data),
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
    final _InheritedPageForm inheritedPageForm = cxt.inheritFromWidgetOfExactType(_InheritedPageForm);
    final PageFormData formData = inheritedPageForm.data;
    return Container(
      width: widget.pageWidth * 2,
      height: widget.pageHeight,
      child: CustomMultiChildLayout(
        delegate: _PagesLayoutDelegate(
          pageWidth: widget.pageWidth,
          pageHeight: widget.pageHeight,
          pageCount: widget.pages.length,
          pageProgress: inheritedPageForm.pageProgress.value,
        ),
        children: List.generate(widget.pages.length, (int pageIndex) {
          final bool isStartingPage = pageIndex == 0;
          final bool isLastPage = pageIndex == widget.pages.length - 1;

          List<Widget> footerActions = [];
          final double footerActionButtonHeight = formData.footerBarHeight - (footerBarPadding * 7);

          footerActions.add(Padding(
            padding: EdgeInsets.symmetric(vertical: footerBarPadding, horizontal: footerBarPadding),
            child: GestureDetector(
              onTapUp: (_) => !isStartingPage ? inheritedPageForm.pageProgress.animateTo((pageIndex - 1).toDouble()) : formData.onCancel(),
              child: Container(
                width: 120.0,
                height: footerActionButtonHeight,
                child: Center(
                  child: Text(
                    !isStartingPage ? 'Back' : 'Cancel',
                    style: themeData.textTheme.button,
                  ),
                ),
              ),
            ),
          ));

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
                style: themeData.textTheme.button.copyWith(color: widget.pages[pageIndex].color),
              ),
            ),
          );

          footerActions.add(Padding(
            padding: EdgeInsets.symmetric(vertical: footerBarPadding, horizontal: footerBarPadding),
            child: isLastPage
              ? _buildSubmitButton(_nextButton, formData)
              : StreamBuilder(
                  stream: widget.pages[pageIndex].fieldStream,
                  builder: (BuildContext nextBtnContext, AsyncSnapshot nextBtnSnapshot) {
                    return _buildNextButton(_nextButton, nextBtnSnapshot, inheritedPageForm.pageProgress, pageIndex + 1);
                  }
                ),
          ));

          return LayoutId(
            id: 'page$pageIndex',
            child: Container(
              color: widget.pages[pageIndex].color,
              child: Column(
                children: <Widget>[
                  Container(
                    height: widget.pageHeight - 120.0,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: widget.statusBarHeight,
                        left: 12.0,
                        right: 12.0,
                        bottom: 30.0,
                      ),
                      child: widget.pages[pageIndex].child,
                    ),
                  ),
                  Container(
                    height: formData.footerBarHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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