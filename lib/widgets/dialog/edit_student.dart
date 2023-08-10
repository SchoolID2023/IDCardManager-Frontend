import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';

import '../../models/schools_model.dart';
import '../../models/student_model.dart';
import 'package:flutter/material.dart';

import '../../services/logger.dart';

class EditStudent extends StatefulWidget {
  final String studentId;
  final String schoolId;

  final List<String> labels;
  const EditStudent(
      {Key? key,
      required this.studentId,
      required this.schoolId,
      required this.labels})
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
    // () async {
    // await _studentController.fetchSchool(widget.schoolId);
    schoolData = _studentController.school.value;
    setState(() {
      classOptions = schoolData.classes;
      sectionOptions = schoolData.sections;
      isLoading = false;
    });

    // }();
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
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.labels.length + 5,
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
                                if (editingStudent.data.isNotEmpty &&
                                    dataIndex < editingStudent.data.length) {
                                  final data = editingStudent.data[dataIndex];
                                  final dataIndexFound = widget.labels
                                      .indexWhere(
                                          (label) => label == data.field);

                                  if (dataIndexFound != -1 &&
                                      !ignoredPlaceholders.contains(
                                          widget.labels[dataIndexFound])) {
                                    final value = data.value.toString();
                                    final labelName =
                                        editingStudent.data[dataIndex].field;
                                    if (labelName.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return buildTextBox(
                                      labelName,
                                      value,
                                      (newValue) {
                                        editingStudent.data[dataIndex].value =
                                            newValue;
                                      },
                                    );
                                  }
                                } else {
                                  final extraIndex = dataIndex;
                                  if (extraIndex >= 0 &&
                                      extraIndex < widget.labels.length) {
                                    final label = widget.labels[extraIndex];
                                    if (!ignoredPlaceholders.contains(label) &&
                                        ![
                                          "name",
                                          "contact",
                                          "class",
                                          "section",
                                          "admno"
                                        ].contains(label)) {
                                      return buildTextBox(
                                        label,
                                        '',
                                        (newValue) {
                                          editingStudent.data.add(Datum(
                                              field: label, value: newValue));
                                        },
                                      );
                                    }
                                  }
                                }
                              }
                              return const SizedBox.shrink();
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
                      _studentController.editStudent(editingStudent);
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
