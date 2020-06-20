// This code is based on https://stackoverflow.com/questions/56326005/how-to-use-expanded-in-singlechildscrollview/56327933#56327933.
// Added AlwaysScrollableScrollPhysics so it can work with RefreshIndicator.

import 'package:flutter/widgets.dart';

class ScrollColumnExpandable extends StatelessWidget {
  const ScrollColumnExpandable({
    Key key,
    this.children,
    CrossAxisAlignment crossAxisAlignment,
    MainAxisAlignment mainAxisAlignment,
    VerticalDirection verticalDirection,
    EdgeInsetsGeometry padding,
    this.textDirection,
    this.textBaseline,
  })  : crossAxisAlignment = crossAxisAlignment ?? CrossAxisAlignment.center,
        mainAxisAlignment = mainAxisAlignment ?? MainAxisAlignment.start,
        verticalDirection = verticalDirection ?? VerticalDirection.down,
        padding = padding ?? EdgeInsets.zero,
        super(key: key);

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final VerticalDirection verticalDirection;
  final TextDirection textDirection;
  final TextBaseline textBaseline;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[const SizedBox(width: double.infinity)];

    if (this.children != null) {
      children.addAll(this.children);
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraint) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraint.maxHeight - padding.vertical,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: crossAxisAlignment,
                  mainAxisAlignment: mainAxisAlignment,
                  mainAxisSize: MainAxisSize.max,
                  verticalDirection: verticalDirection,
                  children: children,
                  textBaseline: textBaseline,
                  textDirection: textDirection,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
