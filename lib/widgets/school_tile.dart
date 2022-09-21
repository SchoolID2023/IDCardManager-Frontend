import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/school_controller.dart';
import 'package:idcard_maker_frontend/pages/student_data.dart';
import 'package:idcard_maker_frontend/services/remote_services.dart';
import 'package:idcard_maker_frontend/widgets/student_table.dart';
import '../models/schools_model.dart';
import 'load_id_card_data.dart';

class SchoolTile extends StatelessWidget {
  final School school;
  SchoolTile({Key? key, required this.school}) : super(key: key);
  final SchoolController _schoolController = Get.put(SchoolController());

  @override
  Widget build(BuildContext context) {
    var _classes = school.classes.join(',');
    var _sections = school.sections.join(',');

    TextEditingController _schoolName =
        TextEditingController(text: school.name);
    TextEditingController _schoolAddress =
        TextEditingController(text: school.address);
    TextEditingController _schoolClasses =
        TextEditingController(text: _classes.toString());
    TextEditingController _schoolSections =
        TextEditingController(text: _sections.toString());
    TextEditingController _schoolContact =
        TextEditingController(text: school.contact);
    TextEditingController _schoolEmail =
        TextEditingController(text: school.email);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(FluentPageRoute(builder: (context) {
            return StudentDataScreen(
              schoolId: school.id,
            );
          }));
        },
        child: Card(
          child: ListTile(
              title: Text(school.name),
              subtitle: Text(school.address),
              trailing: SizedBox(
                width: 200,
                child: IconButton(
                  icon: Icon(
                    FluentIcons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _schoolController.deleteSchool(school.id);
                  },
                ),
              )),
        ),
      ),
    );
  }
}
