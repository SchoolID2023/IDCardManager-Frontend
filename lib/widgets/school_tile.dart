import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/school_controller.dart';
import 'package:idcard_maker_frontend/pages/school_info_page.dart';

import '../models/schools_model.dart';
import 'dialog/confirm_delete.dart';

class SchoolTile extends StatelessWidget {
  final School school;
  SchoolTile({Key? key, required this.school}) : super(key: key);
  final SchoolController _schoolController = Get.put(SchoolController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      child: ListTile(
        title: Text(school.name.toUpperCase()),
        subtitle: Text(school.address.toUpperCase()),
        onPressed: () {
          Navigator.of(context).push(
            FluentPageRoute(
              builder: (context) {
                return SchoolInfoPage(
                  schoolId: school.id,
                );
              },
            ),
          );
        },
        trailing: SizedBox(
          width: 200,
          child: IconButton(
            icon: Icon(
              FluentIcons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmDelete(
                      type: "School",
                      name: school.name.toUpperCase(),
                      deleteDialogueFunction: () {
                        _schoolController.deleteSchool(school.id);
                      },
                      deletePhoto: false,
                    );
                  });
            },
          ),
        ),
      ),
    );
  }
}
