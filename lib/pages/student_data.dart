import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/school_controller.dart';
import 'package:idcard_maker_frontend/models/student_model.dart';
import 'package:idcard_maker_frontend/widgets/edit_school.dart';
import 'package:idcard_maker_frontend/widgets/generate_id_card_list.dart';
import 'package:idcard_maker_frontend/widgets/load_excel.dart';
import 'package:idcard_maker_frontend/widgets/load_photos.dart';
import 'package:idcard_maker_frontend/widgets/student_table.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/student_controller.dart';
import '../models/id_card_model.dart';
import '../models/schools_model.dart';
import '../services/remote_services.dart';
import '../widgets/add_school_admin.dart';
import '../widgets/add_school_teacher.dart';
import '../widgets/load_id_card_data.dart';
import '../widgets/preview_id_card.dart';
import '../services/logger.dart';
import 'edit_id_card.dart';
import 'school_admin_login.dart';

class StudentDataScreen extends StatelessWidget {
  final String schoolId;
  final Map<String, bool> _selectedStudents = {};
  final _scrollController = ScrollController();
  final RemoteServices _remoteServices = RemoteServices();
  bool isSchoolAdmin = false;

  List<String> _photos = ["Name", "Class", "Section", "Contact"];
  List<Label> _labels = [
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

    return ScaffoldPage(
        header: Row(
          children: [
            isSchoolAdmin
                ? Container()
                : Button(
                    child: Icon(FluentIcons.arrow_tall_up_left),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
            Obx(() => Text(
                  studentController.school.value.name,
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.blue,
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
                          builder: (context) => SchoolAdminLoginPage()));
                    },
                  )
                : Container(),
          ],
        ),
        content: Obx(() {
          School _school = studentController.school.value;
          var _idCards = studentController.idCardList.value.idCards;
          var _students = studentController.students.value.students;
          var _admins = studentController.admins.value.schoolAdmins;
          var _teachers = studentController.teachers.value.teachers;
          return studentController.isLoading.value
              ? Center(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                      Text(
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
                                                                        _school),
                                                          );
                                                        },
                                                        icon: Icon(
                                                          FluentIcons.edit,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Text(
                                                    "School Name: ${_school.name}",
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Divider(),
                                                  Text(
                                                    "School Address: ${_school.address}",
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Divider(),
                                                  Text(
                                                    "School Classes: ${_school.classes}",
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Divider(),
                                                  Text(
                                                    "School Contact: ${_school.contact}",
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Divider(),
                                                  Text(
                                                    "School Email: ${_school.email}",
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Divider(),
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
                                                          child: Text(
                                                              "Upload Excel"),
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
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
                                                          child: Text(
                                                              "Upload Photos"),
                                                          onPressed: () {
                                                            _students[0]
                                                                .data
                                                                .forEach(
                                                                    (data) {
                                                              _photos.add(
                                                                  data.field);
                                                            });
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                      LoadPhotos(
                                                                schoolId:
                                                                    schoolId,
                                                                fields: _photos,
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
                                                    child: Text("Download"),
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
                                                  _students.length > 0 &&
                                                          _students[0]
                                                                  .photo
                                                                  .length >
                                                              0
                                                      ? DropDownButton(
                                                          title: Text(
                                                              'Select Photo Column'),
                                                          items: List<
                                                              MenuFlyoutItem>.generate(
                                                            _students[0]
                                                                .photo
                                                                .length,
                                                            (index) =>
                                                                MenuFlyoutItem(
                                                              text: Text(
                                                                  _students[0]
                                                                      .photo[
                                                                          index]
                                                                      .field),
                                                              onPressed: () {
                                                                _remoteServices
                                                                    .downloadPhotos(
                                                                  schoolId,
                                                                  'all',
                                                                  'all',
                                                                  _students[0]
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
                                      "ID Cards Designs of ${_school.name}",
                                      style: TextStyle(
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
                                              if (index == _idCards.length) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      for (int i = 0;
                                                          i <
                                                              (_students[0]
                                                                      .data)
                                                                  .length;
                                                          i++) {
                                                        if (_students[0]
                                                                .data[i]
                                                                .field[0] ==
                                                            '_') {
                                                          continue;
                                                        }
                                                        _labels.add(
                                                          Label(
                                                              title:
                                                                  _students[0]
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
                                                    child: SizedBox(
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
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Button(
                                                                  child: Text(
                                                                      "Generate ID Card"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pushReplacement(
                                                                      FluentPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                GenerateIdCardList(
                                                                          idCardId:
                                                                              _idCards[index].id,
                                                                          students:
                                                                              _students,
                                                                          isSelected:
                                                                              _selectedStudents,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                                Button(
                                                                    child: Text(
                                                                        "Edit Id Card"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(context).pushReplacement(FluentPageRoute(
                                                                          builder: (context) => EditIdCardPage(
                                                                                idCardId: _idCards[index].id,
                                                                              )));
                                                                    }),
                                                                Button(
                                                                    child: Text(
                                                                        "Delete"),
                                                                    onPressed:
                                                                        () {
                                                                      studentController
                                                                          .deleteIdCard(
                                                                        _idCards[index]
                                                                            .id,
                                                                      );
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    }),
                                                                // Button(
                                                                //   child: Text(
                                                                //       "Edit"),
                                                                //   onPressed:
                                                                //       () {},
                                                                // ),
                                                              ],
                                                            ),
                                                          );
                                                        });
                                                  },
                                                  child: Card(
                                                    child: Image.memory(
                                                      base64Decode(
                                                        _idCards[index]
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
                                            itemCount: _idCards.length + 1,
                                            scrollDirection: Axis.horizontal,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: cwidth,
                                      height: 800,
                                      child: _students.isNotEmpty
                                          ? InteractiveViewer(
                                              scaleEnabled: false,
                                              constrained: false,
                                              child: StudentTable(
                                                students: _students,
                                                isSelected: _selectedStudents,
                                                onSelected:
                                                    updateSelectedStudents,
                                                classes: _school.classes,
                                                sections: _school.sections,
                                              ),
                                            )
                                          : const Text("No Students"),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: cwidth * 0.2,
                                    height: cheight * 0.5,
                                    child: Card(
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Text("Manage Admins"),
                                            TextButton(
                                              child: Text("Add Admin"),
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
                                                      _admins[index].name,
                                                    ),
                                                    subtitle: Text(
                                                      _admins[index].email,
                                                    ),
                                                  );
                                                },
                                                itemCount: _admins.length,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  SizedBox(
                                    width: cwidth * 0.2,
                                    height: cheight * 0.5,
                                    child: Card(
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Text("Manage Teachers"),
                                            TextButton(
                                              child: Text("Add Teacher"),
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
                                                      _teachers[index].name,
                                                    ),
                                                    subtitle: Text(
                                                      "${_teachers[index].teacherClass} - ${_teachers[index].section}",
                                                    ),
                                                  );
                                                },
                                                itemCount: _teachers.length,
                                              ),
                                            )
                                          ],
                                        ),
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
        }));
  }
}
