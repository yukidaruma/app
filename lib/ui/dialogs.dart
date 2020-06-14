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
        RaisedButton(
          child: Text(S.of(context).ok),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

Future<bool> showConfirmationDialog({
  @required BuildContext context,
  @required String message,
  bool isDestructive = false,
  String destructiveMessage,
  String title,
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: title == null ? null : Text(title),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text(isDestructive ? S.of(context).goBack : S.of(context).cancel),
          onPressed: () => Navigator.pop<bool>(context, false),
        ),
        FlatButton(
          child: isDestructive
              ? Text(
                  destructiveMessage ?? S.of(context).yes,
                  style: const TextStyle(color: Colors.pink),
                )
              : Text(S.of(context).yes),
          onPressed: () => Navigator.pop<bool>(context, true),
        ),
      ],
    ),
  );
}
