import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/school_controller.dart';
import 'package:idcard_maker_frontend/pages/school_info_page.dart';
import 'package:idcard_maker_frontend/pages/student_data.dart';
import '../models/schools_model.dart';

class SchoolTile extends StatelessWidget {
  final School school;
  SchoolTile({Key? key, required this.school}) : super(key: key);
  final SchoolController _schoolController = Get.put(SchoolController());

  @override
  Widget build(BuildContext context) {
    // var classes = school.classes.join(',');
    // var sections = school.sections.join(',');

    // TextEditingController schoolName =
    //     TextEditingController(text: school.name);
    // TextEditingController schoolAddress =
    //     TextEditingController(text: school.address);
    // TextEditingController schoolClasses =
    //     TextEditingController(text: classes.toString());
    // TextEditingController schoolSections =
    //     TextEditingController(text: sections.toString());
    // TextEditingController schoolContact =
    //     TextEditingController(text: school.contact);
    // TextEditingController schoolEmail =
    //     TextEditingController(text: school.email);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(FluentPageRoute(builder: (context) {
            // return StudentDataScreen(
            //   schoolId: school.id,
            // );
            return SchoolInfoPage(
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
