import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/services/remote_services.dart';

import '../controllers/student_controller.dart';
import '../models/schools_model.dart';

class AddSchoolTeacher extends StatefulWidget {
  final String schoolId;
  const AddSchoolTeacher({Key? key, required this.schoolId}) : super(key: key);

  @override
  State<AddSchoolTeacher> createState() => _AddSchoolTeacherState();
}

class _AddSchoolTeacherState extends State<AddSchoolTeacher> {
  final RemoteServices _remoteServices = RemoteServices();
  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _teacherContactController =
      TextEditingController();
  final TextEditingController _teacherClassController = TextEditingController();
  final TextEditingController _teacherSectionController =
      TextEditingController();

  bool isLoading = true;
  late StudentController _studentController;
  late School schoolData;
  late List<String> classOptions = [];
  late List<String> sectionOptions = [];

  Set<String> ignoredPlaceholders = {
    "_id",
    "__v",
    "id",
    "currentSchool",
    "idCard",
    "otp",
    "password",
  };

  @override
  void initState() {
    super.initState();
    _studentController = Get.put(StudentController(widget.schoolId));
    () async {
      await _studentController.fetchSchool(widget.schoolId);
      schoolData = _studentController.school.value;
      setState(() {
        classOptions = schoolData.classes;
        sectionOptions = schoolData.sections;
      });

      isLoading = false;
    }();
  }

  Widget buildDropdown(
    String placeholder,
    String? value,
    void Function(String?)? onChanged,
    List<String> options,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: placeholder,
        ),
        dropdownColor: Theme.of(context).cardColor,
        value: value,
        onChanged: onChanged,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final StudentController studentController =
    //     Get.put(StudentController(widget.schoolId));
    return Material(
      child: ContentDialog(
        title: const Text("Add Teacher"),
        actions: [
          Button(
            child: const Text("Add"),
            onPressed: () async {
              try {
                await _remoteServices.addSchoolTeacher(
                  schoolId: widget.schoolId,
                  name: _teacherNameController.text,
                  contact: _teacherContactController.text,
                  className: _teacherClassController.text,
                  section: _teacherSectionController.text,
                );
              } catch (e) {
                print('there was an issue');
                print(e);
              }

              await _studentController.fetchTeachers(widget.schoolId);
              Navigator.pop(context);
            },
          ),
          Button(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        content: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                width: 400,
                child: Column(
                  children: [
                    TextBox(
                      controller: _teacherNameController,
                      placeholder: "Teacher Name",
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextBox(
                      controller: _teacherContactController,
                      placeholder: "Teacher Contact",
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    buildDropdown(
                      "Teacher Class",
                      _teacherClassController.text,
                      (value) {
                        setState(() {
                          _teacherClassController.text =
                              value!.isNotEmpty ? value : '';
                        });
                      },
                      classOptions,
                    ),
                    // TextBox(
                    //   controller: _teacherClassController,
                    //   placeholder: "Teacher Class",
                    // ),
                    const SizedBox(
                      height: 20,
                    ),

                    buildDropdown(
                      "Teacher Section",
                      _teacherSectionController.text,
                      (value) {
                        setState(() {
                          _teacherSectionController.text =
                              value!.isNotEmpty ? value : '';
                        });
                      },
                      sectionOptions,
                    ),
                    // TextBox(
                    //   controller: _teacherSectionController,
                    //   placeholder: "Teacher Section",
                    // ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
