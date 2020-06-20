import 'package:dart_json_mapper/dart_json_mapper.dart';

@jsonSerializable
class UploadSalmonResultsResponse {
  List<UploadResult> uploadResults;
}

@jsonSerializable
class UploadResult {
  bool created;
  int jobId;
  int salmonId;
}
