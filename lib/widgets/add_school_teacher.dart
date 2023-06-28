import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/services/remote_services.dart';

import '../controllers/student_controller.dart';

class AddSchoolTeacher extends StatefulWidget {
  final String schoolId;
  const AddSchoolTeacher({Key? key, required this.schoolId}) : super(key: key);

  @override
  State<AddSchoolTeacher> createState() => _AddSchoolTeacherState();
}

class _AddSchoolTeacherState extends State<AddSchoolTeacher> {
  final RemoteServices _remoteServices = RemoteServices();
  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _teacherEmailController = TextEditingController();
  final TextEditingController _teacherPasswordController = TextEditingController();
  final TextEditingController _teacherContactController = TextEditingController();
  final TextEditingController _teacherClassController = TextEditingController();
  final TextEditingController _teacherSectionController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    final StudentController studentController =
        Get.put(StudentController(widget.schoolId));
    return ContentDialog(
      title: const Text("Add SchoolAdmin"),
      actions: [
        Button(
          child: const Text("Add"),
          onPressed: () async {

            await _remoteServices.addSchoolTeacher(
              schoolId: widget.schoolId,
              name: _teacherNameController.text,
              username: _teacherEmailController.text,
              password: _teacherPasswordController.text,
              contact: _teacherContactController.text,
              className: _teacherClassController.text,
              section: _teacherSectionController.text,
            );

            studentController.fetchTeachers(widget.schoolId);
            Navigator.pop(context);
          },
        ),
        Button(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      content: SizedBox(
        width: 400,
        child: Column(
          children: [
            TextBox(
              controller: _teacherNameController,
              placeholder: "Teacher Name",
            ),
            TextBox(
              controller: _teacherEmailController,
              placeholder: "Teacher Username",
            ),
            TextBox(
              controller: _teacherPasswordController,
              placeholder: "Teacher Password",
            ),
            TextBox(
              controller: _teacherContactController,
              placeholder: "Teacher Contact",
            ),
            TextBox(
              controller: _teacherClassController,
              placeholder: "Teacher Class",
            ),
            TextBox(
              controller: _teacherSectionController,
              placeholder: "Teacher Section",
            ),


          ],
        ),
      ),
    );
  }
}
