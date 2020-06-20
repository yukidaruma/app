import 'package:flutter/material.dart';
import 'package:salmonia_android/store/shared_prefs.dart';
import 'package:salmonia_android/ui/all.dart';

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

final List<PreferenceItem> _options = <PreferenceItem>[
  StringPreferenceItem(
    readOnly: true,
    key: SharedPrefsKeys.SALMON_STATS_TOKEN,
    labelBuilder: (BuildContext context) => S.of(context).salmonStatsApiToken,
  ),
  BoolPreferenceItem(
    key: SharedPrefsKeys.TEST_BOOL,
    labelBuilder: (BuildContext context) => S.of(context).salmonStatsApiToken,
  ),
  IntPreferenceItem(
    key: SharedPrefsKeys.TEST_INT,
    labelBuilder: (BuildContext context) => S.of(context).salmonStatsApiToken,
  ),
  DoublePreferenceItem(
    key: SharedPrefsKeys.TEST_DOUBLE,
    labelBuilder: (BuildContext context) => S.of(context).salmonStatsApiToken,
  ),
];

class PreferencesPage extends StatefulWidget {
  const PreferencesPage();

  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  Map<SharedPrefsKeys, ValueNotifier> _controllers = <SharedPrefsKeys, ValueNotifier>{};

  @override
  void initState() {
    super.initState();

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

      _controllers[option.key] = controller;
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
    final Widget label = Text(option.labelBuilder(context));

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

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          child: label,
          width: 160,
        ),
        Expanded(child: control),
      ],
    );
  }
}
