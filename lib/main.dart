import 'package:flutter/foundation.dart';
import 'package:idcard_maker_frontend/homepage.dart';
import 'package:get/get.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:idcard_maker_frontend/pages/login_screen.dart';
import 'package:idcard_maker_frontend/pages/student_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'ID Card Maker',
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          accentColor: Colors.blue,
          iconTheme: const IconThemeData(size: 24)),
      darkTheme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          accentColor: Colors.blue,
          iconTheme: const IconThemeData(size: 24)),
      home: LoginWrapper(),
    );
  }
}

class LoginWrapper extends StatelessWidget {
  LoginWrapper({Key? key}) : super(key: key);

  String token = "";
  String userType = "";
  String schoolId = "";

  Future<void> getToken(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? "";
    userType = prefs.getString('userType') ?? "";
    schoolId = prefs.getString('schoolId') ?? "";
    print("token: $token");
    try {
      if (token == "") {
        print("Heyy");
        Navigator.of(context)
            .push(FluentPageRoute(builder: (context) => LoginPage()));
      } else {
        print("Byeee");
        if (userType == "schoolAdmin") {
          Navigator.of(context)
              .push(FluentPageRoute(builder: (context) => LoginPage()));
          // Navigator.of(context).push(FluentPageRoute(
          //     builder: (context) => StudentDataScreen(schoolId: schoolId)));
        } else {
          Navigator.of(context)
              .push(FluentPageRoute(builder: (context) => HomePage()));
        }
      }
    } catch (e) {
      Navigator.of(context)
          .push(FluentPageRoute(builder: (context) => LoginPage()));

      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // getToken().then((value) {

    // });
    getToken(context);

    return ScaffoldPage(
      content: Center(
        child: ProgressRing(),
      ),
    );
  }
}
