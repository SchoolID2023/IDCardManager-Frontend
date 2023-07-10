// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart' as mat;
import 'package:get/get.dart';
import '../../controllers/school_controller.dart';
import '../../controllers/student_controller.dart';
import '../../models/id_card_model.dart';
import '../../services/logger.dart';

class LoadExcel extends StatefulWidget {
  final String schoolId;

  const LoadExcel({Key? key, required this.schoolId}) : super(key: key);

  @override
  State<LoadExcel> createState() => _LoadExcelState();
}

class _LoadExcelState extends State<LoadExcel> {
  List<Label> labels = [];
  final TextEditingController _excelPath = TextEditingController();
  bool isDual = false;
  bool isLoading = false;

  late StudentController studentController;
  late SchoolController schoolController;

  bool updateOnly = false;

  @override
  void initState() {
    super.initState();

    studentController = Get.put(StudentController(widget.schoolId));
    schoolController = Get.put(SchoolController());
  }

  Future<void> uploadExcel() async {
    // setState(() {
    //   isLoading = true;
    // });

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

    for (var table in excel.tables.keys) {
      logger.d(table);
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

    // setState(() {
    //   isLoading = false;
    // });
  }

  Future<void> showProblemStudentsDialog(List<String> problemStudents) async {
    await showDialog(
      context: context,
      builder: (context) {
        return mat.AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Problem with ${problemStudents.length} students",
              ),
              const SizedBox(
                height: 8,
              ),
              const Text(
                "(missing one or more mandatory columns)",
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: !updateOnly
                  ? mat.DataTable(
                      columns: const [
                        mat.DataColumn(label: Text("S.No")),
                        mat.DataColumn(label: Text("Admno")),
                        mat.DataColumn(label: Text("Name")),
                        mat.DataColumn(label: Text("Contact")),
                        mat.DataColumn(label: Text("Class")),
                        mat.DataColumn(label: Text("Section")),
                      ],
                      rows: problemStudents.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final String student = entry.value;
                        final studentData = jsonDecode(student);
                        return mat.DataRow(
                          color: mat.MaterialStateProperty.resolveWith<Color?>(
                            (Set<mat.MaterialState> states) {
                              if (states.contains(mat.MaterialState.selected)) {
                                return mat.Colors.blue[100];
                              }
                              if (index % 2 != 0) {
                                return const Color.fromARGB(107, 0, 0, 0);
                              }
                              return null;
                            },
                          ),
                          cells: [
                            mat.DataCell(Text((index + 1).toString())),
                            mat.DataCell(Text(studentData["admno"])),
                            mat.DataCell(Text(studentData["name"])),
                            mat.DataCell(Text(studentData["contact"])),
                            mat.DataCell(Text(studentData["class"])),
                            mat.DataCell(Text(studentData["section"])),
                          ],
                        );
                      }).toList(),
                    )
                  : Text(problemStudents.toList().toString()),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                mat.ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: mat.ButtonStyle(
                    padding: mat.MaterialStateProperty.resolveWith<
                        EdgeInsetsGeometry?>((Set<mat.MaterialState> states) {
                      return const EdgeInsets.all(12);
                    }),
                    backgroundColor:
                        mat.MaterialStateProperty.resolveWith<Color?>(
                            (Set<mat.MaterialState> states) {
                      return Colors.blue;
                    }),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("Upload Excel"),
      actions: [
        isLoading
            ? const mat.CircularProgressIndicator()
            : Button(
                onPressed: isLoading
                    ? null
                    : () async {
                        List<String> problemStudents = [];
                        setState(() {
                          isLoading = !isLoading;
                        });
                        try {
                          problemStudents = await studentController.addStudents(
                              widget.schoolId, _excelPath.text, updateOnly);
                        } catch (e) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ContentDialog(
                                title: const Text("Error"),
                                content: Text(e.toString()),
                                actions: [
                                  Button(
                                    child: const Text("OK"),
                                    onPressed: () => Navigator.pop(context),
                                  )
                                ],
                              );
                            },
                          );
                        }

                        if (problemStudents.isNotEmpty) {
                          await showProblemStudentsDialog(problemStudents);
                        }
                        Navigator.pop(context);
                      },
                child: const Text("OK"),
              ),
        Button(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text("CANCEL"),
        ),
      ],
      content: IntrinsicHeight(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextBox(
                    controller: _excelPath,
                    placeholder: "Excel Path",
                    readOnly: true,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                isLoading
                    ? Button(
                        child: const Text(" Uploading"),
                        onPressed: () {},
                      )
                    : Button(
                        child: const Text("Upload Excel"),
                        onPressed: () async {
                          await uploadExcel();
                        },
                      ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Checkbox(
                  checked: updateOnly,
                  onChanged: (value) {
                    setState(() {
                      updateOnly = value ?? false;
                    });
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                const Expanded(
                    child:
                        Text("update only, column required in sheet 'admno'")),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Expanded(
              child: Text(
                "* For normal update, column required are 'admno' 'name', 'contact', 'class' and 'section'",
                style: TextStyle(fontSize: 13),
              ),
            )
          ],
        ),
      ),
    );
  }
}
