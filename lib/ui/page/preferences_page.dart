import 'dart:async';

import 'package:flutter/material.dart';
import 'package:salmon_stats_app/api.dart';
import 'package:salmon_stats_app/config.dart';
import 'package:salmon_stats_app/exceptions.dart';
import 'package:salmon_stats_app/store/global.dart';
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
    this.defaultValue,
  });

  final SharedPrefsKey key;
  final LabelBuilder labelBuilder;
  final bool Function() readOnly;
  final SharedPrefsType type;
  final T defaultValue;

  // ignore: missing_return
  T restore() {
    switch (type) {
      case SharedPrefsType.bool:
        return _sharedPrefs.getBoolUnsafe(key) as T ?? defaultValue;
      case SharedPrefsType.double:
        return _sharedPrefs.getDoubleUnsafe(key) as T ?? defaultValue;
      case SharedPrefsType.int:
        return _sharedPrefs.getIntUnsafe(key) as T ?? defaultValue;
      case SharedPrefsType.string:
        return _sharedPrefs.getStringUnsafe(key) as T ?? defaultValue;
    }
  }

  // ignore: missing_return
  Future<void> save(T value) {
    switch (type) {
      case SharedPrefsType.bool:
        return _sharedPrefs.setBool(key, value as bool);
      case SharedPrefsType.double:
        return _sharedPrefs.setDouble(key, value as double);
      case SharedPrefsType.int:
        return _sharedPrefs.setInt(key, value as int);
      case SharedPrefsType.string:
        return _sharedPrefs.setString(key, value as String);
    }
  }
}

class BoolPreferenceItem extends PreferenceItem<bool> {
  const BoolPreferenceItem({
    bool Function() readOnly,
    @required SharedPrefsKey key,
    @required LabelBuilder labelBuilder,
    bool defaultValue,
  }) : super(
          readOnly: readOnly,
          key: key,
          labelBuilder: labelBuilder,
          type: SharedPrefsType.bool,
          defaultValue: defaultValue,
        );
}

class DoublePreferenceItem extends PreferenceItem<double> {
  const DoublePreferenceItem({
    bool Function() readOnly,
    @required SharedPrefsKey key,
    @required LabelBuilder labelBuilder,
    double defaultValue,
  }) : super(
          readOnly: readOnly,
          key: key,
          labelBuilder: labelBuilder,
          type: SharedPrefsType.double,
          defaultValue: defaultValue,
        );
}

class IntPreferenceItem extends PreferenceItem<int> {
  const IntPreferenceItem({
    bool Function() readOnly,
    @required SharedPrefsKey key,
    @required LabelBuilder labelBuilder,
    int defaultValue,
  }) : super(
          readOnly: readOnly,
          key: key,
          labelBuilder: labelBuilder,
          type: SharedPrefsType.int,
          defaultValue: defaultValue,
        );
}

class StringPreferenceItem extends PreferenceItem<String> {
  const StringPreferenceItem({
    bool Function() readOnly,
    @required SharedPrefsKey key,
    @required LabelBuilder labelBuilder,
    String defaultValue,
  }) : super(
          readOnly: readOnly,
          key: key,
          labelBuilder: labelBuilder,
          type: SharedPrefsType.string,
          defaultValue: defaultValue,
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
  final Map<SharedPrefsKey, ValueNotifier<dynamic>> _controllers = <SharedPrefsKey, ValueNotifier<dynamic>>{};
  List<PreferenceItem> _options;
  bool _enterApiTokenManually = false;

  @override
  void initState() {
    super.initState();

    final AppSharedPrefs prefs = AppSharedPrefs();

    _options = <PreferenceItem>[
      StringPreferenceItem(
        readOnly: () => !_enterApiTokenManually,
        key: SharedPrefsKey.SALMON_STATS_TOKEN,
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
        builder: (_) => FlatButton(
          child: Text(S.of(context).enterApiTokenManually),
          onPressed: () => setState(() => _enterApiTokenManually = true),
        ),
      ),
      if (context.read<GlobalStore>().isInDebugMode)
        WidgetPreferenceItem(
          visibility: () => !_enterApiTokenManually,
          builder: (_) => Column(
            children: <Widget>[
              FlatButton(
                child: Text('[DEV] Reset all settings', style: errorTextStyle(context)),
                onPressed: () => AppSharedPrefs().devResetAll().then((_) => Navigator.pop(context)),
              ),
            ],
          ),
        ),
    ];

    for (final PreferenceItem option in _options) {
      ValueNotifier<dynamic> controller;

      switch (option.type) {
        case SharedPrefsType.bool:
          controller = ValueNotifier<bool>(option.restore() as bool ?? false);
          controller.addListener(() => option.save(controller.value));
          break;

        case SharedPrefsType.double:
        case SharedPrefsType.int:
          controller = TextEditingController(text: (option.restore() ?? 0).toString());
          controller.addListener(() {
            final String text = (controller as TextEditingController).text;
            final dynamic parsedValue = option.type == SharedPrefsType.int ? int.tryParse(text) : double.tryParse(text);
            return option.save(parsedValue);
          });
          break;

        case SharedPrefsType.string:
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
        case SharedPrefsType.bool:
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

        case SharedPrefsType.string:
          return TextField(
            controller: listenable as TextEditingController,
            readOnly: readOnly,
          );

        case SharedPrefsType.double:
        case SharedPrefsType.int:
          return TextField(
            controller: listenable as TextEditingController,
            readOnly: readOnly,
            keyboardType: option.type == SharedPrefsType.int ? const TextInputType.numberWithOptions(decimal: false) : TextInputType.number,
          );
      }
    })();

    if (option is WidgetPreferenceItem) {
      return option.builder(context);
    }

    if (control is TextField) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(option.labelBuilder(context)),
          control,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          flex: 8,
          child: Text(option.labelBuilder(context)),
        ),
        Expanded(
          flex: 2,
          child: control,
        ),
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
        .whereType<MapEntry<SharedPrefsKey, ValueNotifier<TextEditingValue>>>()
        .firstWhere(
          (MapEntry<SharedPrefsKey, ValueNotifier<dynamic>> controller) => controller.key == SharedPrefsKey.SALMON_STATS_TOKEN,
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
