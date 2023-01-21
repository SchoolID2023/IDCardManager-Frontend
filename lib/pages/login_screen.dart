import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:idcard_maker_frontend/pages/homepage.dart';
import 'package:idcard_maker_frontend/pages/school_admin_login.dart';
import 'package:idcard_maker_frontend/pages/school_info_page.dart';
import 'package:idcard_maker_frontend/services/remote_services.dart';
import '../services/logger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final RemoteServices remoteServices = RemoteServices();

  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool sendingOtp = true;
  int role = 0;
  @override
  Widget build(BuildContext context) {
    double cwidth = MediaQuery.of(context).size.width;
    double cheight = MediaQuery.of(context).size.height;
    ThemeData theme = FluentTheme.of(context);

    return ScaffoldPage(
      content: Center(
        child: Container(
          width: cwidth * 0.4,
          height: cheight * 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ID Card Maker",
                style: theme.typography.display,
              ),
              const SizedBox(
                height: 20,
              ),
              TextBox(
                controller: sendingOtp ? _numberController : _otpController,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.accentColor),
                  borderRadius: BorderRadius.circular(5),
                ),
                placeholder:
                    sendingOtp ? "Enter your 10 digit number" : "Enter OTP",
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: 20,
              ),
              Button(
                onPressed: sendingOtp
                    ? () async {
                        try {
                          await remoteServices
                              .sendOtp(_numberController.text, role)
                              .then((value) => {
                                    setState(() {
                                      sendingOtp = false;
                                    })
                                  });
                        } catch (e) {
                          role = 1;
                          await remoteServices
                              .sendOtp(_numberController.text, role)
                              .then((value) => {
                                    setState(() {
                                      sendingOtp = false;
                                    })
                                  });
                        }
                      }
                    : () async {
                        try {
                          await remoteServices
                              .verifyOtp(_numberController.text,
                                  _otpController.text, role)
                              .then((value) => {
                                    {
                                      role == 0
                                          ? Navigator.of(context)
                                              .pushReplacement(FluentPageRoute(
                                                  builder: (context) =>
                                                      HomePage()))
                                          : Navigator.of(context)
                                              .pushReplacement(
                                              FluentPageRoute(
                                                builder: (context) =>
                                                    SchoolInfoPage(
                                                  schoolId: value,
                                                  role: role,
                                                ),
                                              ),
                                            )
                                    }
                                  });
                        } catch (e) {
                          logger.e(e);
                          showSnackbar(
                            context,
                            const Snackbar(
                              content: Text(
                                'Wrong email or password',
                              ),
                            ),
                          );
                        }
                      },
                child: Text(
                  sendingOtp ? "Send OTP" : "Verify OTP",
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // return ScaffoldPage(
    //   content: Stack(
    //     children: [
    //       SizedBox(
    //         width: cwidth,
    //         height: cheight,
    //         child: Image.network(
    //           "https://images.unsplash.com/flagged/photo-1574097656146-0b43b7660cb6?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8aW5kaWFuJTIwc2Nob29sc3xlbnwwfHwwfHw%3D&w=1000&q=80",
    //           fit: BoxFit.cover,
    //         ),
    //       ),
    //       ClipRRect(
    //         // Clip it cleanly.
    //         child: BackdropFilter(
    //           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    //           child: Container(
    //             color: Colors.grey.withOpacity(0.1),
    //             alignment: Alignment.center,
    //             child: Center(
    //               child: ClipRect(
    //                 child: BackdropFilter(
    //                   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
    //                   child: Container(
    //                     width: 500.0,
    //                     height: 300.0,
    //                     decoration:
    //                         BoxDecoration(color: Colors.white.withOpacity(0.2)),
    //                     child: Center(
    //                       child: Padding(
    //                         padding: const EdgeInsets.symmetric(
    //                           vertical: 8.0,
    //                           horizontal: 16.0,
    //                         ),
    //                         child: Column(
    //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                           children: [
    //                             const Text(
    //                               'Super Admin Login',
    //                               style: TextStyle(
    //                                 fontSize: 24,
    //                                 fontWeight: FontWeight.bold,
    //                               ),
    //                             ),
    //                             TextBox(
    //                               placeholder: 'Email',
    //                               controller: _emailController,
    //                             ),
    //                             TextBox(
    //                               placeholder: 'Password',
    //                               obscureText: true,
    //                               controller: _passwordController,
    //                             ),
    //                             Row(
    //                               mainAxisAlignment:
    //                                   MainAxisAlignment.spaceAround,
    //                               children: [
    //                                 Button(
    //                                   child: const Text("Log In"),
    //                                   onPressed: () async {
    //                                     // final navigator = Navigator.of(context);
    //                                     bool isFailed = false;

    //                                     try {
    //                                       await _remoteServices.login(
    //                                         _emailController.text,
    //                                         _passwordController.text,
    //                                         true,
    //                                       );
    //                                       // navigator.push(
    //                                       //   FluentPageRoute(
    //                                       //     builder: (context) => HomePage(),
    //                                       //   ),
    //                                       // );
    //                                       // Navigator.push(
    //                                       //   context,
    //                                       //   FluentPageRoute(
    //                                       //     builder: (context) => HomePage(),
    //                                       //   ),
    //                                       // );
    //                                     } catch (e) {
    //                                       isFailed = true;
    // showSnackbar(
    //   context,
    //   const Snackbar(
    //     content: Text(
    //       'Wrong email or password',
    //     ),
    //   ),
    // );
    //                                     }

    //                                     if (!isFailed) {
    //                                       Navigator.push(
    //                                         context,
    //                                         FluentPageRoute(
    //                                           builder: (context) => HomePage(),
    //                                         ),
    //                                       );
    //                                     }
    //                                   },
    //                                 ),
    //                                 Button(
    //                                   child: const Text(
    //                                       "Log In As School Admin Instead"),
    //                                   onPressed: () {
    //                                     try {
    //                                       Navigator.push(
    //                                         context,
    //                                         FluentPageRoute(
    //                                           builder: (context) =>
    //                                               const SchoolAdminLoginPage(),
    //                                         ),
    //                                       );
    //                                     } catch (e) {
    //                                       logger.d(e);
    //                                     }
    //                                   },
    //                                 ),
    //                               ],
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
