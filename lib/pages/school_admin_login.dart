import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:idcard_maker_frontend/pages/login_screen.dart';
import 'package:idcard_maker_frontend/pages/student_data.dart';
import 'package:idcard_maker_frontend/services/remote_services.dart';
import '../services/logger.dart';

class SchoolAdminLoginPage extends StatefulWidget {
  const SchoolAdminLoginPage({Key? key}) : super(key: key);

  @override
  State<SchoolAdminLoginPage> createState() => _SchoolAdminLoginPageState();
}

class _SchoolAdminLoginPageState extends State<SchoolAdminLoginPage> {
  final RemoteServices _remoteServices = RemoteServices();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double cwidth = MediaQuery.of(context).size.width;
    double cheight = MediaQuery.of(context).size.height;
    return ScaffoldPage(
      content: Stack(
        children: [
          SizedBox(
            width: cwidth,
            height: cheight,
            child: Image.network(
              "https://images.unsplash.com/flagged/photo-1574097656146-0b43b7660cb6?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8aW5kaWFuJTIwc2Nob29sc3xlbnwwfHwwfHw%3D&w=1000&q=80",
              fit: BoxFit.cover,
            ),
          ),
          ClipRRect(
            // Clip it cleanly.
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.grey.withOpacity(0.1),
                alignment: Alignment.center,
                child: Center(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        width: 500.0,
                        height: 300.0,
                        decoration:
                            BoxDecoration(color: Colors.white.withOpacity(0.2)),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text(
                                  'School Admin Login',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextBox(
                                  placeholder: 'Email',
                                  controller: _emailController,
                                ),
                                TextBox(
                                  placeholder: 'Password',
                                  obscureText: true,
                                  controller: _passwordController,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Button(
                                      child: const Text("Log In"),
                                      onPressed: () async {
                                        try {
                                          final navigator =
                                              Navigator.of(context);
                                          String schoolId =
                                              await _remoteServices.login(
                                            _emailController.text,
                                            _passwordController.text,
                                            false,
                                          );
                                          navigator.push(
                                            FluentPageRoute(
                                              builder: (context) =>
                                                  StudentDataScreen(
                                                      schoolId: schoolId),
                                            ),
                                          );
                                          // Navigator.push(
                                          //   context,
                                          // FluentPageRoute(
                                          //   builder: (context) =>
                                          //       StudentDataScreen(
                                          //           schoolId: schoolId),
                                          // ),
                                          // );
                                        } catch (e) {
                                          logger.d(e);
                                        }
                                      },
                                    ),
                                    Button(
                                      child:
                                          const Text("Log In As Super Admin Instead"),
                                      onPressed: () {
                                        try {
                                          Navigator.push(
                                            context,
                                            FluentPageRoute(
                                              builder: (context) => const LoginPage(),
                                            ),
                                          );
                                        } catch (e) {
                                          logger.d(e);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
