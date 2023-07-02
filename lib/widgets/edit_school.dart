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

  final TextEditingController _schoolName = TextEditingController();
  final TextEditingController _schoolAddress = TextEditingController();
  final TextEditingController _schoolClasses = TextEditingController();
  final TextEditingController _schoolSections = TextEditingController();
  final TextEditingController _schoolContact = TextEditingController();
  final TextEditingController _schoolEmail = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    editSchool = widget.school;
    _schoolName.text = editSchool.name;
    _schoolAddress.text = editSchool.address!;
    _schoolClasses.text = editSchool.classes!.join(',');
    _schoolSections.text = editSchool.sections!.join(',');
    _schoolContact.text = editSchool.contact!;
    _schoolEmail.text = editSchool.email!;
    studentController = Get.put(StudentController(editSchool.id));
    schoolController = Get.put(SchoolController());
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("School Details"),
      actions: [
        Button(
          child: const Text("Add Save"),
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
          child: const Text("Cancel"),
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
            placeholder: "School Name",
          ),
          TextBox(
            controller: _schoolAddress,
            placeholder: "School Address",
          ),
          TextBox(
            controller: _schoolClasses,
            placeholder: "Classes",
          ),
          TextBox(
            controller: _schoolSections,
            placeholder: "Sections",
          ),
          TextBox(
            controller: _schoolContact,
            placeholder: "Contact",
          ),
          TextBox(
            controller: _schoolEmail,
            placeholder: "Email",
          ),
        ],
      ),
    );
  }
}
