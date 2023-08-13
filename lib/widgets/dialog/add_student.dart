import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/student_controller.dart';
import '../../models/schools_model.dart';

class AddStudent extends StatefulWidget {
  final List<String> labels;
  final String currentSchool;

  const AddStudent(
      {Key? key, required this.labels, required this.currentSchool})
      : super(key: key);

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  Map<String, String> studentDetails = {};
  late StudentController studentController;
  List<String> classOptions = [];
  List<String> sectionOptions = [];
  late School schoolData;

  final Set<String> _rejectedLabels = {
    "_id",
    "id",
    "otp",
    "currentSchool",
    "__v",
    "idCard",
    "createdat",
    "updatedat",
  };

  @override
  void initState() {
    super.initState();
    studentController = Get.put(StudentController(widget.currentSchool));
    studentDetails["currentSchool"] = widget.currentSchool;
    // () async {
    // await studentController.fetchSchool(widget.currentSchool);
    schoolData = studentController.school.value;
    setState(() {
      classOptions = schoolData.classes;
      sectionOptions = schoolData.sections;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add Student",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: widget.labels.length,
                itemBuilder: (context, index) {
                  if (widget.labels[index].toLowerCase() == 'class') {
                    return buildDropdown(
                      widget.labels[index].toUpperCase(),
                      studentDetails[widget.labels[index]],
                      (value) {
                        // setState(() {
                        studentDetails[widget.labels[index]] =
                            value!.isNotEmpty ? value : '';
                        // });
                      },
                      classOptions,
                    );
                  }
                  if (widget.labels[index].toLowerCase() == 'section') {
                    return buildDropdown(
                      widget.labels[index].toUpperCase(),
                      studentDetails[widget.labels[index]],
                      (value) {
                        // setState(() {
                        studentDetails[widget.labels[index]] =
                            value!.isNotEmpty ? value : '';
                        // });
                      },
                      sectionOptions,
                    );
                  }

                  if (_rejectedLabels
                      .contains(widget.labels[index].toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  return buildTextField(
                    widget.labels[index].toUpperCase(),
                    studentDetails[widget.labels[index]] == null
                        ? ''
                        : studentDetails[widget.labels[index]].toString(),
                    (value) {
                      studentDetails[widget.labels[index]] = value;
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 28.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color?>(
                      Theme.of(context).cardColor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(studentDetails);
                    studentController.addStudent(studentDetails);
                  },
                  child: const Text("Add Student"),
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

  Widget buildTextField(
    String placeholder,
    String value,
    Function(String) onChanged,
  ) {
    final textEditingController = TextEditingController(text: value);

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: TextField(
        decoration: InputDecoration(
          labelText: placeholder,
        ),
        key: UniqueKey(),
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
