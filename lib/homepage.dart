import 'package:fluent_ui/fluent_ui.dart';
import 'package:idcard_maker_frontend/pages/add_id_card.dart';
import 'package:idcard_maker_frontend/widgets/load_id_card_data.dart';
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
          child: Column(
            children: [
              // Button(
              //   child: Text("Generate ID Card"),
              //   onPressed: () {
              //     Navigator.of(context).push(
              //       FluentPageRoute(
              //         builder: (context) => AddIdCardPage(),
              //       ),
              //     );
              //   },
              // ),
              // Text(
              //   "Lorem ipsum dolor sit amet consectetur adipisicing elit. Maxime mollitia,molestiae quas vel sint commodi repudiandae consequuntur voluptatum laborum numquam blanditiis harum quisquam eius sed odit fugiat iusto fuga praesentiumoptio, eaque rerum! Provident similique accusantium nemo autem. Veritatis obcaecati tenetur iure eius earum ut molestias architecto voluptate aliquamnihil, eveniet aliquid culpa officia aut! Impedit sit sunt quaerat, odit,tenetur error, harum nesciunt ipsum debitis quas aliquid.",
              // ),
              Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                child: Text(
                  "Lorem ipsum dolor sit amet consectetur adipisicing elit. Maxime mollitia,molestiae quas vel sint commodi repudiandae consequuntur voluptatum laborum numquam blanditiis harum quisquam eius sed odit fugiat iusto fuga praesentiumoptio, eaque rerum! Provident similique accusantium nemo autem. Veritatis obcaecati tenetur iure eius earum ut molestias architecto voluptate aliquamnihil, eveniet aliquid culpa officia aut! Impedit sit sunt quaerat, odit,tenetur error, harum nesciunt ipsum debitis quas aliquid.",
                ),
              ),
              Button(
                child: Text("Upload"),
                onPressed: () {
                  showDialog(
                      context: context, builder: (context) => LoadIdCardData());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
