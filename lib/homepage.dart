import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/school_controller.dart';
import 'package:idcard_maker_frontend/models/superadmin_model.dart';
import 'package:idcard_maker_frontend/widgets/titlebar/navigation_app_bar.dart';
import 'package:idcard_maker_frontend/widgets/titlebar/window_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/schools_model.dart';
import 'pages/login_screen.dart';
import 'widgets/school_tile.dart';

class HomePage extends StatelessWidget {
  final SchoolController schoolController = Get.put(SchoolController());

  final TextEditingController _schoolName = TextEditingController();
  final TextEditingController _schoolAddress = TextEditingController();
  final TextEditingController _schoolClasses = TextEditingController();
  final TextEditingController _schoolSections = TextEditingController();
  final TextEditingController _schoolContact = TextEditingController();
  final TextEditingController _schoolEmail = TextEditingController();

  final TextEditingController _superAdminName = TextEditingController();
  final TextEditingController _superAdminUsername = TextEditingController();
  final TextEditingController _superAdminPassword = TextEditingController();
  final TextEditingController _superAdminContact = TextEditingController();
  final TextEditingController _superAdminEmail = TextEditingController();

  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: customNavigationAppBar("All Schools", context,
          isHomePage: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Button(
                child: const Text("Log Out"),
                onPressed: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('token').then((value) => Navigator.of(context)
                      .push(FluentPageRoute(
                          builder: (context) => const LoginPage())));
                },
              ),
            ),
          ]),
      content: ScaffoldPage(
        header: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Row(
            children: [
              Text(
                "Manage School",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.blue,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Button(
                  child: const Text("Add Super Admin"),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ContentDialog(
                          title: const Text("Super Admin Details"),
                          actions: [
                            Button(
                              child: const Text("Add Super Admin"),
                              onPressed: () {
                                schoolController.addSuperAdmin(SuperAdmin(
                                  email: _superAdminEmail.text,
                                  password: _superAdminPassword.text,
                                  name: _superAdminName.text,
                                  contact: _superAdminContact.text,
                                  username: _superAdminUsername.text,
                                ));

                                Navigator.of(context).pop();
                              },
                            ),
                            Button(
                              child: const Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextBox(
                                controller: _superAdminName,
                                header: "superAdmin Name",
                              ),
                              TextBox(
                                controller: _superAdminUsername,
                                header: "superAdmin Username",
                              ),
                              TextBox(
                                controller: _superAdminPassword,
                                header: "Password",
                              ),
                              TextBox(
                                controller: _superAdminContact,
                                header: "Contact",
                              ),
                              TextBox(
                                controller: _superAdminEmail,
                                header: "Email",
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Button(
                  child: const Text("Add School"),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ContentDialog(
                          title: const Text("School Details"),
                          actions: [
                            Button(
                              child: const Text("Add Save"),
                              onPressed: () {
                                schoolController.addSchool(
                                  School(
                                    id: DateTime.now().toString(),
                                    name: _schoolName.text,
                                    address: _schoolAddress.text,
                                    classes: _schoolClasses.text.split(','),
                                    sections: _schoolSections.text.split(','),
                                    contact: _schoolContact.text,
                                    email: _schoolEmail.text,
                                  ),
                                );
                                Navigator.of(context).pop();
                              },
                            ),
                            Button(
                              child: const Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextBox(
                                controller: _schoolName,
                                header: "School Name",
                              ),
                              TextBox(
                                controller: _schoolAddress,
                                header: "School Address",
                              ),
                              TextBox(
                                controller: _schoolClasses,
                                header: "Classes",
                              ),
                              TextBox(
                                controller: _schoolSections,
                                header: "Sections",
                              ),
                              TextBox(
                                controller: _schoolContact,
                                header: "Contact",
                              ),
                              TextBox(
                                controller: _schoolEmail,
                                header: "Email",
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // content: Center(
        //   child: Column(
        //     children: [
        //       Button(
        //         child: Text("Upload"),
        // onPressed: () {
        //   showDialog(
        //       context: context, builder: (context) => LoadIdCardData());
        // },
        //       ),
        //     ],
        //   ),
        // ),
        content: Obx(() {
          return schoolController.isLoading.value
              ? const Center(
                  child: ProgressRing(),
                )
              : ListView.builder(
                  itemBuilder: ((context, index) {
                    return SchoolTile(
                      school: schoolController.schools.value.schools[index],
                    );
                  }),
                  itemCount: schoolController.schools.value.schools.length,
                );
          // : Text(schoolController.schools.value.schools.length.toString());
        }),
      ),
    );
  }
}
