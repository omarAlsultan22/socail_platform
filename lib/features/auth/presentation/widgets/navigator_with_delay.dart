import 'package:flutter/cupertino.dart';
import '../../../../core/presentation/widgets/navigation/navigator.dart';


class NavigatorWithDelay {
  static void build({
    required Widget link,
    required BuildContext context,
  }) {
    Future.delayed(const Duration(seconds: AppDurations.oneSecond), () =>
        BuildNavigator.build(link: link, context: context)
    );
  }
}