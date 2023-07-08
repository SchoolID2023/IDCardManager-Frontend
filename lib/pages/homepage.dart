import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/school_controller.dart';
import 'package:idcard_maker_frontend/widgets/dialog/add_super_admin.dart';
import 'package:idcard_maker_frontend/widgets/dialog/confirm_delete.dart';
import 'package:idcard_maker_frontend/widgets/titlebar/navigation_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import '../widgets/dialog/add_school.dart';
import '../widgets/school_tile.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SchoolController schoolController = Get.put(SchoolController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    () async {
      schoolController.setLoading = true;
      await schoolController.fetchSchools();
      await schoolController.fetchSuperAdmins();
      schoolController.setLoading = false;
    }();
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);
    return Obx(() {
      return NavigationView(
        appBar: customNavigationAppBar("ID Card Maker", context,
            isHomePage: true,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Button(
                  child: const Text("Add Super Admin"),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const AddSuperAdmin();
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
                        return const AddSchool();
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Button(
                  child: const Text("Log Out"),
                  onPressed: () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.remove('token').then(
                          (value) => Navigator.of(context).push(
                            FluentPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          ),
                        );
                  },
                ),
              ),
            ]),
        pane: NavigationPane(
          selected: index,
          onChanged: (newIndex) {
            setState(() {
              index = newIndex;
            });
          },
          displayMode: PaneDisplayMode.auto,
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.office_store_logo),
              title: const Text("Manage Schools"),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListView.builder(
                    itemCount: schoolController.getSchools.length,
                    itemBuilder: (context, index2) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.accentColor,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: SchoolTile(
                            school: schoolController.getSchools[index2],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.local_admin),
              title: const Text("Manage Super Admins"),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListView.builder(
                    itemCount: schoolController.getSuperAdmins.length,
                    itemBuilder: (context, index2) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.accentColor,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            title: Text(schoolController
                                .getSuperAdmins[index2].name
                                .toString()),
                            subtitle: Text(schoolController
                                .getSuperAdmins[index2].contact
                                .toString()),
                            trailing: SizedBox(
                              width: 200,
                              child: IconButton(
                                icon: Icon(
                                  FluentIcons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ConfirmDelete(
                                          type: "Super Admin",
                                          name: schoolController
                                              .getSuperAdmins[index2].name,
                                          deleteDialogueFunction: () {
                                            schoolController.deleteSuperAdmin(
                                                schoolController
                                                    .getSuperAdmins[index2].id);
                                          },
                                          deletePhoto: false,
                                        );
                                      });
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
