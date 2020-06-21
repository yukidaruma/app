import 'dart:async';

import 'package:flutter/material.dart';
import 'package:salmonia_android/api.dart';
import 'package:salmonia_android/config.dart';
import 'package:salmonia_android/exceptions.dart';
import 'package:salmonia_android/store/shared_prefs.dart';
import 'package:salmonia_android/ui/all.dart';
import 'package:webview_flutter/webview_flutter.dart';

final AppSharedPrefs _sharedPrefs = AppSharedPrefs();

@mustCallSuper
@optionalTypeArgs
abstract class PreferenceItem<T> {
  const PreferenceItem({
    bool readOnly,
    this.key,
    this.labelBuilder,
    this.type,
  }) : readOnly = readOnly ?? false;

  final bool readOnly;
  final SharedPrefsKeys key;
  final LabelBuilder labelBuilder;
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
    bool readOnly,
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
    bool readOnly,
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
    bool readOnly,
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
    bool readOnly,
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
  WidgetPreferenceItem({@required this.builder});

  final WidgetBuilder builder;

  @override
  void restore() {
    throw InvalidOperationException('restore');
  }

  @override
  Future<void> save(void value) {
    throw InvalidOperationException('save');
  }
}

class PreferencesPage extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();

    _options = <PreferenceItem>[
      StringPreferenceItem(
        readOnly: true,
        key: SharedPrefsKeys.SALMON_STATS_TOKEN,
        labelBuilder: (BuildContext context) => S.of(context).salmonStatsApiToken,
      ),
      WidgetPreferenceItem(
        builder: (BuildContext context) => Center(
          child: RaisedButton(
            child: Text((salmonStatsAPIToken?.isEmpty ?? true) ? S.of(context).getApiToken : S.of(context).updateApiToken),
            onPressed: () => _getSalmonStatsAPIToken(context),
          ),
        ),
      ),
    ];

    for (final PreferenceItem option in _options) {
      ValueNotifier<dynamic> controller;

      switch (option.type) {
        case SharedPrefsTypes.bool:
          controller = ValueNotifier<bool>(option.restore() ?? false);
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
          controller = TextEditingController(text: option.restore() ?? '');
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
      itemBuilder: (BuildContext context, int i) => _buildPrefItem(context, _options[i]),
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
      final bool readOnly = option.readOnly;
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
            controller: listenable,
            readOnly: readOnly,
          );

        case SharedPrefsTypes.double:
        case SharedPrefsTypes.int:
          return TextField(
            controller: listenable,
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

    return _options
        .whereType<StringPreferenceItem>()
        .firstWhere(
          (PreferenceItem option) => option.key == SharedPrefsKeys.SALMON_STATS_TOKEN,
        )
        .save(token);
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
    final String settingsPageUrl = '${Config.SALMON_STATS_URL}/settings#app-request-api-token';
    final RegExp tokenUrlPattern = RegExp(r'#token=(.+)$');

    return Scaffold(
      appBar: AppBar(),
      body: WebView(
        initialUrl: settingsPageUrl,
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
