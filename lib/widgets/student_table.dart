import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';
import 'package:idcard_maker_frontend/widgets/dialog/confirm_delete.dart';
import 'package:idcard_maker_frontend/widgets/dialog/edit_student.dart';
import 'package:idcard_maker_frontend/widgets/dialog/generate_id_card.dart';
import 'package:idcard_maker_frontend/widgets/dialog/student_dialog.dart';
import 'package:path_provider/path_provider.dart';
import '../services/logger.dart';

import '../models/student_model.dart';

class StudentTable extends StatefulWidget {
  final List<String> labels;
  final List<String> photoLabels;
  final List<Student> students;
  final List<String> classes;
  final List<String> sections;
  final Map<String, bool> isSelected;
  final String schoolId;
  final Function(String, bool) onSelected;
  // final ScrollController ScrollController() = ScrollController();

  StudentTable({
    Key? key,
    required this.students,
    required this.isSelected,
    required this.onSelected,
    required this.classes,
    required this.sections,
    required this.schoolId,
    required this.labels,
    required this.photoLabels,
  }) : super(key: key);

  @override
  State<StudentTable> createState() => _StudentTableState();
}

class _StudentTableState extends State<StudentTable> {
  bool isAllSelected = false;
  String photoLabel = "-1";
  bool isFiltering = false;
  // int filterIndex = -1;
  String filterField = '';
  String classFilter = 'All';
  String sectionFilter = 'All';
  final TextEditingController _filter = TextEditingController();

  List<String> filteredStudents = [];

  final ValueNotifier<bool> _isAllSelected = ValueNotifier(false);
  final ValueNotifier<Map<String, bool>> isSelected = ValueNotifier(
    <String, bool>{},
  );

  void onSelectingRow(String studentId, bool isSelected) {
    setState(() {
      this.isSelected.value[studentId] = isSelected;
    });
    widget.onSelected(studentId, isSelected);
  }

  final Map<String, bool> _isVisible = <String, bool>{};
  late StudentController studentController;

  void deleteStudent(String studentId) {
    studentController.deleteStudent(studentId, widget.schoolId);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    logger.d("Length-> ${widget.students[0].data.length}");

    for (var element in widget.labels) {
      _isVisible[element] = false;
    }

    photoLabel = widget.photoLabels.isNotEmpty ? widget.photoLabels[0] : "-1";

    studentController = Get.put(StudentController(widget.schoolId));
  }

  @override
  Widget build(BuildContext context) {
    isSelected.value = widget.isSelected;

    List<DataColumn> columnName = [
      const DataColumn(
        label: Text('S. No.'),
      ),
      DataColumn(
        label: const Text('Name'),
        onSort: (int columnIndex, bool ascending) {
          setState(() {
            if (columnIndex == 1) {
              widget.students.sort((a, b) => a.name.compareTo(b.name));
            } else {
              widget.students.sort((a, b) => a.data[columnIndex - 1].value
                  .toString()
                  .compareTo(b.data[columnIndex - 1].value.toString()));
            }
          });
        },
      ),
      DataColumn(
        label: const Text('Class'),
        onSort: (int columnIndex, bool ascending) {
          setState(() {
            if (columnIndex == 2) {
              widget.students
                  .sort((a, b) => a.studentClass.compareTo(b.studentClass));
            } else {
              widget.students.sort((a, b) => a.data[columnIndex - 1].value
                  .toString()
                  .compareTo(b.data[columnIndex - 1].value.toString()));
            }
          });
        },
      ),
      DataColumn(
        label: const Text('Section'),
        onSort: (int columnIndex, bool ascending) {
          setState(
            () {
              if (columnIndex == 3) {
                widget.students.sort((a, b) => a.section.compareTo(b.section));
              } else {
                widget.students.sort((a, b) => a.data[columnIndex - 1].value
                    .toString()
                    .compareTo(b.data[columnIndex - 1].value.toString()));
              }
            },
          );
        },
      ),
      const DataColumn(
        label: Text('Contact'),
      ),
    ];

    widget.photoLabels.isNotEmpty
        ? columnName.add(
            DataColumn(
              label: Text(
                widget.students[0].photo
                    .firstWhere((element) => element.field == photoLabel,
                        orElse: () => Photo(field: photoLabel, value: "value"))
                    .field,
              ),
            ),
          )
        : Container();

    int getIndex(Student student, String field) {
      for (int i = 0; i < student.data.length; i++) {
        if (student.data[i].field == field) {
          return i;
        }
      }
      return 0;
    }

    for (String label in widget.labels) {
      // logger.d("Field--> ${element.field}");
      if (_isVisible[label] ?? false) {
        columnName.add(
          DataColumn(
            label: Text(label),
            onSort: (int columnIndex, bool ascending) {
              setState(() {
                if (true) {
                  widget.students.sort((a, b) => a
                      .data[getIndex(a, label)].value
                      .toString()
                      .compareTo(b.data[getIndex(a, label)].value.toString()));
                }
              });
            },
          ),
        );
      }
    }
    final tableKey = GlobalKey<PaginatedDataTableState>();
    final DataTableSource data = MyData(
      widget.students,
      context,
      onSelectingRow,
      isSelected,
      _isVisible,
      photoLabel,
      isFiltering,
      filteredStudents,
      filterField,
      classFilter,
      sectionFilter,
      deleteStudent,
      widget.schoolId,
    );
    return fluent.Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: fluent.Column(
            children: [
              fluent.Padding(
                padding: const EdgeInsets.all(8.0),
                child: fluent.Row(
                  children: [
                    widget.labels.isEmpty
                        ? Container()
                        : SizedBox(
                            width: 150,
                            child: fluent.DropDownButton(
                              title: filterField != ''
                                  ? Text(filterField)
                                  : const Text('Search Data by'),
                              items: List<fluent.MenuFlyoutItem>.generate(
                                widget.labels.length,
                                (index) => fluent.MenuFlyoutItem(
                                  // leading: fluent.Checkbox(
                                  //   checked: _isVisible[index] ?? false,
                                  //   onChanged: (value) {
                                  //     setState(() {
                                  //       _isVisible[index] = !(_isVisible[index] ?? false);
                                  //     });
                                  //   },
                                  // ),
                                  text: Text(widget.labels[index]),
                                  onPressed: () {
                                    setState(() {
                                      filterField = widget.labels[index];
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                    fluent.SizedBox(
                      width: 400,
                      child: fluent.TextBox(
                        placeholder: 'Search',
                        controller: _filter,
                        onEditingComplete: () {
                          logger.d("Editing Complete");
                          setState(() {
                            isFiltering = true;
                            filteredStudents =
                                _filter.text.toLowerCase().split(',').toList();
                            logger.d(filteredStudents);
                          });
                        },
                      ),
                    ),
                    fluent.Button(
                        child: const Text("Filter"),
                        onPressed: () {
                          setState(() {
                            isFiltering = true;
                            filteredStudents =
                                _filter.text.toLowerCase().split(',').toList();
                            logger.d(filteredStudents);
                          });
                        }),
                    fluent.Button(
                        child: const Text("Clear Filter"),
                        onPressed: () {
                          setState(() {
                            isFiltering = false;
                            _filter.clear();

                            filteredStudents = [];
                          });
                        }),
                  ],
                ),
              ),
              fluent.Row(
                children: [
                  fluent.Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 250,
                      child: widget.classes.isEmpty
                          ? Container()
                          : fluent.DropDownButton(
                              title: classFilter != 'All'
                                  ? Text(
                                      'Students of Class ${classFilter.toUpperCase()}')
                                  : const Text('All Classes'),
                              items: List<fluent.MenuFlyoutItem>.generate(
                                widget.classes.length,
                                (index) => fluent.MenuFlyoutItem(
                                  text: Text(widget.classes[index]),
                                  onPressed: () {
                                    setState(() {
                                      classFilter = widget.classes[index];
                                    });
                                  },
                                ),
                              ),
                            ),
                    ),
                  ),
                  fluent.Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 250,
                      child: widget.sections.isEmpty
                          ? Container()
                          : fluent.DropDownButton(
                              title: sectionFilter != 'All'
                                  ? Text(
                                      'Students of Section ${sectionFilter.toUpperCase()}')
                                  : const Text('All Sections'),
                              items: List<fluent.MenuFlyoutItem>.generate(
                                widget.sections.length,
                                (index) => fluent.MenuFlyoutItem(
                                  text: Text(widget.sections[index]),
                                  onPressed: () {
                                    setState(() {
                                      sectionFilter = widget.sections[index];
                                    });
                                  },
                                ),
                              ),
                            ),
                    ),
                  ),
                  fluent.FilledButton(
                    child: const Text("Generate ID Cards"),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return GenerateIdCard(
                              students: widget.students,
                              isSelected: widget.isSelected,
                              schoolId: widget.schoolId,
                            );
                          });
                    },
                  )
                ],
              ),
            ],
          ),
        ),
        PaginatedDataTable(
          // controller: ScrollController(),
          key: tableKey,
          actions: [
            SizedBox(
              width: 150,
              child: fluent.TextBox(
                placeholder: 'Page Number',
                onChanged: ((value) {
                  tableKey.currentState!
                      .pageTo(int.parse(value == "" ? "0" : value) * 10);
                }),
              ),
            )
          ],
          onSelectAll: (selectedValue) {
            for (var student in widget.students) {
              widget.onSelected(student.id, selectedValue!);
            }

            isSelected.value.updateAll((key, value) => value = selectedValue!);
            setState(() {
              isAllSelected = selectedValue!;
            });

            logger.d(isAllSelected);
          },
          // sortColumnIndex: 2,
          source: data,
          header: Row(
            children: [
              const Text('Students'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget.labels.length <= 5
                    ? Container()
                    : SizedBox(
                        width: 150,
                        child: fluent.DropDownButton(
                          title: const Text('View Data'),
                          items: List<fluent.MenuFlyoutItem>.generate(
                            widget.labels.length - 5,
                            (index) {
                              index += 5;

                              return fluent.MenuFlyoutItem(
                                leading: fluent.Checkbox(
                                  checked: _isVisible.values.elementAt(index),
                                  onChanged: (value) {
                                    setState(() {
                                      _isVisible[_isVisible.keys
                                              .elementAt(index)] =
                                          !(_isVisible.values.elementAt(index));
                                    });
                                  },
                                ),
                                text: Text(_isVisible.keys.elementAt(index)),
                                onPressed: () {
                                  setState(() {
                                    _isVisible[
                                            _isVisible.keys.elementAt(index)] =
                                        !(_isVisible.values.elementAt(index));
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
              ),
              widget.photoLabels.isEmpty
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 150,
                        child: fluent.DropDownButton(
                          title: const Text('View Photo'),
                          items: List<fluent.MenuFlyoutItem>.generate(
                            widget.photoLabels.length,
                            (index) => fluent.MenuFlyoutItem(
                              text: Text(widget.photoLabels[index]),
                              onPressed: () {
                                setState(() {
                                  photoLabel = widget.photoLabels[index];
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
          columns: columnName,
          columnSpacing: 50,
          horizontalMargin: 10,
          dataRowHeight: 90,

          rowsPerPage:  min(10, widget.students.length),
          showCheckboxColumn: true,
          sortAscending: true,
        ),
      ],
    );
  }
}

class MyData extends DataTableSource {
  final List<Student> students;
  final Function(String, bool) onSelected;
  final ValueNotifier<Map<String, bool>> isSelected;
  final Map<String, bool> _isVisible;
  final String photoLabel;
  final bool isFiltering;
  final List<String> filteredStudents;
  final String filterField;
  final String classFilter;
  final String sectionFilter;
  final String schoolId;

  String noPhoto =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/1024px-No_image_available.svg.png';

  final Function deleteFunction;

  BuildContext context;
  final List<List<String>> _data = [];
  MyData(
      this.students,
      this.context,
      this.onSelected,
      this.isSelected,
      this._isVisible,
      this.photoLabel,
      this.isFiltering,
      this.filteredStudents,
      this.filterField,
      this.classFilter,
      this.sectionFilter,
      this.deleteFunction,
      this.schoolId) {
    bool ifFilter(Student student) {
      bool value = false;
      logger.i(
          "Filtering ${student.name} ${filterField} ${filteredStudents.toString()}");
      if (filterField == "") {
        for (var fields in _isVisible.keys) {
          if (fields == 'name') {
            for (var element in filteredStudents) {
              if (student.name.toLowerCase().contains(element.toLowerCase())) {
                value = true;
                break;
              }
            }
          } else if (fields == 'class') {
            for (var element in filteredStudents) {
              if (student.studentClass
                  .toLowerCase()
                  .contains(element.toLowerCase())) {
                value = true;
                break;
              }
            }
          } else if (fields == 'section') {
            for (var element in filteredStudents) {
              if (student.section
                  .toLowerCase()
                  .contains(element.toLowerCase())) {
                value = true;
                break;
              }
            }
          } else if (fields == 'contact') {
            for (var element in filteredStudents) {
              if (student.contact
                  .toLowerCase()
                  .contains(element.toLowerCase())) {
                value = true;
                break;
              }
            }
          } else {
            for (var element in filteredStudents) {
              for (var data in student.data) {
                if (data.value
                        .toString()
                        .toLowerCase()
                        .contains(element.toLowerCase()) &&
                    data.field
                        .toLowerCase()
                        .contains(filterField.toLowerCase())) {
                  value = true;
                  break;
                }
              }
            }
          }
        }
      }

      if (filterField == 'name') {
        for (var element in filteredStudents) {
          if (student.name.toLowerCase().contains(element.toLowerCase())) {
            value = true;
            break;
          }
        }
      } else if (filterField == 'class') {
        for (var element in filteredStudents) {
          if (student.studentClass
              .toLowerCase()
              .contains(element.toLowerCase())) {
            value = true;
            break;
          }
        }
      } else if (filterField == 'section') {
        for (var element in filteredStudents) {
          if (student.section.toLowerCase().contains(element.toLowerCase())) {
            value = true;
            break;
          }
        }
      } else if (filterField == 'contact') {
        for (var element in filteredStudents) {
          if (student.contact.toLowerCase().contains(element.toLowerCase())) {
            value = true;
            break;
          }
        }
      } else {
        for (var element in filteredStudents) {
          for (var data in student.data) {
            if (data.value
                    .toString()
                    .toLowerCase()
                    .contains(element.toLowerCase()) &&
                data.field.toLowerCase().contains(filterField.toLowerCase())) {
              value = true;
              break;
            }
          }
        }
      }

      logger.i("Filtering ${student.name} $value");

      return value;
    }

    for (int index = 0; index < students.length; index++) {
      if (isFiltering && filteredStudents.isNotEmpty) {
        if (!ifFilter(students[index])) {
          // logger.d(
          //     "##-> ${students[index].data[filterIndex].value} -- ${filteredStudents}");
          continue;
        }
      }

      if (classFilter != 'All' && students[index].studentClass != classFilter) {
        continue;
      }

      if (sectionFilter != 'All' &&
          students[index].section.toUpperCase() !=
              sectionFilter.toUpperCase()) {
        continue;
      }

      List<String> studentData = [
        index.toString(),
        students[index].name,
        students[index].studentClass,
        students[index].section,
        students[index].contact
      ];

      if (photoLabel != "-1") {
        studentData.add(students[index]
            .photo
            .firstWhere((element) => element.field == photoLabel,
                orElse: () => Photo(value: noPhoto, field: "No Value"))
            .value);
      }

      for (var label in _isVisible.keys) {
        if (_isVisible[label] ?? false) {
          studentData.add(students[index]
              .data
              .firstWhere((element) => element.field == label,
                  orElse: () => Datum(value: "", field: "No Value"))
              .value
              .toString());
        }
      }

      studentData.add(students[index].id);
      _data.add(studentData);
    }
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0;
  @override
  DataRow getRow(int index) {
    int ind = 0;
    return DataRow(
      selected: isSelected.value[students[index].id] ?? true,
      onSelectChanged: (value) {
        logger.d("Selected Row: $value");
        onSelected(students[index].id, value!);

        logger.d("Previous Value--> ${isSelected.value[students[index].id]}");
        isSelected.value[students[index].id] = value;
      },
      cells: List<DataCell>.generate(_data[index].length - 1, (value) {
        if (value == 5 && photoLabel != "-1") {
          return DataCell(
            GestureDetector(
              onDoubleTap: () async {
                // Download the image to the computer in downloads section

                final Directory? downloadsDir = await getDownloadsDirectory();

                final String downloadsPath = downloadsDir!.path;
                String savePath =
                    "$downloadsPath/idcardImages/${_data[index][1]}.jpg";


                logger.i(savePath);
                try {
                  await Dio().download(
                    _data[index][value],
                    savePath,
                  );
                } on DioError catch (e) {
                  print(e.message);
                } finally {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: Text("Image Downloaded in Downloads Folder"),
                  //   ),
                  // );
                }
              },
              child: Image.network(
                _data[index][value],
                height: 90,
                // width: 100,
              ),
            ),
          );
        }

        return DataCell(
          // showEditIcon: value == 0 ? true : false,

          onTap: value == 1
              ? null
              : () {
                  logger.d(students[index].id);
                  showDialog(
                    context: context,
                    builder: (context) => EditStudent(
                      studentId: _data[index].last,
                      schoolId: schoolId,
                    ),
                  );
                },
          fluent.Row(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Text(
                  _data[index][value].toString(),
                  maxLines: 3,
                  // overflow: TextOverflow.ellipsis,
                ),
              ),
              value == 1
                  ? IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return ConfirmDelete(
                                type: "Student",
                                name: _data[index][value],
                                deleteFunction: () {
                                  deleteFunction(_data[index].last);
                                },
                              );
                            });
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ))
                  : Container(),
            ],
          ),
        );
      }),
    );
  }
}
