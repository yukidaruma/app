import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:salmonia_android/api.dart';
import 'package:salmonia_android/config.dart';
import 'package:salmonia_android/model/all.dart';
import 'package:salmonia_android/store/database/all.dart';
import 'package:salmonia_android/store/global.dart';
import 'package:salmonia_android/ui/all.dart';
import 'package:salmonia_android/util/all.dart';

class EnterIksmPage extends StatefulWidget {
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
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _iksmTextFieldController,
            builder: (_, __, ___) => Center(
              child: RaisedButton(
                child: Text('Continue'),
                onPressed: _isIksmSessionValid ? () => _setIksmSession(context) : null,
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

  Future<void> _setIksmSession(BuildContext context) async {
    final String iksmSession = _iksmTextFieldController.text;
    final CookieJar cookieJar = await createCookieJar(iksmSession);

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
      await UserProfileRepository(DatabaseProvider.instance).save(profile);

      final GlobalStore store = context.read<GlobalStore>();
      store
        ..profile = profile
        ..cookieJar = cookieJar;
    } catch (_) {
      return showErrorMessageDialog(
        context: context,
        message: S.of(context).invalidIksmSession,
      );
    }
  }
}
