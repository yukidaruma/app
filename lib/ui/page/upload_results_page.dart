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
  cancelling,
  canceled,
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
    final Map<_UploadState, String> uploadStateMessagesMap = <_UploadState, String>{
      _UploadState.cancelling: S.of(context).uploadCancellingButtonText,
      _UploadState.canceled: S.of(context).uploadCanceledButtonText,
      _UploadState.done: S.of(context).uploadCompletedButtonText,
    };

    final Widget startUploadButton = (salmonStatsAPIToken?.isEmpty ?? true)
        ? Column(
            children: <Widget>[
              Text(S.of(context).salmonStatsApiTokenNotSet),
              const Padding(padding: EdgeInsets.only(bottom: 8.0)),
              RaisedButton(
                child: Text(S.of(context).openOtherPage(S.of(context).settings)),
                onPressed: () => PreferencesPage.push(context),
              ),
            ],
          )
        : RaisedButton(
            child: Text(S.of(context).startUploadingButtonText),
            onPressed: _startUploading,
          );

    final Widget body = WillPopScope(
      onWillPop: () async {
        if (_uploadState == _UploadState.cancelling) {
          return false;
        } else if (_uploadState != _UploadState.uploading) {
          return true;
        }

        final bool shouldCancel = await showConfirmationDialog(
              context: context,
              message: S.of(context).confirmCancelUploading,
              isDestructive: true,
              destructiveMessage: S.of(context).confirmCancelUploadingYes,
            ) ??
            false;

        if (shouldCancel) {
          _setUploadState(_UploadState.cancelling);
        }

        return false;
      },
      child: ScrollColumnExpandable(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_uploadState == _UploadState.waiting)
            Expanded(
              child: Center(
                child: startUploadButton,
              ),
            )
          else if (uploadStateMessagesMap.containsKey(_uploadState))
            Expanded(
              child: Center(
                child: RaisedButton(
                  child: Text(uploadStateMessagesMap[_uploadState]),
                  onPressed: _uploadState == _UploadState.cancelling ? null : () => Navigator.pop(context),
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
    );

    return Scaffold(
      appBar: AppBar(),
      body: PagePadding(child: body),
    );
  }

  void _addLog(String message) {
    _logController.value = '$message\n' + _logController.value;
  }

  Future<UploadSalmonResultsResponse> _uploadSalmonResult(int jobId) async {
    final String resultResponse = await SplatnetAPIRepository(context.read<GlobalStore>().cookieJar).fetchResultAsString(jobId);
    final Map<String, dynamic> resultMap = json.decode(resultResponse);
    final Map<String, dynamic> payload = <String, dynamic>{
      'results': <dynamic>[resultMap],
    };

    final UserProfile profile = context.read<GlobalStore>().profile;
    final String rawUploadResponse = await SalmonStatsRepository().upload(payload);
    final UploadSalmonResultsResponse uploadResult = JsonMapper.deserialize<UploadSalmonResultsResponse>(rawUploadResponse, DEFAULT_SERIALIZE_OPTIONS);
    final InternalSalmonResult result = InternalSalmonResult.fromSplatnetResponse(resultResponse, profile.pid, uploadResult.uploadResults.first.salmonId);
    await SalmonResultRepository(DatabaseProvider.instance).create(result);

    context.read<GlobalStore>().profile = profile..jobId = _progressionController.value;
    await UserProfileRepository(DatabaseProvider.instance).save(profile);

    return uploadResult;
  }

  Future<void> _startUploading() async {
    _setUploadState(_UploadState.uploading);

    while (_currentIndex < _count) {
      _addLog('Uploading ${_progressionController.value}...');

      try {
        final UploadSalmonResultsResponse uploadResult = await _uploadSalmonResult(_progressionController.value);

        _progressionController.value += 1;

        if (!uploadResult.uploadResults.first.created) {
          _addLog('${uploadResult.uploadResults.first.jobId} is already on Salmon Stats.');
        }
      } on DioError catch (e) {
        _addLog('Error ${e.response.statusCode}:\n' + (e.response?.data ?? e.toString()));
        break;
      } catch (e) {
        _addLog(e.toString());
        break;
      }

      if (_uploadState == _UploadState.cancelling) {
        _setUploadState(_UploadState.canceled);

        _addLog('Upload cancelled');
        return;
      }

      _addLog('Done');
    }

    _setUploadState(_UploadState.done);
  }

  void _setUploadState(_UploadState newState) => setState(() => _uploadState = newState);
}
