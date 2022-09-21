import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/school_controller.dart';
import 'package:idcard_maker_frontend/models/superadmin_model.dart';
import 'package:idcard_maker_frontend/pages/add_id_card.dart';
import 'package:idcard_maker_frontend/widgets/load_id_card_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/schools_model.dart';
import 'pages/login_screen.dart';
import 'widgets/school_tile.dart';

class HomePage extends StatelessWidget {
  final SchoolController schoolController = Get.put(SchoolController());

  TextEditingController _schoolName = TextEditingController();
  TextEditingController _schoolAddress = TextEditingController();
  TextEditingController _schoolClasses = TextEditingController();
  TextEditingController _schoolSections = TextEditingController();
  TextEditingController _schoolContact = TextEditingController();
  TextEditingController _schoolEmail = TextEditingController();

  TextEditingController _superAdminName = TextEditingController();
  TextEditingController _superAdminUsername = TextEditingController();
  TextEditingController _superAdminPassword = TextEditingController();
  TextEditingController _superAdminContact = TextEditingController();
  TextEditingController _superAdminEmail = TextEditingController();

  // Future<void> logOut() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.remove('token');
  //   Navigator.of(context)
  //       .push(FluentPageRoute(builder: (context) => LoginPage()));
  // }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: const Text('Id Card Maker'),
        actions: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
        ),
      ),
      // pane: NavigationPane(
      //   onChanged: (value) async {
      //     if (value == 1) {
      //       final SharedPreferences prefs =
      //           await SharedPreferences.getInstance();
      //       prefs.remove('token');
      //       Navigator.of(context)
      //           .push(FluentPageRoute(builder: (context) => LoginPage()));
      //     }
      //   },
      //   items: [
      //     PaneItem(
      //       icon: Icon(FluentIcons.home),
      //       title: const Text('Home'),
      //     ),
      //     PaneItem(
      //       icon: Icon(FluentIcons.log_remove),
      //       title: const Text('Log Out'),
      //     )
      //   ],
      //   displayMode: PaneDisplayMode.top,
      // ),
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
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Button(
                  child: Text("Add Super Admin"),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ContentDialog(
                          title: Text("Super Admin Details"),
                          actions: [
                            Button(
                              child: Text("Add Super Admin"),
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
                              child: Text("Cancel"),
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
                  child: Text("Add School"),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ContentDialog(
                          title: Text("School Details"),
                          actions: [
                            Button(
                              child: Text("Add Save"),
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
                              child: Text("Cancel"),
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
              ? Center(
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
