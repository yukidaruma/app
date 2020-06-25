import 'package:salmonia_android/ui/all.dart';

typedef _AsyncBuilder<T> = Widget Function(BuildContext context, T response);
typedef ErrorMessageBuilder = Widget Function(BuildContext context, Object error);

class FutureBuilderWrapper<T> extends StatelessWidget {
  const FutureBuilderWrapper({
    @required this.builder,
    this.errorBuilder,
    @required this.future,
    this.initialData,
  });

  final _AsyncBuilder<T> builder;
  final ErrorMessageBuilder errorBuilder;
  final Future<T> future;
  final T initialData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      initialData: initialData,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: (errorBuilder ?? _defaultErrorBuilder)(context, snapshot.error),
          );
        } else if (snapshot.hasData) {
          return builder(context, snapshot.data);
        }

        return const Center(child: CircularProgressIndicator());
      },
      future: future,
    );
  }

  Widget _defaultErrorBuilder(BuildContext context, Object error) {
    return ErrorText(error.toString());
  }
}
