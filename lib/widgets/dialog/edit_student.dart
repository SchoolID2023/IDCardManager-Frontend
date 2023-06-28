import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';

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
  late Student editingStudent; // New

  late StudentController _studentController;

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
    editingStudent = Student.fromJson(student.toJson()); // Initialize editingStudent with a copy of student
    isLoading = false;
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
                    itemCount: editingStudent.data.length + 4,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return buildTextBox(
                          "Name",
                          editingStudent
                              .name, // Use editingStudent instead of student
                          (value) { 
                              editingStudent.name =
                                  value; // Update editingStudent instead of student 
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
                        return buildTextBox(
                          "Class",
                          editingStudent.studentClass,
                          (value) { 
                              editingStudent.studentClass = value; 
                          },
                        );
                      } else if (index == 3) {
                        return buildTextBox(
                          "Section",
                          editingStudent.section,
                          (value) { 
                              editingStudent.section = value; 
                          },
                        );
                      } else {
                        final dataIndex = index - 4;
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
                    _studentController.editStudent(
                        editingStudent); // Apply the changes from editingStudent to student
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

  Widget buildTextBox(
    String placeholder,
    String value,
    Function(String) onChanged,
  ) {
    final textEditingController = TextEditingController(text: value);
    final selection = TextSelection.fromPosition(
      TextPosition(offset: textEditingController.text.length),
    );

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
      onTap: () {
        textEditingController.selection = selection;
      },
    );
  }
}
