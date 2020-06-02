// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

class S {
  S();
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S();
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  String get iksmSessionPromptText {
    return Intl.message(
      'Enter your iksm_session',
      name: 'iksmSessionPromptText',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '\$comment' key

  String get errorDialogTitle {
    return Intl.message(
      'Error',
      name: 'errorDialogTitle',
      desc: '',
      args: [],
    );
  }

  String get invalidIksmSession {
    return Intl.message(
      'Invalid iksm_session. Please make sure you enter correct iksm_session and try again.',
      name: 'invalidIksmSession',
      desc: '',
      args: [],
    );
  }

  String get resultsFetchingError {
    return Intl.message(
      'Failed to fetch results from Splatnet.',
      name: 'resultsFetchingError',
      desc: '',
      args: [],
    );
  }

  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  String get clear {
    return Intl.message(
      'Clear',
      name: 'clear',
      desc: '',
      args: [],
    );
  }

  String get fail {
    return Intl.message(
      'Fail',
      name: 'fail',
      desc: '',
      args: [],
    );
  }

  String get iksmSession {
    return Intl.message(
      'iksm_session',
      name: 'iksmSession',
      desc: '',
      args: [],
    );
  }

  String get navResults {
    return Intl.message(
      'Results',
      name: 'navResults',
      desc: '',
      args: [],
    );
  }

  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  String get salmonStats {
    return Intl.message(
      'Salmon Stats',
      name: 'salmonStats',
      desc: '',
      args: [],
    );
  }

  String get salmonStatsApiToken {
    return Intl.message(
      'Salmon Stats\nAPI Token',
      name: 'salmonStatsApiToken',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ja'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}