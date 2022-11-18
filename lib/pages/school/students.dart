import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';
import 'package:idcard_maker_frontend/models/student_model.dart';

import '../../widgets/student_table.dart';

class Students extends StatefulWidget {
  final String schoolId;
  const Students({super.key, required this.schoolId});

  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  late StudentController studentController;
  final Map<String, bool> _selectedStudents = {};

  final controller = ScrollController();

  @override
  void initState() {
    studentController = Get.put(StudentController(widget.schoolId));
    for (Student element in studentController.getStudents) {
      _selectedStudents[element.id] = false;
    }
    super.initState();
  }

  void updateSelectedStudents(String studentId, bool isSelected) {
    _selectedStudents[studentId] = isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: studentController.getStudents.isNotEmpty
                ? Scrollbar(
                    controller: controller,
                    child: SingleChildScrollView(
                      controller: controller,
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: StudentTable(
                            students: studentController.getStudents,
                            isSelected: _selectedStudents,
                            onSelected: updateSelectedStudents,
                            classes: studentController.getSchool.classes,
                            sections: studentController.getSchool.sections,
                            schoolId: widget.schoolId,
                            labels: studentController.getSchoolLabels.labels,
                            photoLabels:
                                studentController.getSchoolLabels.photoLabels,
                          ),
                        ),
                      ),
                    ),
                  )
                : const Text("No Students"),
          ),
        );
      },
    );
  }
}
