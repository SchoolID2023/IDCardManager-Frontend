import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
          title: Center(child: const Text('Id Card Maker')),
          actions: Row(
            children: [
              Button(
                child: Text("Log Out"),
                onPressed: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('token');
                  Navigator.of(context)
                      .push(FluentPageRoute(builder: (context) => LoginPage()));
                },
              )
            ],
          )),
      content: ScaffoldPage(
        header: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Welcome !",
            style: TextStyle(
              fontSize: 40,
              color: Colors.blue,
            ),
          ),
        ),
        content: Center(
          child: Text("Welcome to Page 1!"),
        ),
      ),
    );
  }
}
