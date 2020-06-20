import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:salmonia_android/api.dart';
import 'package:salmonia_android/model/all.dart';
import 'package:salmonia_android/store/database/all.dart';
import 'package:salmonia_android/store/global.dart';
import 'package:salmonia_android/ui/all.dart';

enum _UploadState {
  waiting,
  uploading,
  done,
}

class UploadResultsPage extends StatefulWidget {
  const UploadResultsPage({
    @required this.sinceId,
    @required this.untilId,
  });

  final int sinceId;
  final int untilId;

  @override
  _UploadResultsPageState createState() => _UploadResultsPageState();
}

class _UploadResultsPageState extends State<UploadResultsPage> {
  final ValueNotifier<int> _progressionController = ValueNotifier<int>(null);
  final ValueNotifier<String> _logController = ValueNotifier<String>('');
  _UploadState _uploadState = _UploadState.waiting;

  int get _count => widget.untilId - widget.sinceId + 1;
  int get _currentIndex => _progressionController.value - widget.sinceId;
  double get _progressionPercentage => _currentIndex / _count;

  @override
  void initState() {
    super.initState();

    _progressionController.value = widget.sinceId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: WillPopScope(
        onWillPop: () {
          if (_uploadState != _UploadState.uploading) {
            return Future<bool>.value(true);
          }

          return showConfirmationDialog(
            context: context,
            message: S.of(context).confirmCancelUploading,
            isDestructive: true,
            destructiveMessage: S.of(context).confirmCancelUploadingYes,
          );
        },
        child: ScrollColumnExpandable(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_uploadState == _UploadState.waiting)
              Expanded(
                child: Center(
                  child: RaisedButton(
                    child: Text(S.of(context).startUploading),
                    onPressed: _startUploading,
                  ),
                ),
              )
            else ...<Widget>[
              const Padding(padding: EdgeInsets.only(bottom: 24.0)),
              Center(
                child: ValueListenableBuilder<int>(
                  valueListenable: _progressionController,
                  builder: (_, __, ___) => Column(
                    children: <Widget>[
                      SizedBox.fromSize(
                        size: const Size.square(128.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 12.0,
                          backgroundColor: Theme.of(context).unselectedWidgetColor,
                          value: _progressionPercentage,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 24.0)),
                      Center(child: Text('$_currentIndex / $_count')),
                    ],
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 16.0)),
            ],
            ValueListenableBuilder<String>(
              valueListenable: _logController,
              builder: (_, String log, ___) => Text(log),
            ),
          ],
        ),
      ),
    );
  }

  void _addLog(String message) {
    _logController.value = '$message\n' + _logController.value;
  }

  Future<String> _uploadSalmonResult(int jobId) async {
    final String resultResponse = await SplatnetAPIRepository(context.read<GlobalStore>().cookieJar).fetchResultAsString(jobId);
    final Map<String, dynamic> resultMap = json.decode(resultResponse);
    final Map<String, dynamic> payload = <String, dynamic>{
      'results': <dynamic>[resultMap],
    };

    final String uploadResponse = await SalmonStatsRepository().upload(payload);

    final InternalSalmonResult result = InternalSalmonResult.fromString(resultResponse);
    await SalmonResultRepository(DatabaseProvider.instance).save(result);

    final UserProfile profile = context.read<GlobalStore>().profile;
    context.read<GlobalStore>().profile = profile..jobId = _progressionController.value;
    await UserProfileRepository(DatabaseProvider.instance).save(profile);

    return uploadResponse;
  }

  Future<void> _startUploading() async {
    setState(() => _uploadState = _UploadState.uploading);

    while (_currentIndex < _count) {
      _addLog('Uploading ${_progressionController.value}...');

      try {
        final String log = await _uploadSalmonResult(_progressionController.value);
        _progressionController.value += 1;
        _addLog(log);
      } on DioError catch (e) {
        _addLog((e.response?.data ?? e.toString()) as String);
        break;
      } catch (e) {
        _addLog(e.toString());
        break;
      }

      _addLog('Done');
    }

    setState(() => _uploadState = _UploadState.done);
  }
}
