import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';
import 'package:idcard_maker_frontend/models/student_model.dart';
import 'package:idcard_maker_frontend/services/logger.dart';

import '../../widgets/student_table.dart';

class Students extends StatefulWidget {
  final String schoolId;

  const Students({Key? key, required this.schoolId}) : super(key: key);

  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  late StudentController studentController;
  final Map<String, bool> _selectedStudents = {};
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
    studentController = Get.put(StudentController(widget.schoolId));
    _initializeSelectedStudents();
  }

  void _initializeSelectedStudents() {
    for (Student element in studentController.getStudents) {
      _selectedStudents[element.id] = false;
    }
  }

  void updateSelectedStudents(String studentId, bool isSelected) {
    logger.i("Selected $studentId");
    setState(() {
      _selectedStudents[studentId] = isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);

    return Obx(
      () {
        return ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Double Tap an image to download it in the downloads folder",
                style: theme.typography.subtitle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: studentController.getStudents.isNotEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return Scrollbar(
                            interactive: true,
                            style: const ScrollbarThemeData(
                              thickness: 8,
                            ),
                            controller: controller,
                            child: SingleChildScrollView(
                              controller: controller,
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth,
                                ),
                                child: IntrinsicWidth(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: SizedBox(
                                      width: constraints.maxWidth,
                                      child: StudentTable(
                                        students: studentController.getStudents,
                                        isSelected: _selectedStudents,
                                        onSelected: updateSelectedStudents,
                                        classes:
                                            studentController.getSchool.classes,
                                        sections: studentController
                                            .getSchool.sections,
                                        schoolId: widget.schoolId,
                                        labels: studentController
                                            .getSchoolLabels.labels,
                                        photoLabels: studentController
                                            .getSchoolLabels.photoLabels,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : const Text("No Students"),
              ),
            ),
          ],
        );
      },
    );
  }
}
