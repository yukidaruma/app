import 'package:salmonia_android/ui/all.dart';

Future<void> showErrorMessageDialog({
  @required BuildContext context,
  @required String message,
}) {
  return showMessageDialog(context: context, message: message, title: S.of(context).errorDialogTitle);
}

Future<void> showMessageDialog({
  @required BuildContext context,
  @required String message,
  String title,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: title == null ? null : Text(title),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text(S.of(context).ok),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
