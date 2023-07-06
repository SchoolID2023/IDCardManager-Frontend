import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import './window_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pages/login_screen.dart';

NavigationAppBar customNavigationAppBar(
  String title,
  BuildContext context, {
  bool isHomePage = false,
  List<Widget>? actions,
}) {
  return NavigationAppBar(
    leading: isHomePage
        ? Container()
        : IconButton(
            icon: const Icon(FluentIcons.back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
    title: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 24,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    ),
    actions: Row(
      children: [
        Expanded(child: MoveWindow()),
        Row(
          children: actions ?? [],
        ),
        // WindowButtons()
      ],
    ),
  );
}
