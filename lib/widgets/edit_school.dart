import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/school_controller.dart';

import '../controllers/student_controller.dart';
import '../models/schools_model.dart';

class EditSchoolDialog extends StatefulWidget {
  final School school;
  EditSchoolDialog({Key? key, required this.school}) : super(key: key);

  @override
  State<EditSchoolDialog> createState() => _EditSchoolDialogState();
}

class _EditSchoolDialogState extends State<EditSchoolDialog> {
  late School editSchool;
  late StudentController studentController;
  late SchoolController schoolController;

  TextEditingController _schoolName = TextEditingController();
  TextEditingController _schoolAddress = TextEditingController();
  TextEditingController _schoolClasses = TextEditingController();
  TextEditingController _schoolSections = TextEditingController();
  TextEditingController _schoolContact = TextEditingController();
  TextEditingController _schoolEmail = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    editSchool = widget.school;
    _schoolName.text = editSchool.name;
    _schoolAddress.text = editSchool.address;
    _schoolClasses.text = editSchool.classes.join(',');
    _schoolSections.text = editSchool.sections.join(',');
    _schoolContact.text = editSchool.contact;
    _schoolEmail.text = editSchool.email;
    studentController = Get.put(StudentController(editSchool.id));
    schoolController = Get.put(SchoolController());
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text("School Details"),
      actions: [
        Button(
          child: Text("Add Save"),
          onPressed: () {
            Navigator.of(context).pop();
            studentController.editSchool(
              School(
                id: editSchool.id,
                name: _schoolName.text,
                address: _schoolAddress.text,
                classes: _schoolClasses.text.split(','),
                sections: _schoolSections.text.split(','),
                contact: _schoolContact.text,
                email: _schoolEmail.text,
              ),
            );
            schoolController.fetchSchools();
          },
        ),
        Button(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextBox(
            controller: _schoolName,
            header: "School Name",
          ),
          TextBox(
            controller: _schoolAddress,
            header: "School Address",
          ),
          TextBox(
            controller: _schoolClasses,
            header: "Classes",
          ),
          TextBox(
            controller: _schoolSections,
            header: "Sections",
          ),
          TextBox(
            controller: _schoolContact,
            header: "Contact",
          ),
          TextBox(
            controller: _schoolEmail,
            header: "Email",
          ),
        ],
      ),
    );
  }
}
