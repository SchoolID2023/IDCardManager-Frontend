import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/widgets/edit_school.dart';
import 'package:idcard_maker_frontend/widgets/generate_id_card_list.dart';
import 'package:idcard_maker_frontend/widgets/dialog/load_excel.dart';
import 'package:idcard_maker_frontend/widgets/load_photos.dart';
import 'package:idcard_maker_frontend/widgets/student_table.dart';
import 'package:idcard_maker_frontend/widgets/titlebar/navigation_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/student_controller.dart';
import '../models/id_card_model.dart';
import '../models/schools_model.dart';
import '../services/remote_services.dart';
import '../widgets/add_school_admin.dart';
import '../widgets/add_school_teacher.dart';
import '../widgets/dialog/load_id_card_data.dart';
import '../services/logger.dart';
import 'edit_id_card.dart';
import 'school_admin_login.dart';

class StudentDataScreen extends StatelessWidget {
  final String schoolId;
  final Map<String, bool> _selectedStudents = {};
  final _scrollController = ScrollController();
  final RemoteServices _remoteServices = RemoteServices();
  bool isSchoolAdmin = false;

  final List<String> _photos = ["Name", "Class", "Section", "Contact"];
  final List<Label> _labels = [
    Label(title: "Name"),
    Label(title: "Class"),
    Label(title: "Section"),
    Label(
      title: "Contact",
    ),
  ];

  StudentDataScreen(
      {Key? key, required this.schoolId, this.isSchoolAdmin = false})
      : super(key: key);

  void updateSelectedStudents(String studentId, bool isSelected) {
    _selectedStudents[studentId] = isSelected;
  }

  @override
  Widget build(BuildContext context) {
    logger.d("Screen-> ${schoolId}");
    final StudentController studentController =
        Get.put(StudentController(schoolId));
    // final SchoolController schoolController = Get.put(SchoolController());

    studentController.fetchIdCardList(schoolId);
    studentController.fetchStudents(schoolId);
    studentController.fetchAdmins(schoolId);
    studentController.fetchSchool(schoolId);
    studentController.fetchTeachers(schoolId);

    for (var student in studentController.students.value.students) {
      _selectedStudents[student.id] = false;
    }

    double cwidth = MediaQuery.of(context).size.width;
    double cheight = MediaQuery.of(context).size.height;

    return NavigationView(
      appBar: customNavigationAppBar("School Info", context),
      content: ScaffoldPage(
          header: Row(
            children: [
              Obx(() => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      studentController.school.value.name,
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.blue,
                      ),
                    ),
                  )),
              isSchoolAdmin
                  ? Button(
                      child: const Icon(FluentIcons.power_button),
                      onPressed: () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.remove('token');
                        Navigator.of(context).push(FluentPageRoute(
                            builder: (context) =>
                                const SchoolAdminLoginPage()));
                      },
                    )
                  : Container(),
            ],
          ),
          content: Obx(() {
            School school = studentController.school.value;
            var idCards = studentController.idCardList.value.idCards;
            var students = studentController.students.value.students;
            var admins = studentController.admins.value.schoolAdmins;
            var teachers = studentController.teachers.value.teachers;
            return studentController.isLoading.value
                ? const Center(
                    child: ProgressBar(),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: cwidth,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              width: cwidth * (0.2),
                                              // height: 200,
                                              child: Card(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Text(
                                                          "School Details",
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) =>
                                                                  EditSchoolDialog(
                                                                      school:
                                                                          school),
                                                            );
                                                          },
                                                          icon: const Icon(
                                                            FluentIcons.edit,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Text(
                                                      "School Name: ${school.name}",
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const Divider(),
                                                    Text(
                                                      "School Address: ${school.address}",
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const Divider(),
                                                    Text(
                                                      "School Classes: ${school.classes}",
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const Divider(),
                                                    Text(
                                                      "School Contact: ${school.contact}",
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const Divider(),
                                                    Text(
                                                      "School Email: ${school.email}",
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const Divider(),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Button(
                                                            child: const Text(
                                                                "Upload Excel"),
                                                            onPressed: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        LoadExcel(
                                                                  schoolId:
                                                                      schoolId,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          Button(
                                                            child: const Text(
                                                                "Upload Photos"),
                                                            onPressed: () {
                                                              for (var data
                                                                  in students[0]
                                                                      .data) {
                                                                _photos.add(
                                                                    data.field);
                                                              }
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        LoadPhotos(
                                                                  schoolId:
                                                                      schoolId,
                                                                  fields:
                                                                      _photos,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              width: cwidth * (0.2),
                                              // height: 200,
                                              child: Card(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Download Student Data",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Button(
                                                      child: const Text(
                                                          "Download"),
                                                      onPressed: () {
                                                        _remoteServices
                                                            .generateExcel(
                                                          schoolId,
                                                          'all',
                                                          'all',
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              width: cwidth * (0.2),
                                              // height: 200,
                                              child: Card(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Download Student Photos",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    students.isNotEmpty &&
                                                            students[0]
                                                                .photo
                                                                .isNotEmpty
                                                        ? DropDownButton(
                                                            title: const Text(
                                                                'Select Photo Column'),
                                                            items: List<
                                                                MenuFlyoutItem>.generate(
                                                              students[0]
                                                                  .photo
                                                                  .length,
                                                              (index) =>
                                                                  MenuFlyoutItem(
                                                                text: Text(
                                                                    students[0]
                                                                        .photo[
                                                                            index]
                                                                        .field),
                                                                onPressed: () {
                                                                  _remoteServices
                                                                      .downloadPhotos(
                                                                    schoolId,
                                                                    'all',
                                                                    'all',
                                                                    students[0]
                                                                        .photo[
                                                                            index]
                                                                        .field,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    // Button(
                                                    //   child: Text("Download"),
                                                    //   onPressed: () {
                                                    //     _remoteServices
                                                    //         .downloadPhotos(
                                                    //       schoolId,
                                                    //       'all',
                                                    //       'all',
                                                    //     );
                                                    //   },
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "ID Cards Designs of ${school.name}",
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontWeight: mat.FontWeight.bold),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          height: 210,
                                          child: Scrollbar(
                                            controller: _scrollController,
                                            child: ListView.builder(
                                              controller: _scrollController,
                                              shrinkWrap: true,
                                              itemBuilder: ((context, index) {
                                                if (index == idCards.length) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        for (int i = 0;
                                                            i <
                                                                (students[0]
                                                                        .data)
                                                                    .length;
                                                            i++) {
                                                          if (students[0]
                                                                  .data[i]
                                                                  .field[0] ==
                                                              '_') {
                                                            continue;
                                                          }
                                                          _labels.add(
                                                            Label(
                                                                title:
                                                                    students[0]
                                                                        .data[i]
                                                                        .field),
                                                          );
                                                        }
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              LoadIdCardData(
                                                            schoolId: schoolId,
                                                            labels: _labels,
                                                          ),
                                                        );
                                                      },
                                                      child: const SizedBox(
                                                        height: 200,
                                                        width: 200,
                                                        child: Card(
                                                          child: Icon(
                                                              FluentIcons.add),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return ContentDialog(
                                                              backgroundDismiss:
                                                                  true,
                                                              content: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Button(
                                                                    child: const Text(
                                                                        "Generate ID Card"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pushReplacement(
                                                                        FluentPageRoute(
                                                                          builder: (context) =>
                                                                              GenerateIdCardList(
                                                                            idCardId:
                                                                                idCards[index].id,
                                                                            students:
                                                                                students,
                                                                            isSelected:
                                                                                _selectedStudents,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                  Button(
                                                                      child: const Text(
                                                                          "Edit Id Card"),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context).pushReplacement(FluentPageRoute(
                                                                            builder: (context) => EditIdCardPage(
                                                                                  idCardId: idCards[index].id,
                                                                                )));
                                                                      }),
                                                                  Button(
                                                                      child: const Text(
                                                                          "Delete"),
                                                                      onPressed:
                                                                          () {
                                                                        studentController
                                                                            .deleteIdCard(
                                                                          idCards[index]
                                                                              .id,
                                                                        );
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      }),
                                                                  Button(
                                                                      child: const Text(
                                                                          "Cancel"),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      })
                                                                ],
                                                              ),
                                                            );
                                                          });
                                                    },
                                                    child: Card(
                                                      child: Image.memory(
                                                        base64Decode(
                                                          idCards[index]
                                                              .foregroundImagePath,
                                                        ),
                                                        height: 200,
                                                        width: 200,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                              itemCount: idCards.length + 1,
                                              scrollDirection: Axis.horizontal,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // SizedBox(
                                      //   width: cwidth,
                                      //   height: 800,
                                      //   child: students.isNotEmpty
                                      //       ? InteractiveViewer(
                                      //           scaleEnabled: false,
                                      //           constrained: false,
                                      //           child: StudentTable(
                                      //             students: students,
                                      //             isSelected: _selectedStudents,
                                      //             onSelected:
                                      //                 updateSelectedStudents,
                                      //             classes: school.classes,
                                      //             sections: school.sections,
                                      //             schoolId: schoolId,
                                      //           ),
                                      //         )
                                      //       : const Text("No Students"),
                                      // ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      width: cwidth * 0.2,
                                      height: cheight * 0.5,
                                      child: Card(
                                        child: Column(
                                          children: [
                                            const Text("Manage Admins"),
                                            TextButton(
                                              child: const Text("Add Admin"),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AddSchoolAdmin(
                                                          schoolId: schoolId),
                                                );
                                              },
                                            ),
                                            Expanded(
                                              child: ListView.builder(
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title: Text(
                                                      admins[index].name,
                                                    ),
                                                    subtitle: Text(
                                                      admins[index].email,
                                                    ),
                                                  );
                                                },
                                                itemCount: admins.length,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    SizedBox(
                                      width: cwidth * 0.2,
                                      height: cheight * 0.5,
                                      child: Card(
                                        child: Column(
                                          children: [
                                            const Text("Manage Teachers"),
                                            TextButton(
                                              child: const Text("Add Teacher"),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AddSchoolTeacher(
                                                          schoolId: schoolId),
                                                );
                                              },
                                            ),
                                            Expanded(
                                              child: ListView.builder(
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title: Text(
                                                      teachers[index].name,
                                                    ),
                                                    subtitle: Text(
                                                      "${teachers[index].teacherClass} - ${teachers[index].section}",
                                                    ),
                                                  );
                                                },
                                                itemCount: teachers.length,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
          })),
    );
  }
}
