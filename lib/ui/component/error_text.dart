import 'package:flutter/material.dart';
import 'package:salmonia_android/ui/styles.dart';

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
