import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';
import '../../models/admins_model.dart';
import '../../models/schools_model.dart';
import 'package:flutter/material.dart';

class EditAdmin extends StatefulWidget {
  final String adminId;
  final String schoolId;
  const EditAdmin({Key? key, required this.adminId, required this.schoolId})
      : super(key: key);

  @override
  State<EditAdmin> createState() => _EditAdminState();
}

class _EditAdminState extends State<EditAdmin> {
  bool isLoading = true;
  late SchoolAdmin admin;
  late SchoolAdmin editingAdmin;
  late StudentController _studentController;
  late School schoolData;

  Set<String> ignoredPlaceholders = {
    "_id",
    "__v",
    "id",
    "currentSchool",
    "idCard",
    "otp",
    "password",
  };

  @override
  void initState() {
    super.initState();
    _studentController = Get.put(StudentController(widget.schoolId));

    admin = _studentController.getAdminById(widget.adminId);
    editingAdmin = SchoolAdmin.fromJson(admin.toJson());
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(30.0),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Admin",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 2,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return buildTextBox(
                                  "Name",
                                  editingAdmin.name,
                                  (value) {
                                    editingAdmin.name = value;
                                  },
                                );
                              }
                              if (index == 1) {
                                return buildTextBox(
                                  "Contact",
                                  editingAdmin.contact,
                                  (value) {
                                    editingAdmin.contact = value;
                                  },
                                );
                              }
                              return null;
                            },
                          ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _studentController.editSchoolAdmin(editingAdmin);
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdown(
    String placeholder,
    String? value,
    void Function(String?)? onChanged,
    List<String> options,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: placeholder,
        ),
        dropdownColor: Theme.of(context).cardColor,
        value: value,
        onChanged: onChanged,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  Widget buildTextBox(
    String placeholder,
    String value,
    Function(String) onChanged,
  ) {
    final textEditingController = TextEditingController(text: value);

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: placeholder,
        ),
        controller: textEditingController,
        onChanged: onChanged,
        autofocus: false,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        cursorWidth: 2.0,
        cursorRadius: const Radius.circular(2.0),
        enableInteractiveSelection: true,
      ),
    );
  }
}
