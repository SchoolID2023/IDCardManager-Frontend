import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';

import '../../controllers/school_controller.dart';
import '../../models/schools_model.dart';

class AddSchool extends StatefulWidget {
  const AddSchool({super.key});

  @override
  State<AddSchool> createState() => _AddSchoolState();
}

class _AddSchoolState extends State<AddSchool> {
  final SchoolController schoolController = Get.put(SchoolController());
  final TextEditingController _schoolName = TextEditingController();

  final TextEditingController _schoolAddress = TextEditingController();

  final TextEditingController _schoolClasses = TextEditingController();

  final TextEditingController _schoolSections = TextEditingController();

  final TextEditingController _schoolContact = TextEditingController();

  final TextEditingController _schoolEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
    _schoolName.text = '';
    _schoolAddress.text = 'no address available';
    _schoolClasses.text = '';
    _schoolSections.text = '';
    _schoolContact.text = 'no contact available';
    _schoolEmail.text = 'no email available';
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("School Details"),
      actions: [
        Button(
          child: const Text("Add Save"),
          onPressed: () {
            schoolController.addSchool(
              School(
                id: DateTime.now().toString(),
                name: _schoolName.text,
                address: _schoolAddress.text,
                classes: _schoolClasses.text.split(','),
                sections: _schoolSections.text.split(','),
                contact: _schoolContact.text,
                email: _schoolEmail.text,
              ),
            );
            Navigator.of(context).pop();
          },
        ),
        Button(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
      content: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextBox(
              controller: _schoolName,
              placeholder: "School Name",
            ),
            // TextBox(
            //   controller: _schoolAddress,
            //   placeholder: "School Address",
            // ),
            // TextBox(
            //   controller: _schoolClasses,
            //   placeholder: "Classes",
            // ),
            // TextBox(
            //   controller: _schoolSections,
            //   placeholder: "Sections",
            // ),
            // TextBox(
            //   controller: _schoolContact,
            //   placeholder: "Contact",
            // ),
            // TextBox(
            //   controller: _schoolEmail,
            //   placeholder: "Email",
            // ),
          ],
        ),
      ),
    );
  }
}
