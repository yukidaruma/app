import 'package:salmonia_android/ui/all.dart';

typedef LabelBuilder = String Function(BuildContext context);

// https://github.com/dart-lang/language/issues/356
// For the time being, this is just a marker interface.
abstract class PushablePage<T extends Widget> {
//  static Future<void> push(BuildContext context) {
//    throw UnimplementedError();
//  }
}
