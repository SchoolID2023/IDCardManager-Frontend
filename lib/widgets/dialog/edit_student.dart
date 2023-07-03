import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';

import '../../models/schools_model.dart';
import '../../models/student_model.dart';
import 'package:flutter/material.dart';

class EditStudent extends StatefulWidget {
  final String studentId;
  final String schoolId;
  const EditStudent({Key? key, required this.studentId, required this.schoolId})
      : super(key: key);

  @override
  State<EditStudent> createState() => _EditStudentState();
}

class _EditStudentState extends State<EditStudent> {
  bool isLoading = true;
  late Student student;
  late Student editingStudent;
  late StudentController _studentController;
  List<String> classOptions = [];
  List<String> sectionOptions = [];
  late School schoolData;

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

    student = _studentController.getStudentById(widget.studentId);
    editingStudent = Student.fromJson(student.toJson());
    () async {
      await _studentController.fetchSchool(widget.schoolId);
      schoolData = _studentController.school.value;
      setState(() {
        classOptions = schoolData.classes;
        sectionOptions = schoolData.sections;
        isLoading = false;
      });
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
              "Edit Student",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: editingStudent.data.length + 5,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return buildTextBox(
                          "Name",
                          editingStudent.name,
                          (value) {
                            editingStudent.name = value;
                          },
                        );
                      } else if (index == 1) {
                        return buildTextBox(
                          "Contact",
                          editingStudent.contact,
                          (value) {
                            editingStudent.contact = value;
                          },
                        );
                      } else if (index == 2) {
                        return buildDropdown(
                          "Class",
                          editingStudent.studentClass,
                          (value) {
                            setState(() {
                              editingStudent.studentClass =
                                  value!.isNotEmpty ? value : '';
                            });
                          },
                          classOptions,
                        );
                      } else if (index == 3) {
                        return buildDropdown(
                          "Section",
                          editingStudent.section,
                          (value) {
                            setState(() {
                              editingStudent.section =
                                  value!.isNotEmpty ? value : '';
                            });
                          },
                          sectionOptions,
                        );
                      } else if (index == 4) {
                        return buildTextBox(
                          "Admn. No.",
                          editingStudent.admno,
                          (value) {
                            editingStudent.admno = value;
                          },
                        );
                      } else {
                        final dataIndex = index - 5;
                        final data = editingStudent.data[dataIndex];
                        if (ignoredPlaceholders.contains(data.field)) {
                          return const SizedBox.shrink();
                        }
                        return buildTextBox(
                          data.field,
                          data.value.toString(),
                          (value) {
                            editingStudent.data[dataIndex].value = value;
                          },
                        );
                      }
                    },
                  ),
            const SizedBox(height: 16.0),
            Row(
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
                    _studentController.editStudent(editingStudent);
                  },
                  child: const Text("Save"),
                ),
              ],
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
    return DropdownButtonFormField<String>(
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
    );
  }

  Widget buildTextBox(
    String placeholder,
    String value,
    Function(String) onChanged,
  ) {
    final textEditingController = TextEditingController(text: value);
    // final selection = TextSelection.fromPosition(
    //   TextPosition(offset: textEditingController.text.length),
    // );

    return TextFormField(
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
      // onTap: () {
      //   textEditingController.selection = selection;
      // },
    );
  }
}
