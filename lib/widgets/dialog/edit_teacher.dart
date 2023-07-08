import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';
import '../../models/teacher_list_model.dart';
import '../../models/schools_model.dart';
import 'package:flutter/material.dart';

class EditTeacher extends StatefulWidget {
  final String teacherId;
  final String schoolId;
  const EditTeacher({Key? key, required this.teacherId, required this.schoolId})
      : super(key: key);

  @override
  State<EditTeacher> createState() => _EditTeacherState();
}

class _EditTeacherState extends State<EditTeacher> {
  bool isLoading = true;
  late Teacher teacher;
  late Teacher editingTeacher;
  late StudentController _studentController;
  late School schoolData;
  late List<String> classOptions;
  late List<String> sectionOptions;

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

    teacher = _studentController.getTeacherById(widget.teacherId);
    editingTeacher = Teacher.fromJson(teacher.toJson());
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(30.0),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Teacher",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return buildTextBox(
                                  "Name",
                                  editingTeacher.name,
                                  (value) {
                                    editingTeacher.name = value;
                                  },
                                );
                              }
                              if (index == 1) {
                                return buildTextBox(
                                  "Contact",
                                  editingTeacher.contact,
                                  (value) {
                                    editingTeacher.contact = value;
                                  },
                                );
                              }

                              if (index == 2) {
                                return buildDropdown(
                                  "Class",
                                  editingTeacher.teacherClass,
                                  (value) {
                                    setState(() {
                                      editingTeacher.teacherClass =
                                          value!.isNotEmpty ? value : '';
                                    });
                                  },
                                  classOptions,
                                );
                              }

                              if (index == 3) {
                                return buildDropdown(
                                  "Section",
                                  editingTeacher.section,
                                  (value) {
                                    setState(() {
                                      editingTeacher.section =
                                          value!.isNotEmpty ? value : '';
                                    });
                                  },
                                  sectionOptions,
                                );
                              }
                              return null;
                            },
                          ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _studentController.editSchoolTeacher(editingTeacher);
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget buildTextBox(
    String placeholder,
    String value,
    Function(String) onChanged,
  ) {
    final textEditingController = TextEditingController(text: value);

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: placeholder,
        ),
        controller: textEditingController,
        onChanged: onChanged,
        autofocus: false,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        cursorWidth: 2.0,
        cursorRadius: const Radius.circular(2.0),
        enableInteractiveSelection: true,
      ),
    );
  }
}
