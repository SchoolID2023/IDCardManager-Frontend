import 'dart:math';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/constants/database_const.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';
import 'package:idcard_maker_frontend/widgets/dialog/confirm_delete.dart';
import 'package:idcard_maker_frontend/widgets/dialog/edit_student.dart';
import 'package:idcard_maker_frontend/widgets/dialog/generate_id_card.dart';
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

  const StudentTable({
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
  String filterField = '';
  String classFilter = 'All';
  String sectionFilter = 'All';
  final TextEditingController _filter = TextEditingController();
  List<String> filteredStudents = [];
  late Map<String, bool> isSelected;
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
    logger.d("Length-> ${widget.students[0].data.length}");
    for (var element in widget.labels) {
      _isVisible[element] = false;
    }
    photoLabel = widget.photoLabels.isNotEmpty ? widget.photoLabels[0] : "-1";
    studentController = Get.put(StudentController(widget.schoolId));
  }

  final tableKey = GlobalKey<PaginatedDataTableState>();
  void onSelectingRow(String studentId, bool isSelected) {
    setState(() {
      this.isSelected[studentId] = isSelected;
    });
    widget.onSelected(studentId, isSelected);
    // Set the current page index after the selection is made
    tableKey.currentState?.pageTo(currentPageIndex);
  }

  final Map<String, bool> _isVisible = <String, bool>{};
  late StudentController studentController;

  void deleteStudent(String studentId) {
    studentController.deleteStudent(studentId, widget.schoolId);
  }

  Future<bool> deleteStudentPhoto(String photoUrl, String studentId) async {
    try {
      bool deleteStatus = await studentController.deleteStudentPhoto(
          photoUrl, studentId, widget.schoolId);
      return deleteStatus ? true : false;
    } catch (e) {
      logger.d(e);
      return false;
    }
  }

  // void removeStudentImage(String studentId) {
  //   studentController.editStudent(studentId);
  // }

  @override
  Widget build(BuildContext context) {
    List<DataColumn> columnName = [
      const DataColumn(
        label: Text('S. No.'),
      ),
      DataColumn(
        label: const Text('ADMN. No.'),
        onSort: (int columnIndex, bool ascending) {
          setState(() {
            if (columnIndex == 1) {
              widget.students.sort((a, b) => a.admno.compareTo(b.admno));
            } else {
              widget.students.sort((a, b) => a.data[columnIndex - 1].value
                  .toString()
                  .compareTo(b.data[columnIndex - 1].value.toString()));
            }
          });
        },
      ),
      DataColumn(
        label: const Text('NAME'),
        onSort: (int columnIndex, bool ascending) {
          setState(() {
            if (columnIndex == 2) {
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
        label: const Text('CLASS'),
        onSort: (int columnIndex, bool ascending) {
          setState(() {
            if (columnIndex == 3) {
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
        label: const Text('SECTION'),
        onSort: (int columnIndex, bool ascending) {
          setState(
            () {
              if (columnIndex == 4) {
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
        label: Text('CONTACT'),
      ),
      const DataColumn(
        label: Text('ACTION'),
      ),
    ];

    widget.photoLabels.isNotEmpty
        ? columnName.add(
            DataColumn(
              label: Text(
                widget.students[0].photo
                    .firstWhere(
                        (element) =>
                            element.field.toUpperCase() ==
                            photoLabel.toUpperCase(),
                        orElse: () => Photo(field: photoLabel, value: "value"))
                    .field
                    .toUpperCase(),
              ),
            ),
          )
        : Container();

    // int getIndex(Student student, String field) {
    //   for (int i = 0; i < student.data.length; i++) {
    //     if (student.data[i].field == field) {
    //       return i;
    //     }
    //   }
    //   return 0;
    // }
    int getIndex(Student student, String field) {
      for (int i = 0; i < student.data.length; i++) {
        if (student.data[i].field == field) {
          return i + 1; // Start the index from 1
        }
      }
      return 0;
    }

    for (String label in widget.labels) {
      if (_isVisible[label] ?? false) {
        columnName.add(
          DataColumn(
            label: Text(label.toUpperCase()),
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
      deleteStudentPhoto,
      widget.schoolId,
      widget.labels,
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
                              items: List<fluent.MenuFlyoutItemBase>.generate(
                                widget.labels.length,
                                (index) => fluent.MenuFlyoutItem(
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
                    const SizedBox(
                      width: 10,
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
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    fluent.Button(
                        child: const Text("Filter"),
                        onPressed: () {
                          setState(() {
                            isFiltering = true;
                            filteredStudents =
                                _filter.text.toLowerCase().split(',').toList();
                          });
                        }),
                    const SizedBox(
                      width: 10,
                    ),
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
                              items: List<fluent.MenuFlyoutItemBase>.generate(
                                widget.classes.length,
                                (index) => fluent.MenuFlyoutItem(
                                  text: Text(widget.classes[index]),
                                  onPressed: () {
                                    studentController.filterClass.value =
                                        widget.classes[index];

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
                              items: List<fluent.MenuFlyoutItemBase>.generate(
                                widget.sections.length,
                                (index) => fluent.MenuFlyoutItem(
                                  text: Text(widget.sections[index]),
                                  onPressed: () {
                                    studentController.filterSection.value =
                                        widget.sections[index];
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
          checkboxHorizontalMargin: 30,
          key: tableKey,
          onPageChanged: (pageIndex) {
            setState(() {
              currentPageIndex = pageIndex;
            });
          },
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

            isSelected.updateAll((key, value) => value = selectedValue!);
            setState(() {
              isAllSelected = selectedValue!;
            });

            logger.d(isAllSelected);
          },
          source: data,
          header: Row(
            children: [
              const Text('STUDENTS'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget.labels.length <= 5
                    ? Container()
                    : SizedBox(
                        width: 150,
                        child: fluent.DropDownButton(
                          title: const Text('View Data'),
                          items: List<fluent.MenuFlyoutItemBase>.generate(
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
                                text: Text(_isVisible.keys
                                    .elementAt(index)
                                    .toUpperCase()),
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
                          items: List<fluent.MenuFlyoutItemBase>.generate(
                            widget.photoLabels.length,
                            (index) => fluent.MenuFlyoutItem(
                              text:
                                  Text(widget.photoLabels[index].toUpperCase()),
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
          dataRowHeight: MediaQuery.of(context).size.height / 16,
          showFirstLastButtons: true,
          rowsPerPage: min(10, widget.students.length),
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
  final Map<String, bool> isSelected;
  final Map<String, bool> _isVisible;
  final String photoLabel;
  final bool isFiltering;
  final List<String> filteredStudents;
  final String filterField;
  final String classFilter;
  final String sectionFilter;
  final String schoolId;
  String outputFile = '';
  final List<String> labels;

  String noPhoto =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/1024px-No_image_available.svg.png';

  final Function deleteFunction;
  final Function deleteStudentPhotoFunction;

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
      this.deleteStudentPhotoFunction,
      this.schoolId,
      this.labels) {
    bool resetIndex = false;
    bool ifFilter(Student student) {
      bool value = false;
      if (filterField == "") {
        for (var fields in _isVisible.keys) {
          if (fields == 'admno') {
            for (var element in filteredStudents) {
              if (student.admno.toLowerCase().contains(element.toLowerCase())) {
                value = true;
                break;
              }
            }
          } else if (fields == 'name') {
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
      if (filterField == 'admno') {
        for (var element in filteredStudents) {
          if (student.admno.toLowerCase().contains(element.toLowerCase())) {
            value = true;
            break;
          }
        }
      } else if (filterField == 'name') {
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

      // logger.i("Filtering ${student.name} $value");

      return value;
    }

    for (int index = 0; index < students.length; index++) {
      if (isFiltering && filteredStudents.isNotEmpty) {
        print('the data is');
        print(index.toString());
        print(resetIndex);
        if (!resetIndex) {
          index = 0;
          resetIndex = true;
        }
        if (index == students.length - 1) {
          resetIndex = false;
        }
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
        (index + 1).toString(),
        students[index].admno.toUpperCase(),
        students[index].name.toUpperCase(),
        students[index].studentClass.toUpperCase(),
        students[index].section.toUpperCase(),
        students[index].contact.toUpperCase(),
        ""
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
              .firstWhere(
                  (element) =>
                      element.field.toUpperCase() == label.toUpperCase(),
                  orElse: () => Datum(value: "", field: "No Value"))
              .value
              .toString());
        }
      }

      studentData.add(students[index].id);
      _data.add(studentData);
    }
  }
  Set<int> selectedRows = <int>{};
  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    return DataRow(
      key: ValueKey(_data[index].last),
      selected: isSelected[_data[index].last] ?? false,
      onSelectChanged: (value) {
        logger.d("Row Number $index");
        logger.d("Selected Row: $value");
        onSelected(_data[index].last, value!);

        logger.d("Previous Value--> ${isSelected[students[index].id]}");
        isSelected[students[index].id] = value;
      },
      cells: List<DataCell>.generate(_data[index].length - 1, (value) {
        if (value == 7 && photoLabel != "-1") {
          return DataCell(
            fluent.Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Image.network(_data[index][value]),
                          ),
                        );
                      },
                    );
                  },
                  onDoubleTap: () async {
                    // Download the image to the computer in downloads section

                    List<String> parts = _data[index][7].split('/');
                    String lastItem = parts.last;

                    if (outputFile.isEmpty) {
                      String? location = await FilePicker.platform.saveFile(
                        dialogTitle:
                            'Please select where you want to download the file at:',
                        fileName: lastItem,
                      );
                      outputFile = location ?? '';
                    }

                    String savePath = "$outputFile/idcardImages/$lastItem";

                    try {
                      await Dio().download(
                        _data[index][value],
                        savePath,
                      );
                    } on DioException catch (e) {
                      print(e.message);
                    } finally {}
                  },
                  child: fluent.Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Image.network(
                      _data[index][value],
                      height: 120,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                !_data[index][value].contains(DBConstants.photoURLInclude)
                    ? const SizedBox.shrink()
                    : IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return ConfirmDelete(
                                  type: "Student",
                                  name: _data[index][2].toUpperCase(),
                                  deleteDialogueFunction: () async {
                                    await deleteStudentPhotoFunction(
                                        _data[index][7], _data[index].last);
                                  },
                                  deletePhoto: true,
                                );
                              });
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
              ],
            ),
          );
        }

        return DataCell(
          onTap: value == 6
              ? null
              : () {
                  logger.d(students[index].id);
                  showDialog(
                    context: context,
                    builder: (context) => EditStudent(
                      studentId: _data[index].last,
                      schoolId: schoolId,
                      labels: labels,
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
                  _data[index][value].toString().toUpperCase(),
                  maxLines: 3,
                ),
              ),
              value == 6
                  ? IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return ConfirmDelete(
                                type: "Student",
                                name: _data[index][2].toUpperCase(),
                                deleteDialogueFunction: () async {
                                  await deleteFunction(_data[index].last);
                                },
                                deletePhoto: false,
                              );
                            });
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      }),
    );
  }
}
