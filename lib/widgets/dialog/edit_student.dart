import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';

import '../../models/student_model.dart';

class EditStudent extends StatefulWidget {
  final Student student;
  const EditStudent({Key? key, required this.student}) : super(key: key);

  @override
  State<EditStudent> createState() => _EditStudentState();
}

class _EditStudentState extends State<EditStudent> {
  bool isLoading = true;
  late Student student;

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
    student = widget.student;
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    StudentController _studentController =
        Get.put(StudentController(student.currentSchool));
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
                      controller: TextEditingController(text: student.studentClass),
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

                if (ignoredPlaceholders.contains(
                    widget.student.data[index - 1].field.toString())) {
                  return Container();
                }
                return TextBox(
                  // placeholder: widget.student.data[index - 1].value.toString(),
                  controller: TextEditingController(
                      text: widget.student.data[index - 1].value.toString()),
                  header: widget.student.data[index - 1].field.toString(),
                  onChanged: (value) {
                    student.data[index - 1].value = value;
                  },
                );
              },
            ),
    );
  }
}
