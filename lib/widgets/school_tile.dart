import 'package:fluent_ui/fluent_ui.dart';
import 'package:idcard_maker_frontend/pages/student_data.dart';
import 'package:idcard_maker_frontend/widgets/student_table.dart';
import '../models/schools_model.dart';
import 'load_id_card_data.dart';

class SchoolTile extends StatelessWidget {
  final School school;
  SchoolTile({Key? key, required this.school}) : super(key: key);

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // TextButton(
                    //   child: Text("Genrate"),
                    //   onPressed: () {
                    //     showDialog(
                    //         context: context,
                    //         builder: (context) => LoadIdCardData(
                    //               schoolId: school.id,
                    //             ));
                    //   },
                    // ),
                    // IconButton(
                    //   icon: Icon(FluentIcons.edit),
                    //   onPressed: () {
                    //     showDialog(
                    //       context: context,
                    //       builder: (context) {
                    //         return ContentDialog(
                    //           title: Text("School Details"),
                    //           actions: [
                    //             Button(
                    //               child: Text("Update"),
                    //               onPressed: () {},
                    //             ),
                    //             Button(
                    //               child: Text("Save"),
                    //               onPressed: () {
                    //                 Navigator.of(context).pop();
                    //               },
                    //             )
                    //           ],
                    //           content: Column(
                    //             mainAxisSize: MainAxisSize.min,
                    //             children: [
                    //               TextBox(
                    //                 controller: _schoolName,
                    //                 header: "School Name",
                    //               ),
                    //               TextBox(
                    //                 controller: _schoolAddress,
                    //                 header: "School Address",
                    //               ),
                    //               TextBox(
                    //                 controller: _schoolClasses,
                    //                 header: "Classes",
                    //               ),
                    //               TextBox(
                    //                 controller: _schoolSections,
                    //                 header: "Sections",
                    //               ),
                    //               TextBox(
                    //                 controller: _schoolContact,
                    //                 header: "Contact",
                    //               ),
                    //               TextBox(
                    //                 controller: _schoolEmail,
                    //                 header: "Email",
                    //               ),
                    //             ],
                    //           ),
                    //         );
                    //       },
                    //     );
                    //   },
                    // ),
                    // IconButton(
                    //   icon: Icon(FluentIcons.delete),
                    //   onPressed: () {},
                    // ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
