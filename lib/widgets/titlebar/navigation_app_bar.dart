import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import './window_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pages/login_screen.dart';

NavigationAppBar customNavigationAppBar(String title, BuildContext context) {
  return NavigationAppBar(
    leading: Container(),
    title: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
       title,
        style: const TextStyle(
          fontSize: 24,
        ),
      ),
    ),
    actions: Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Button(
            child: const Text("Log Out"),
            onPressed: () async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              prefs.remove('token').then((value) => Navigator.of(context).push(
                  FluentPageRoute(builder: (context) => const LoginPage())));
            },
          ),
        ),
        Expanded(child: MoveWindow()),
        WindowButtons()
      ],
    ),
  );
}
