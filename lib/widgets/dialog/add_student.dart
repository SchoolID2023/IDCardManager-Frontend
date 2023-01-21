import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';

import '../../controllers/student_controller.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    studentController = Get.put(StudentController(widget.currentSchool));
    studentDetails["currentSchool"] = widget.currentSchool;
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("Add Student"),
      content: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.labels.length,
        itemBuilder: (context, index) {
          if (widget.labels[index] == "sno") {
            return Container();
          }
          return TextBox(
            placeholder: widget.labels[index],
            onChanged: (value) {
              studentDetails[widget.labels[index]] = value;
            },
          );
        },
      ),
      actions: [
        FilledButton(
          child: const Text("Add Student"),
          onPressed: () {
            studentController.addStudent(studentDetails);
            Navigator.of(context).pop(studentDetails);
          },
        ),
        Button(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
