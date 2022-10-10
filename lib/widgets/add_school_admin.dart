import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/services/remote_services.dart';

import '../controllers/student_controller.dart';

class AddSchoolAdmin extends StatefulWidget {
  final String schoolId;
  const AddSchoolAdmin({Key? key, required this.schoolId}) : super(key: key);

  @override
  State<AddSchoolAdmin> createState() => _AddSchoolAdminState();
}

class _AddSchoolAdminState extends State<AddSchoolAdmin> {
  final RemoteServices _remoteServices = RemoteServices();
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();
  final TextEditingController _adminContactController = TextEditingController();
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
            await _remoteServices
                .addSchoolAdmin(
              schoolId: widget.schoolId,
              name: _adminNameController.text,
              email: _adminEmailController.text,
              password: _adminPasswordController.text,
              contact: _adminContactController.text,
            )
                .then((value) {
              studentController.fetchAdmins(widget.schoolId);
              Navigator.pop(context);
            });
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
              controller: _adminNameController,
              header: "Admin Name",
            ),
            TextBox(
              controller: _adminEmailController,
              header: "Admin Email",
            ),
            TextBox(
              controller: _adminPasswordController,
              header: "Admin Password",
            ),
            TextBox(
              controller: _adminContactController,
              header: "Admin Contact",
            ),
          ],
        ),
      ),
    );
  }
}
