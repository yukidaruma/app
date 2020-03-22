import 'package:flutter/widgets.dart';
import 'package:salmonia_android/config.dart';
import 'package:salmonia_android/ui/all.dart';

class SpecialWeapon extends StatelessWidget {
  const SpecialWeapon(this.specialId);

  final int specialId;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: '${Config.SALMON_IMAGE_BASE_PATH}/special/$specialId.png',
    );
  }
}
