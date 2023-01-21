import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';
import 'package:idcard_maker_frontend/pages/school/idcard.dart';
import 'package:idcard_maker_frontend/pages/school/students.dart';
import 'package:idcard_maker_frontend/services/download_data.dart';
import 'package:idcard_maker_frontend/widgets/dialog/add_student.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote_services.dart';
import '../widgets/dialog/download_photos.dart';
import '../widgets/dialog/load_excel.dart';
import '../widgets/load_photos.dart';
import '../widgets/titlebar/navigation_app_bar.dart';
import 'login_screen.dart';
import 'school/home.dart';

class SchoolInfoPage extends StatefulWidget {
  final int role;
  final String schoolId;
  const SchoolInfoPage({super.key, required this.schoolId, this.role = 0});

  @override
  State<SchoolInfoPage> createState() => _SchoolInfoPageState();
}

class _SchoolInfoPageState extends State<SchoolInfoPage> {
  int index = 0;
  final RemoteServices _remoteServices = RemoteServices();
  late StudentController studentController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    studentController = Get.put(StudentController(widget.schoolId));

    () async {
      studentController.setLoading = true;
      await studentController.setRole(widget.role);

      try {
        await studentController.fetchSchoolLabels(widget.schoolId);
        await studentController.fetchSchool(widget.schoolId);
        await studentController.fetchAdmins(widget.schoolId);
        await studentController.fetchTeachers(widget.schoolId);
        await studentController.fetchStudents(widget.schoolId);
        await studentController.fetchIdCardList(widget.schoolId);
        studentController.setLoading = false;
      } catch (e) {
        showDialog(
            context: context,
            builder: (context) => ContentDialog(
                  title: const Text("Error"),
                  content: Text(e.toString()),
                  actions: [
                    Button(
                      child: const Text("Log Out"),
                      onPressed: () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.remove('token').then((value) =>
                            Navigator.of(context).push(FluentPageRoute(
                                builder: (context) => const LoginPage())));
                      },
                    ),
                  ],
                ));
      }

         
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (studentController.isLoading.value) {
        return const ScaffoldPage(
          content: Center(child: ProgressRing()),
        );
      }

      return NavigationView(
        appBar: customNavigationAppBar(
          "School Info",
          context,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Button(
                child: const Text("Add Student"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddStudent(
                      labels: studentController.getSchoolLabels.labels,
                      currentSchool: studentController.getSchool.id,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Button(
                child: const Text("Upload Data"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => LoadExcel(
                      schoolId: widget.schoolId,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Button(
                child: const Text("Upload Photos"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => LoadPhotos(
                      schoolId: widget.schoolId,
                      fields: studentController.getSchoolLabels.labels,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Button(
                child: const Text(
                  "Download Data",
                ),
                onPressed: () {
                  _remoteServices.generateExcel(
                    widget.schoolId,
                    'all',
                    'all',
                  );
                },
              ),
            ),
            studentController.getSchoolLabels.photoLabels.isEmpty
                ? Container()
                : Button(
                    child: Text("Download Photos"),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => DownloadPhotosDialog(
                          schoolId: widget.schoolId,
                        ),
                      );
                    }),
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
          ],
        ),
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
              icon: const Icon(FluentIcons.home),
              title: const Text("Home"),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.people),
              title: const Text("Students"),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.i_d_badge),
              title: const Text("ID Cards"),
            ),
          ],
        ),
        content: NavigationBody(
          index: index,
          children: [
            Home(
              schoolId: widget.schoolId,
            ),
            Students(
              schoolId: widget.schoolId,
            ),
            IdCard(
              schoolId: widget.schoolId,
            )
          ],
        ),
      );
    });
  }
}
