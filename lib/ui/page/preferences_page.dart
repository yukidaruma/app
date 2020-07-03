import 'dart:async';

import 'package:flutter/material.dart';
import 'package:salmon_stats_app/api.dart';
import 'package:salmon_stats_app/config.dart';
import 'package:salmon_stats_app/exceptions.dart';
import 'package:salmon_stats_app/store/shared_prefs.dart';
import 'package:salmon_stats_app/ui/all.dart';

final AppSharedPrefs _sharedPrefs = AppSharedPrefs();

@mustCallSuper
@optionalTypeArgs
abstract class PreferenceItem<T> {
  const PreferenceItem({
    this.key,
    this.labelBuilder,
    this.readOnly,
    this.type,
  });

  final SharedPrefsKeys key;
  final LabelBuilder labelBuilder;
  final bool Function() readOnly;
  final SharedPrefsTypes type;

  // ignore: missing_return
  T restore() {
    switch (type) {
      case SharedPrefsTypes.bool:
        return _sharedPrefs.getBool(key) as T;
      case SharedPrefsTypes.double:
        return _sharedPrefs.getDouble(key) as T;
      case SharedPrefsTypes.int:
        return _sharedPrefs.getInt(key) as T;
      case SharedPrefsTypes.string:
        return _sharedPrefs.getString(key) as T;
    }
  }

  // ignore: missing_return
  Future<void> save(T value) {
    switch (type) {
      case SharedPrefsTypes.bool:
        return _sharedPrefs.setBool(key, value as bool);
      case SharedPrefsTypes.double:
        return _sharedPrefs.setDouble(key, value as double);
      case SharedPrefsTypes.int:
        return _sharedPrefs.setInt(key, value as int);
      case SharedPrefsTypes.string:
        return _sharedPrefs.setString(key, value as String);
    }
  }
}

class BoolPreferenceItem extends PreferenceItem<bool> {
  const BoolPreferenceItem({
    bool Function() readOnly,
    @required SharedPrefsKeys key,
    @required LabelBuilder labelBuilder,
  }) : super(
          readOnly: readOnly,
          key: key,
          labelBuilder: labelBuilder,
          type: SharedPrefsTypes.bool,
        );
}

class DoublePreferenceItem extends PreferenceItem<double> {
  const DoublePreferenceItem({
    bool Function() readOnly,
    @required SharedPrefsKeys key,
    @required LabelBuilder labelBuilder,
  }) : super(
          readOnly: readOnly,
          key: key,
          labelBuilder: labelBuilder,
          type: SharedPrefsTypes.double,
        );
}

class IntPreferenceItem extends PreferenceItem<int> {
  const IntPreferenceItem({
    bool Function() readOnly,
    @required SharedPrefsKeys key,
    @required LabelBuilder labelBuilder,
  }) : super(
          readOnly: readOnly,
          key: key,
          labelBuilder: labelBuilder,
          type: SharedPrefsTypes.int,
        );
}

class StringPreferenceItem extends PreferenceItem<String> {
  const StringPreferenceItem({
    bool Function() readOnly,
    @required SharedPrefsKeys key,
    @required LabelBuilder labelBuilder,
  }) : super(
          readOnly: readOnly,
          key: key,
          labelBuilder: labelBuilder,
          type: SharedPrefsTypes.string,
        );
}

class WidgetPreferenceItem extends PreferenceItem<void> {
  WidgetPreferenceItem({@required this.builder, this.visibility});

  final WidgetBuilder builder;
  final bool Function() visibility;

  @override
  void restore() {
    throw InvalidOperationException('restore');
  }

  @override
  Future<void> save(void value) {
    throw InvalidOperationException('save');
  }
}

class PreferencesPage extends StatefulWidget implements PushablePage<PreferencesPage> {
  const PreferencesPage();

  @override
  _PreferencesPageState createState() => _PreferencesPageState();

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const PreferencesPage()),
    );
  }
}

class _PreferencesPageState extends State<PreferencesPage> {
  final Map<SharedPrefsKeys, ValueNotifier<dynamic>> _controllers = <SharedPrefsKeys, ValueNotifier<dynamic>>{};
  List<PreferenceItem> _options;
  bool _enterApiTokenManually = false;

  @override
  void initState() {
    super.initState();

    _options = <PreferenceItem>[
      StringPreferenceItem(
        readOnly: () => !_enterApiTokenManually,
        key: SharedPrefsKeys.SALMON_STATS_TOKEN,
        labelBuilder: (BuildContext context) => S.of(context).salmonStatsApiToken,
      ),
      WidgetPreferenceItem(
        visibility: () => !_enterApiTokenManually,
        builder: (BuildContext context) => Center(
          child: RaisedButton(
            child: Text((salmonStatsAPIToken?.isEmpty ?? true) ? S.of(context).getApiToken : S.of(context).updateApiToken),
            onPressed: () => _getSalmonStatsAPIToken(context),
          ),
        ),
      ),
      WidgetPreferenceItem(
        visibility: () => !_enterApiTokenManually,
        builder: (_) => Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(bottom: 16.0)),
            FlatButton(
              child: Text(S.of(context).enterApiTokenManually),
              onPressed: () => setState(() => _enterApiTokenManually = true),
            ),
          ],
        ),
      ),
    ];

    for (final PreferenceItem option in _options) {
      ValueNotifier<dynamic> controller;

      switch (option.type) {
        case SharedPrefsTypes.bool:
          controller = ValueNotifier<bool>(option.restore() as bool ?? false);
          controller.addListener(() => option.save(controller.value));
          break;

        case SharedPrefsTypes.double:
        case SharedPrefsTypes.int:
          controller = TextEditingController(text: (option.restore() ?? 0).toString());
          controller.addListener(() {
            final String text = (controller as TextEditingController).text;
            final dynamic parsedValue = option.type == SharedPrefsTypes.int ? int.tryParse(text) : double.tryParse(text);
            return option.save(parsedValue);
          });
          break;

        case SharedPrefsTypes.string:
          controller = TextEditingController(text: option.restore() as String ?? '');
          controller.addListener(() => option.save((controller as TextEditingController).text));
          break;
      }

      if (controller != null) {
        _controllers[option.key] = controller;
      }
    }
  }

  @override
  void dispose() {
    for (final ValueNotifier<dynamic> controller in _controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = ListView.builder(
      itemBuilder: (BuildContext context, int i) {
        final PreferenceItem item = _options[i];

        if (item is WidgetPreferenceItem && !item.visibility()) {
          return Container();
        }

        return _buildPrefItem(context, _options[i]);
      },
      itemCount: _options.length,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings),
      ),
      body: PagePadding(child: body),
    );
  }

  Widget _buildPrefItem(BuildContext context, PreferenceItem option) {
    // ignore: missing_return
    final Widget control = (() {
      final bool readOnly = option.readOnly != null && option.readOnly();
      final ValueNotifier<dynamic> listenable = _controllers[option.key];
      switch (option.type) {
        case SharedPrefsTypes.bool:
          return ValueListenableBuilder<bool>(
            valueListenable: listenable as ValueNotifier<bool>,
            builder: (_, bool value, __) => Row(
              children: <Widget>[
                Switch(
                  onChanged: readOnly ? null : (bool newValue) => listenable.value = newValue,
                  value: value,
                ),
              ],
            ),
          );

        case SharedPrefsTypes.string:
          return TextField(
            controller: listenable as TextEditingController,
            readOnly: readOnly,
          );

        case SharedPrefsTypes.double:
        case SharedPrefsTypes.int:
          return TextField(
            controller: listenable as TextEditingController,
            readOnly: readOnly,
            keyboardType: option.type == SharedPrefsTypes.int ? const TextInputType.numberWithOptions(decimal: false) : TextInputType.number,
          );
      }
    })();

    if (option is WidgetPreferenceItem) {
      return option.builder(context);
    }

    return Row(
      children: <Widget>[
        SizedBox(
          child: Text(option.labelBuilder(context)),
          width: 160,
        ),
        Expanded(child: control),
      ],
    );
  }

  Future<void> _getSalmonStatsAPIToken(BuildContext context) async {
    final String token = await Navigator.push(
      context,
      MaterialPageRoute<String>(
        builder: (_) => _GetAPITokenPage(),
      ),
    );

    final ValueNotifier<TextEditingValue> controller = _controllers.entries
        .whereType<MapEntry<SharedPrefsKeys, ValueNotifier<TextEditingValue>>>()
        .firstWhere(
          (MapEntry<SharedPrefsKeys, ValueNotifier<dynamic>> controller) => controller.key == SharedPrefsKeys.SALMON_STATS_TOKEN,
        )
        .value;
    controller.value = TextEditingValue(text: token);
  }
}

class _GetAPITokenPage extends StatefulWidget {
  @override
  _GetAPITokenPageState createState() => _GetAPITokenPageState();
}

class _GetAPITokenPageState extends State<_GetAPITokenPage> {
  WebViewController _controller;
  Timer _timer;

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final String initialUrl = '${Config.SALMON_STATS_API_ORIGIN}/app-request-api-token';
    final RegExp tokenUrlPattern = RegExp(r'#token=(.+)$');

    return Scaffold(
      appBar: AppBar(),
      body: WebView(
        initialUrl: initialUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController controller) {
          _controller = controller;

          // https://github.com/flutter/flutter/issues/27729
          // navigationDelegate doesn't work with History API, so we watch url periodically.
          _timer = Timer.periodic(
            const Duration(milliseconds: 100),
            (_) async {
              final String url = await _controller.currentUrl();
              final Match match = tokenUrlPattern.firstMatch(url);

              if (match != null) {
                final String token = match.group(1);

                _timer.cancel();
                Navigator.pop(context, token);
              }
            },
          );
        },
      ),
    );
  }
}
