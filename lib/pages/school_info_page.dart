import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';

import '../services/remote_services.dart';
import '../widgets/load_excel.dart';
import '../widgets/load_photos.dart';
import '../widgets/titlebar/navigation_app_bar.dart';
import 'school/home.dart';

class SchoolInfoPage extends StatefulWidget {
  final String schoolId;
  const SchoolInfoPage({super.key, required this.schoolId});

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
    studentController.fetchSchoolLabels(widget.schoolId);
    studentController.fetchSchool(widget.schoolId);
    studentController.fetchAdmins(widget.schoolId);
    studentController.fetchTeachers(widget.schoolId);
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
                      fields: studentController.getSchoolLabels.photoLabels,
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
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropDownButton(
                      title: const Text('Download Photos'),
                      items: List<MenuFlyoutItem>.generate(
                        studentController.getSchoolLabels.photoLabels.length,
                        (index) => MenuFlyoutItem(
                          text: Text(studentController
                              .getSchoolLabels.photoLabels[index]),
                          onPressed: () {
                            _remoteServices.downloadPhotos(
                              widget.schoolId,
                              'all',
                              'all',
                              studentController
                                  .getSchoolLabels.photoLabels[index],
                            );
                          },
                        ),
                      ),
                    ),
                  )
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
              key: Key(widget.schoolId),
            ),
            const Text("Students"),
            const Text("ID Cards"),
          ],
        ),
      );
    });
  }
}
