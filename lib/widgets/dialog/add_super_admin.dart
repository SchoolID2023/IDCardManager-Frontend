import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';

import '../../controllers/school_controller.dart';

import '../../models/superadmin_model.dart';

class AddSuperAdmin extends StatefulWidget {
  const AddSuperAdmin({super.key});

  @override
  State<AddSuperAdmin> createState() => _AddSuperAdminState();
}

class _AddSuperAdminState extends State<AddSuperAdmin> {
  final SchoolController schoolController = Get.put(SchoolController());
  final TextEditingController _superAdminName = TextEditingController();

  final TextEditingController _superAdminContact = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("Super Admin Details"),
      actions: [
        Button(
          child: const Text("Add Super Admin"),
          onPressed: () {
            schoolController.addSuperAdmin(SuperAdmin(
              email: DateTime.now().toString(),
              password: DateTime.now().toString(),
              name: _superAdminName.text,
              contact: _superAdminContact.text,
              username: DateTime.now().toString(),
            ));

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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextBox(
            controller: _superAdminName,
            placeholder: "Name",
          ),
          TextBox(
            controller: _superAdminContact,
            placeholder: "Contact",
          ),
        ],
      ),
    );
  }
}
