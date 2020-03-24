import 'package:salmonia_android/ui/all.dart';

class ErrorText extends StatelessWidget {
  const ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: errorTextStyle(context),
    );
  }
}
