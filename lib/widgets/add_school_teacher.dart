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
  RemoteServices _remoteServices = RemoteServices();
  TextEditingController _teacherNameController = TextEditingController();
  TextEditingController _teacherEmailController = TextEditingController();
  TextEditingController _teacherPasswordController = TextEditingController();
  TextEditingController _teacherContactController = TextEditingController();
  TextEditingController _teacherClassController = TextEditingController();
  TextEditingController _teacherSectionController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    final StudentController studentController =
        Get.put(StudentController(widget.schoolId));
    return ContentDialog(
      title: Text("Add SchoolAdmin"),
      actions: [
        Button(
          child: Text("Add"),
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
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      content: SizedBox(
        width: 400,
        child: Column(
          children: [
            TextBox(
              controller: _teacherNameController,
              header: "Teacher Name",
            ),
            TextBox(
              controller: _teacherEmailController,
              header: "Teacher Username",
            ),
            TextBox(
              controller: _teacherPasswordController,
              header: "Teacher Password",
            ),
            TextBox(
              controller: _teacherContactController,
              header: "Teacher Contact",
            ),
            TextBox(
              controller: _teacherClassController,
              header: "Teacher Class",
            ),
            TextBox(
              controller: _teacherSectionController,
              header: "Teacher Section",
            ),


          ],
        ),
      ),
    );
  }
}
