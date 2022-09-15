import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';

import '../controllers/student_controller.dart';
import '../models/student_model.dart';
import 'edit_student.dart';

class StudentDialog extends StatelessWidget {
  // final String studentId;
  // final String studentName;
  // final String studentClass;
  // final String studentSection;
  final Student student;

  const StudentDialog({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StudentController _studentController =
        Get.put(StudentController(student.currentSchool));

    return ContentDialog(
      title: Text(student.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Class:-  ${student.studentClass}'),
          Text("Section:- ${student.section}"),
        ],
      ),
      actions: [
        Button(
          child: Text('Edit'),
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
                context: context,
                builder: (context) => EditStudent(student: student));
          },
        ),
        Button(
          child: Text('Delete'),
          onPressed: () {
            _studentController.deleteStudent(student.id);
            Navigator.of(context).pop();
          },
        ),
        Button(
          child: Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
