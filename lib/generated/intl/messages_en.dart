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

  static m0(pageName) => "Open ${pageName}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "aboutThisApp" : MessageLookupByLibrary.simpleMessage("About this app"),
    "cancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "clear" : MessageLookupByLibrary.simpleMessage("Clear"),
    "confirmCancelUploading" : MessageLookupByLibrary.simpleMessage("Are you sure you want to stop uploading?"),
    "confirmCancelUploadingYes" : MessageLookupByLibrary.simpleMessage("Yes, stop uploading"),
    "continueButtonText" : MessageLookupByLibrary.simpleMessage("Continue"),
    "enterApiTokenManually" : MessageLookupByLibrary.simpleMessage("Enter API Token manually"),
    "errorDialogTitle" : MessageLookupByLibrary.simpleMessage("Error"),
    "fail" : MessageLookupByLibrary.simpleMessage("Fail"),
    "getApiToken" : MessageLookupByLibrary.simpleMessage("Get API Token"),
    "goBack" : MessageLookupByLibrary.simpleMessage("Go back"),
    "iksmSession" : MessageLookupByLibrary.simpleMessage("iksm_session"),
    "iksmSessionPromptText" : MessageLookupByLibrary.simpleMessage("Enter your iksm_session"),
    "invalidIksmSession" : MessageLookupByLibrary.simpleMessage("Invalid iksm_session. Please make sure you enter correct iksm_session and try again."),
    "navResults" : MessageLookupByLibrary.simpleMessage("Results"),
    "noResultsFound" : MessageLookupByLibrary.simpleMessage("No results were found. Please play some Salmon Run and refresh the page."),
    "ok" : MessageLookupByLibrary.simpleMessage("OK"),
    "openOtherPage" : m0,
    "refresh" : MessageLookupByLibrary.simpleMessage("Refresh"),
    "resultPageUnderConstruction" : MessageLookupByLibrary.simpleMessage("Result page is under construction. For the time being, please upload result to Salmon Stats and visit Salmon Stats."),
    "resultsFetchingError" : MessageLookupByLibrary.simpleMessage("Failed to fetch results from Splatnet."),
    "salmonStats" : MessageLookupByLibrary.simpleMessage("Salmon Stats"),
    "salmonStatsApiToken" : MessageLookupByLibrary.simpleMessage("Salmon Stats\nAPI Token"),
    "salmonStatsApiTokenNotSet" : MessageLookupByLibrary.simpleMessage("Salmon Stats API Token is not set."),
    "salmonStatsProfile" : MessageLookupByLibrary.simpleMessage("profile"),
    "settings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "startUploadingButtonText" : MessageLookupByLibrary.simpleMessage("Start Uploading"),
    "updateApiToken" : MessageLookupByLibrary.simpleMessage("Update API Token"),
    "uploadCanceledButtonText" : MessageLookupByLibrary.simpleMessage("Successfully stopped "),
    "uploadCancellingButtonText" : MessageLookupByLibrary.simpleMessage("Stopping upload..."),
    "uploadCompletedButtonText" : MessageLookupByLibrary.simpleMessage("Upload completed."),
    "yes" : MessageLookupByLibrary.simpleMessage("Yes")
  };
}
