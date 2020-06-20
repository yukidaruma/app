import 'package:salmonia_android/ui/all.dart';

class SalmoniaColors {
  static const Color successColor = Color(0xffadff2f);
  static const Color failColor = Color(0xffffa500);
}

const TextStyle failTextStyle = TextStyle(color: SalmoniaColors.failColor);
const TextStyle successTextStyle = TextStyle(color: SalmoniaColors.successColor);

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
