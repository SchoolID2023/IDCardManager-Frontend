import 'package:idcard_maker_frontend/pages/homepage.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:idcard_maker_frontend/pages/login_screen.dart';
import 'package:idcard_maker_frontend/pages/school_info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  // doWhenWindowReady(() {
  //   const initialSize = Size(1200, 450);
  //   appWindow.minSize = initialSize;
  //   appWindow.size = initialSize;
  //   appWindow.alignment = Alignment.center;
  //   appWindow.show();
  // });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'ID Card Maker',
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: Colors.blue,
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blue,
      ),
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
    await SharedPreferences.getInstance().then((value) {
      token = value.getString('token') ?? "";
      userType = value.getString('userType') ?? "";
      schoolId = value.getString('schoolId') ?? "";
      logger.d("token: $token");
      try {
        if (token == "") {
          logger.d("Heyy");
          Navigator.of(context)
              .push(FluentPageRoute(builder: (context) => const LoginPage()));
        } else {
          logger.d("Byeee");
          logger.d("userType: $userType");
          if (userType == "schoolAdmin") {
            Navigator.of(context).push(FluentPageRoute(
              builder: (context) => SchoolInfoPage(
                schoolId: schoolId,
                role: 1,
              ),
            ));
          } else {
            Navigator.of(context)
                .push(FluentPageRoute(builder: (context) => HomePage()));
          }
        }
      } catch (e) {
        Navigator.of(context).push(
          FluentPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );

        logger.d(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getToken(context);

    return const ScaffoldPage(
      content: Center(
        child: ProgressRing(),
      ),
    );
  }
}
