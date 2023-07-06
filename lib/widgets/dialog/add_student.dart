import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/student_controller.dart';
import '../../models/schools_model.dart';

class AddStudent extends StatefulWidget {
  final List<String> labels;
  final String currentSchool;

  const AddStudent(
      {super.key, required this.labels, required this.currentSchool});

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  Map<String, String> studentDetails = {};
  late StudentController studentController;
  List<String> classOptions = [];
  List<String> sectionOptions = [];
  late School schoolData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    studentController = Get.put(StudentController(widget.currentSchool));
    studentDetails["currentSchool"] = widget.currentSchool;

    () async {
      await studentController.fetchSchool(widget.currentSchool);
      schoolData = studentController.school.value;
      setState(() {
        classOptions = schoolData.classes;
        sectionOptions = schoolData.sections;
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
              "Add Student",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.labels.length,
                itemBuilder: (context, index) {
                  if (widget.labels[index].toLowerCase() == 'class') {
                    return buildDropdown(
                      widget.labels[index].toUpperCase(),
                      studentDetails[widget.labels[index]],
                      (value) {
                        setState(() {
                          studentDetails[widget.labels[index]] =
                              value!.isNotEmpty ? value : '';
                        });
                      },
                      classOptions,
                    );
                  }
                  if (widget.labels[index].toLowerCase() == 'section') {
                    return buildDropdown(
                      widget.labels[index].toUpperCase(),
                      studentDetails[widget.labels[index]],
                      (value) {
                        setState(() {
                          studentDetails[widget.labels[index]] =
                              value!.isNotEmpty ? value : '';
                        });
                      },
                      sectionOptions,
                    );
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
                        Theme.of(context).cardColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    studentController.addStudent(studentDetails);
                    Navigator.of(context).pop(studentDetails);
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

  Widget buildTextField(
    String placeholder,
    String value,
    Function(String) onChanged,
  ) {
    final textEditingController = TextEditingController(text: value);
    // final selection = TextSelection.fromPosition(
    //   TextPosition(offset: textEditingController.text.length),
    // );

    return TextField(
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
