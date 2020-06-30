import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:salmon_stats_app/api.dart';
import 'package:salmon_stats_app/config.dart';
import 'package:salmon_stats_app/model/all.dart';
import 'package:salmon_stats_app/store/database/all.dart';
import 'package:salmon_stats_app/store/global.dart';
import 'package:salmon_stats_app/ui/all.dart';
import 'package:salmon_stats_app/util/all.dart';

class EnterIksmPage extends StatefulWidget {
  const EnterIksmPage({this.restartOnComplete = false});

  final bool restartOnComplete;

  @override
  _EnterIksmPageState createState() => _EnterIksmPageState();
}

class _EnterIksmPageState extends State<EnterIksmPage> {
  final TextEditingController _iksmTextFieldController = TextEditingController();

  bool get _isIksmSessionValid => validIksmPattern.hasMatch(_iksmTextFieldController.text);

  @override
  void initState() {
    super.initState();

    if (context.read<GlobalStore>().isInDebugMode && Config.DEV_IKSM_SESSION != null) {
      _iksmTextFieldController.text = Config.DEV_IKSM_SESSION;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(S.of(context).iksmSessionPromptText),
          TextField(
            decoration: InputDecoration(
              labelText: S.of(context).iksmSession,
            ),
            controller: _iksmTextFieldController,
            maxLength: IKSM_SESSION_LENGTH,
            obscureText: Config.DEV_OBSCURE_IKSM_SESSION,
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _iksmTextFieldController,
            builder: (_, __, ___) => Center(
              child: RaisedButton(
                child: Text(S.of(context).continueButtonText),
                onPressed: _isIksmSessionValid ? () => _addAccount(context) : null,
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: PagePadding(child: body),
    );
  }

  Future<void> _addAccount(BuildContext context) async {
    final String iksmSession = _iksmTextFieldController.text;
    final CookieJar cookieJar = createCookieJar(iksmSession);

    try {
      final SplatnetAPIRepository repository = SplatnetAPIRepository(cookieJar);
      final String pid = await repository.fetchNSAId();
      final NicknameAndIcon nicknameAndIcon = await repository.fetchNicknameAndIcon(pid);
      final Uint8List avatar = await repository.fetchIcon(nicknameAndIcon.thumbnailUrl);

      final UserProfile profile = UserProfile()
        ..pid = pid
        ..name = nicknameAndIcon.nickname
        ..isActiveBool = true
        ..iksmSession = iksmSession
        ..avatar = avatar;

      await UserProfileRepository(DatabaseProvider.instance).create(profile);

      final GlobalStore store = context.read<GlobalStore>();
      store
        ..addProfile(profile)
        ..cookieJar = cookieJar;

      if (widget.restartOnComplete) {
        await store.switchProfile(profile);
        Navigator.pop(context);
      }
    } on DatabaseException catch (e) {
      if (!e.isUniqueConstraintError()) {
        rethrow;
      }

      return showErrorMessageDialog(
        context: context,
        message: S.of(context).iksmSessionAlreadyUsed,
      );
    } catch (_) {
      return showErrorMessageDialog(
        context: context,
        message: S.of(context).invalidIksmSession,
      );
    }
  }
}
