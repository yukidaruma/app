import 'package:dart_json_mapper/dart_json_mapper.dart';

@jsonSerializable
class UserProfile {
  String pid;
  String name;
  bool isActiveBool;
  String iksmSession;
  String sessionToken;
}
