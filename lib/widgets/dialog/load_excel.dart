import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:excel/excel.dart';
import 'package:get/get.dart';

import '../../controllers/student_controller.dart';
import '../../models/id_card_model.dart';
import '../../services/logger.dart';

class LoadExcel extends StatefulWidget {
  final String schoolId;

  const LoadExcel({super.key, required this.schoolId});
  @override
  State<LoadExcel> createState() => _LoadExcelState();
}

class _LoadExcelState extends State<LoadExcel> {
  List<Label> labels = [];
  final TextEditingController _excelPath = TextEditingController();
  bool isDual = false;
  final TextEditingController _idCardWidth = TextEditingController();
  final TextEditingController _idCardHeight = TextEditingController();

  Future<void> uploadExcel() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ['xls', 'xlsx'],
    );

    var file = result?.files.first;

    var bytes = File(file!.path.toString()).readAsBytesSync();

    setState(() {
      _excelPath.text = file.path.toString();
    });

    Excel excel = Excel.decodeBytes(bytes);

    Sheet sheet = excel["Sheet1"];

    for (var table in excel.tables.keys) {
      logger.d(table); //sheet Name
      logger.d(excel.tables[table]?.maxCols);
      logger.d(excel.tables[table]?.maxRows);
      for (var cell in excel.tables[table]!.rows[0]) {
        cell!.value = cell.value.toString().replaceAll(".", "");
        logger.d("${cell.value}");
        labels.add(
          Label(
            title: cell.value.toString(),
          ),
        );
      }

      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    StudentController studentController =
        Get.put(StudentController(widget.schoolId));
    return ContentDialog(
      title: const Text("Upload Excel"),
      actions: [
        Button(
          child: const Text("OK"),
          onPressed: () async {
            await studentController
                .addStudents(widget.schoolId, _excelPath.text)
                .then(
              (value) {
                Navigator.pop(context);
              },
            );
          },
        ),
        Button(
            child: const Text("CANCEL"),
            onPressed: () => Navigator.pop(context)),
      ],
      content: Row(
        children: [
          Expanded(
            child: TextBox(
              controller: _excelPath,
              header: "Excel Path",
              readOnly: true,
            ),
          ),
          Button(
            child: const Text("Upload Excel"),
            onPressed: () async {
              await uploadExcel();
            },
          ),
        ],
      ),
    );
  }
}
