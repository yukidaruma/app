// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "clear" : MessageLookupByLibrary.simpleMessage("Clear"),
    "errorDialogTitle" : MessageLookupByLibrary.simpleMessage("Error"),
    "fail" : MessageLookupByLibrary.simpleMessage("Fail"),
    "iksmSession" : MessageLookupByLibrary.simpleMessage("iksm_session"),
    "iksmSessionPromptText" : MessageLookupByLibrary.simpleMessage("Enter your iksm_session"),
    "invalidIksmSession" : MessageLookupByLibrary.simpleMessage("Invalid iksm_session. Please make sure you enter correct iksm_session and try again."),
    "navResults" : MessageLookupByLibrary.simpleMessage("Results"),
    "ok" : MessageLookupByLibrary.simpleMessage("OK"),
    "resultsFetchingError" : MessageLookupByLibrary.simpleMessage("Failed to fetch results from Splatnet."),
    "salmonStats" : MessageLookupByLibrary.simpleMessage("Salmon Stats"),
    "salmonStatsApiToken" : MessageLookupByLibrary.simpleMessage("Salmon Stats\nAPI Token"),
    "settings" : MessageLookupByLibrary.simpleMessage("Settings")
  };
}
