import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';
import 'package:idcard_maker_frontend/services/logger.dart';
import 'package:idcard_maker_frontend/widgets/dialog/edit_admin.dart';
import 'package:idcard_maker_frontend/widgets/dialog/edit_teacher.dart';

import '../../widgets/add_school_admin.dart';
import '../../widgets/add_school_teacher.dart';
import '../../widgets/dialog/confirm_delete.dart';
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

  void deleteSchoolAdmin(String adminId) {
    studentController.deleteSchoolAdmin(adminId, widget.schoolId);
  }

  void deleteSchoolTeacher(String adminId) {
    studentController.deleteSchoolTeacher(adminId, widget.schoolId);
  }

  @override
  Widget build(BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);
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
                              studentController.getSchool.name[0].toUpperCase(),
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
                            studentController.getSchool.address.toUpperCase(),
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
                                                            .classes[index]
                                                            .toUpperCase(),
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
                                                            .sections[index]
                                                            .toUpperCase(),
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
                                      "E Mail:- ${studentController.getSchool.email.toUpperCase()}",
                                      style: theme.typography.bodyLarge,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Divider(),
                                    ),
                                    Text(
                                      "Phone:- ${studentController.getSchool.contact.toUpperCase()}",
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
                                                    "ADMINS",
                                                    style: theme
                                                        .typography.bodyLarge,
                                                  ),
                                                  Button(
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
                                                                  .all(18.0),
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
                                                                          .all(
                                                                      14.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween, // Aligns items at start and end
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start, // Aligns column items at start
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        studentController
                                                                            .getAdmins[index]
                                                                            .name
                                                                            .toUpperCase(),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: theme
                                                                            .typography
                                                                            .bodyLarge,
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        studentController
                                                                            .getAdmins[index]
                                                                            .contact
                                                                            .toUpperCase(),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: theme
                                                                            .typography
                                                                            .body,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          logger.d(studentController
                                                                              .getAdmins[index]
                                                                              .id);
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder: (context) =>
                                                                                EditAdmin(
                                                                              adminId: studentController.getAdmins[index].id,
                                                                              schoolId: studentController.getAdmins[index].school,
                                                                            ),
                                                                          );
                                                                        },
                                                                        icon:
                                                                            const Icon(
                                                                          FluentIcons
                                                                              .edit,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return ConfirmDelete(
                                                                                  type: "Admin",
                                                                                  name: studentController.getAdmins[index].name.toUpperCase(),
                                                                                  deleteDialogueFunction: () {
                                                                                    deleteSchoolAdmin(studentController.getAdmins[index].id);
                                                                                  },
                                                                                  deletePhoto: false,
                                                                                );
                                                                              });
                                                                        },
                                                                        icon:
                                                                            const Icon(
                                                                          FluentIcons
                                                                              .delete,
                                                                          color:
                                                                              Color(0xffec404f),
                                                                          size:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    ],
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
                                                    "TEACHERS",
                                                    style: theme
                                                        .typography.bodyLarge,
                                                  ),
                                                  Button(
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
                                                                  .all(18.0),
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
                                                                          .all(
                                                                      14.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween, // Aligns items at start and end
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start, // Aligns column items at start
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        studentController
                                                                            .getTeachers[index]
                                                                            .name
                                                                            .toUpperCase(),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: theme
                                                                            .typography
                                                                            .bodyLarge,
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        "${studentController.getTeachers[index].teacherClass.toUpperCase()} - ${studentController.getTeachers[index].section.toUpperCase()}",
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: theme
                                                                            .typography
                                                                            .body,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          logger.d(studentController
                                                                              .getTeachers[index]
                                                                              .id);
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder: (context) =>
                                                                                EditTeacher(
                                                                              teacherId: studentController.getTeachers[index].id,
                                                                              schoolId: studentController.getTeachers[index].currentSchool,
                                                                            ),
                                                                          );
                                                                        },
                                                                        icon:
                                                                            const Icon(
                                                                          FluentIcons
                                                                              .edit,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return ConfirmDelete(
                                                                                  type: "Teacher",
                                                                                  name: studentController.getTeachers[index].name.toUpperCase(),
                                                                                  deleteDialogueFunction: () {
                                                                                    deleteSchoolTeacher(studentController.getTeachers[index].id);
                                                                                  },
                                                                                  deletePhoto: false,
                                                                                );
                                                                              });
                                                                        },
                                                                        icon:
                                                                            const Icon(
                                                                          FluentIcons
                                                                              .delete,
                                                                          color:
                                                                              Color(0xffec404f),
                                                                          size:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    ],
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
