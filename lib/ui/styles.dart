import 'package:salmonia_android/ui/all.dart';

TextStyle boldTextStyle(BuildContext context) {
  final TextStyle style = Theme.of(context).textTheme.bodyText2;
  return style.copyWith(
    fontWeight: FontWeight.bold,
  );
}

TextStyle errorTextStyle(BuildContext context) {
  return TextStyle(
    color: Theme.of(context).errorColor,
  );
}

TextStyle weakTextStyle(BuildContext context) {
  final TextStyle style = Theme.of(context).textTheme.bodyText2;
  return style.copyWith(
    color: style.color.withAlpha(0xAA),
    fontSize: style.fontSize * 0.9,
  );
}
