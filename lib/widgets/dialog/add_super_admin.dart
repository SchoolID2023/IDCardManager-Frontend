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

  final TextEditingController _superAdminUsername = TextEditingController();

  final TextEditingController _superAdminPassword = TextEditingController();

  final TextEditingController _superAdminContact = TextEditingController();

  final TextEditingController _superAdminEmail = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("Super Admin Details"),
      actions: [
        Button(
          child: const Text("Add Super Admin"),
          onPressed: () {
            schoolController.addSuperAdmin(SuperAdmin(
              email: _superAdminEmail.text,
              password: _superAdminPassword.text,
              name: _superAdminName.text,
              contact: _superAdminContact.text,
              username: _superAdminUsername.text,
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
            header: "superAdmin Name",
          ),
          TextBox(
            controller: _superAdminUsername,
            header: "superAdmin Username",
          ),
          TextBox(
            controller: _superAdminPassword,
            header: "Password",
          ),
          TextBox(
            controller: _superAdminContact,
            header: "Contact",
          ),
          TextBox(
            controller: _superAdminEmail,
            header: "Email",
          ),
        ],
      ),
    );
  }
}
