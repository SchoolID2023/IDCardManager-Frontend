import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';

import '../../models/student_model.dart';

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
    // TODO: implement initState
    super.initState();
    _studentController = Get.put(StudentController(widget.schoolId));
    student = _studentController.getStudentById(widget.studentId);
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      actions: [
        Button(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Button(
          child: const Text("Save"),
          onPressed: () {
            Navigator.of(context).pop();
            _studentController.editStudent(student);
          },
        ),
      ],
      title: const Text("Edit Student"),
      content: isLoading == true
          ? const Center(child: ProgressRing())
          : ListView.builder(
              shrinkWrap: true,
              itemCount: student.data.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(children: [
                    TextBox(
                      header: "Name",
                      controller: TextEditingController(text: student.name),
                      onChanged: (value) {
                        setState(() {
                          student.name = value;
                        });
                      },
                    ),
                    TextBox(
                      header: "Contact",
                      controller: TextEditingController(text: student.contact),
                      onChanged: (value) {
                        setState(() {
                          student.contact = value;
                        });
                      },
                    ),
                    TextBox(
                      header: "Class",
                      controller:
                          TextEditingController(text: student.studentClass),
                      onChanged: (value) {
                        setState(() {
                          student.studentClass = value;
                        });
                      },
                    ),
                    TextBox(
                      header: "Section",
                      controller: TextEditingController(text: student.section),
                      onChanged: (value) {
                        setState(() {
                          student.section = value;
                        });
                      },
                    ),
                  ]);
                }

                if (ignoredPlaceholders
                    .contains(student.data[index - 1].field.toString())) {
                  return Container();
                }
                return TextBox(
                  // placeholder: widget.student.data[index - 1].value.toString(),
                  controller: TextEditingController(
                      text: student.data[index - 1].value.toString()),
                  header: student.data[index - 1].field.toString(),
                  onChanged: (value) {
                    student.data[index - 1].value = value;
                  },
                );
              },
            ),
    );
  }
}
