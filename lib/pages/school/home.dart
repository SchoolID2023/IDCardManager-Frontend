import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';
import 'package:idcard_maker_frontend/services/logger.dart';

import '../../widgets/add_school_admin.dart';
import '../../widgets/add_school_teacher.dart';
import '../../widgets/edit_school.dart';

class Home extends StatefulWidget {
  final String schoolId;
  const Home({super.key, required this.schoolId});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late StudentController studentController;
  bool isInfoPage = true;

  @override
  void initState() {
    logger.i("Home Page SchoolID: ${widget.schoolId}");
    studentController = Get.put(StudentController(widget.schoolId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = FluentTheme.of(context);
    return Obx(
      () {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CircleAvatar(
                            radius: 120,
                            backgroundColor: Colors.white,
                            child: Text(
                              studentController.getSchool.name[0],
                              style: const TextStyle(
                                fontSize: 50,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            studentController.getSchool.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: theme.typography.title,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            studentController.getSchool.address,
                            textAlign: TextAlign.center,
                            style: theme.typography.bodyLarge,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: const Icon(FluentIcons.edit, size: 24.0),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => EditSchoolDialog(
                                    school: studentController.getSchool),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Flexible(
                  flex: 2,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 64.0),
                          child: DropDownButton(
                            items: [
                              MenuFlyoutItem(
                                text: const Text("Info"),
                                onPressed: () {
                                  setState(() {
                                    isInfoPage = true;
                                  });
                                },
                              ),
                              MenuFlyoutItem(
                                text: const Text("Staff"),
                                onPressed: () {
                                  setState(() {
                                    isInfoPage = false;
                                  });
                                },
                              ),
                            ],
                            leading: const Icon(
                              FluentIcons.badge,
                            ),
                            title:
                                Text(isInfoPage ? "Info Page" : "Staff Page"),
                          ),
                        ),
                        isInfoPage
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Classes",
                                                  style: theme
                                                      .typography.bodyLarge,
                                                ),
                                                ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: studentController
                                                        .getSchool
                                                        .classes
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Text(
                                                        studentController
                                                            .getSchool
                                                            .classes[index],
                                                        textAlign:
                                                            TextAlign.center,
                                                      );
                                                    }),
                                              ],
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Divider(),
                                          ),
                                          Flexible(
                                            flex: 1,
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Sections",
                                                  style: theme
                                                      .typography.bodyLarge,
                                                ),
                                                ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: studentController
                                                        .getSchool
                                                        .sections
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Text(
                                                        studentController
                                                            .getSchool
                                                            .sections[index],
                                                        textAlign:
                                                            TextAlign.center,
                                                      );
                                                    }),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // child: Text("Hey"),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Divider(),
                                    ),
                                    Text(
                                      "E Mail:- ${studentController.getSchool.email}",
                                      style: theme.typography.bodyLarge,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Divider(),
                                    ),
                                    Text(
                                      "Phone:- ${studentController.getSchool.contact}",
                                      style: theme.typography.bodyLarge,
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Container(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Card(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Admins",
                                                    style: theme
                                                        .typography.bodyLarge,
                                                  ),
                                                  TextButton(
                                                    child:
                                                        const Text("Add Admin"),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AddSchoolAdmin(
                                                                schoolId: widget
                                                                    .schoolId),
                                                      );
                                                    },
                                                  ),
                                                  ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          studentController
                                                              .getAdmins.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                color: theme
                                                                    .accentColor,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    studentController
                                                                        .getAdmins[
                                                                            index]
                                                                        .name,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: theme
                                                                        .typography
                                                                        .bodyLarge,
                                                                  ),
                                                                  Text(
                                                                    studentController
                                                                        .getAdmins[
                                                                            index]
                                                                        .email,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: theme
                                                                        .typography
                                                                        .body,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Divider(),
                                          ),
                                          Flexible(
                                            flex: 1,
                                            child: Card(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Teachers",
                                                    style: theme
                                                        .typography.bodyLarge,
                                                  ),
                                                  TextButton(
                                                    child: const Text(
                                                        "Add Teacher"),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AddSchoolTeacher(
                                                                schoolId: widget
                                                                    .schoolId),
                                                      );
                                                    },
                                                  ),
                                                  ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          studentController
                                                              .getTeachers
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                color: theme
                                                                    .accentColor,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    studentController
                                                                        .getTeachers[
                                                                            index]
                                                                        .name,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: theme
                                                                        .typography
                                                                        .bodyLarge,
                                                                  ),
                                                                  Text(
                                                                    "${studentController.getTeachers[index].teacherClass} - ${studentController.getTeachers[index].section}",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: theme
                                                                        .typography
                                                                        .body,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // child: Text("Hey"),
                                    ),
                                  ],
                                ),
                              )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}