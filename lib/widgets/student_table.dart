import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:idcard_maker_frontend/services/remote_services.dart';
import 'package:idcard_maker_frontend/widgets/student_dialog.dart';
import '../services/logger.dart';

import '../models/student_model.dart';

class StudentTable extends StatefulWidget {
  final List<Student> students;
  final List<String> classes;
  final List<String> sections;
  final Map<String, bool> isSelected;
  final Function(String, bool) onSelected;

  StudentTable({
    Key? key,
    required this.students,
    required this.isSelected,
    required this.onSelected,
    required this.classes,
    required this.sections,
  }) : super(key: key);

  @override
  State<StudentTable> createState() => _StudentTableState();
}

class _StudentTableState extends State<StudentTable> {
  bool isAllSelected = false;
  int photoIndex = -1;
  bool isFiltering = false;
  int filterIndex = -1;
  String classFilter = 'All';
  String sectionFilter = 'All';
  TextEditingController _filter = TextEditingController();

  Set<String> filteredStudents = Set<String>();

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

  Map<int, bool> _isVisible = <int, bool>{};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    logger.d("Length-> ${widget.students[0].data.length}");

    for (int i = 0; i < widget.students[0].data.length; i++) {
      _isVisible[i] = false;
      // logger.d("Field--> ${widget.students[0].data[i].field}");
    }
  }

  @override
  Widget build(BuildContext context) {
    isSelected.value = widget.isSelected;

    List<DataColumn> _columnName = [
      DataColumn(
        label: Text('S. No.'),
        onSort: (int columnIndex, bool ascending) {
          setState(() {
            if (columnIndex == 0) {
              widget.students.sort((a, b) => a.id.compareTo(b.id));
            } else {
              widget.students.sort((a, b) => a.data[columnIndex - 1].value
                  .toString()
                  .compareTo(b.data[columnIndex - 1].value.toString()));
            }
          });
        },
      ),
      DataColumn(
        label: Text('Name'),
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
        label: Text('Class'),
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
        label: Text('Section'),
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
      DataColumn(
        label: Text('Contact'),
      ),
    ];

    if (photoIndex != -1) {
      _columnName.add(
        DataColumn(
          label: Text(
            widget.students[0].photo[photoIndex].field,
          ),
        ),
      );
    }

    for (int i = 0; i < widget.students[0].data.length; i++) {
      // logger.d("Field--> ${element.field}");

      if (_isVisible[i] ?? false) {
        _columnName.add(
          DataColumn(
            label: Text(widget.students[0].data[i].field),
            onSort: (int columnIndex, bool ascending) {
              setState(() {
                if (true) {
                  widget.students.sort((a, b) => a.data[i].value
                      .toString()
                      .compareTo(b.data[i].value.toString()));
                } else {
                  // widget.students.sort((a, b) => a.data[columnIndex - 1].value
                  //     .toString()
                  //     .compareTo(b.data[columnIndex - 1].value.toString()));
                  logger.d(columnIndex);
                  logger.d(i);
                }
              });
            },
          ),
        );
      }

      // DataColumn(
      //   label: Text(
      //     widget.students[0].data[i].field,
      //   ),
      // ),

    }
    final DataTableSource _data = MyData(
      widget.students,
      context,
      onSelectingRow,
      isSelected,
      _isVisible,
      photoIndex,
      isFiltering,
      filteredStudents,
      filterIndex,
      classFilter,
      sectionFilter,
    );
    return SizedBox(
      width: _columnName.length * 150,
      child: fluent.Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: fluent.Column(
              children: [
                fluent.Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: fluent.DropDownButton(
                          title: filterIndex != -1
                              ? Text(widget.students[0].data[filterIndex].field)
                              : Text('Search Data by'),
                          items: List<fluent.MenuFlyoutItem>.generate(
                            widget.students[0].data.length,
                            (index) => fluent.MenuFlyoutItem(
                              // leading: fluent.Checkbox(
                              //   checked: _isVisible[index] ?? false,
                              //   onChanged: (value) {
                              //     setState(() {
                              //       _isVisible[index] = !(_isVisible[index] ?? false);
                              //     });
                              //   },
                              // ),
                              text: Text(widget.students[0].data[index].field),
                              onPressed: () {
                                setState(() {
                                  filterIndex = index;
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
                        ),
                      ),
                      fluent.Button(
                          child: Text("Filter"),
                          onPressed: () {
                            setState(() {
                              isFiltering = true;
                              filteredStudents =
                                  _filter.text.split(',').toSet();
                              logger.d(filteredStudents);
                            });
                          }),
                      fluent.Button(
                          child: Text("Clear Filter"),
                          onPressed: () {
                            setState(() {
                              isFiltering = false;
                              _filter.clear();

                              filteredStudents = Set<String>();
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
                        child: fluent.DropDownButton(
                          title: classFilter != 'All'
                              ? Text('Students of Class ' +
                                  classFilter.toUpperCase())
                              : Text('All Classes'),
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
                        child: fluent.DropDownButton(
                          title: sectionFilter != 'All'
                              ? Text('Students of Section ' +
                                  sectionFilter.toUpperCase())
                              : Text('All Sections'),
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
                  ],
                ),
              ],
            ),
          ),
          PaginatedDataTable(
            onSelectAll: (selectedValue) {
              for (var student in widget.students) {
                widget.onSelected(student.id, selectedValue!);
              }

              isSelected.value
                  .updateAll((key, value) => value = selectedValue!);
              setState(() {
                isAllSelected = selectedValue!;
              });

              logger.d(isAllSelected);
            },
            sortColumnIndex: 2,
            source: _data,
            header: Row(
              children: [
                Text('Students'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 150,
                    child: fluent.DropDownButton(
                      title: Text('View Data'),
                      items: List<fluent.MenuFlyoutItem>.generate(
                        widget.students[0].data.length,
                        (index) => fluent.MenuFlyoutItem(
                          leading: fluent.Checkbox(
                            checked: _isVisible[index] ?? false,
                            onChanged: (value) {
                              setState(() {
                                _isVisible[index] =
                                    !(_isVisible[index] ?? false);
                              });
                            },
                          ),
                          text: Text(widget.students[0].data[index].field),
                          onPressed: () {
                            setState(() {
                              _isVisible[index] = !(_isVisible[index] ?? false);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                widget.students[0].photo.length == 0
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 150,
                          child: fluent.DropDownButton(
                            title: Text('View Photo'),
                            items: List<fluent.MenuFlyoutItem>.generate(
                              widget.students[0].photo.length,
                              (index) => fluent.MenuFlyoutItem(
                                text:
                                    Text(widget.students[0].photo[index].field),
                                onPressed: () {
                                  setState(() {
                                    photoIndex = index;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            columns: _columnName,
            columnSpacing: 50,
            horizontalMargin: 10,
            rowsPerPage: isFiltering
                ? min(10, filteredStudents.length)
                : min(10, widget.students.length),
            showCheckboxColumn: true,
          ),
        ],
      ),
    );
  }
}

class MyData extends DataTableSource {
  final List<Student> students;
  final Function(String, bool) onSelected;
  final ValueNotifier<Map<String, bool>> isSelected;
  final Map<int, bool> _isVisible;
  final int photoIndex;
  final bool isFiltering;
  final Set<String> filteredStudents;
  final int filterIndex;
  final String classFilter;
  final String sectionFilter;

  BuildContext context;
  List<List<String>> _data = [];
  MyData(
    this.students,
    this.context,
    this.onSelected,
    this.isSelected,
    this._isVisible,
    this.photoIndex,
    this.isFiltering,
    this.filteredStudents,
    this.filterIndex,
    this.classFilter,
    this.sectionFilter,
  ) {
    for (int index = 0; index < students.length; index++) {
      if (isFiltering && filteredStudents.isNotEmpty) {
        if (!filteredStudents
            .contains(students[index].data[filterIndex].value.toString())) {
          logger.d(
              "##-> ${students[index].data[filterIndex].value} -- ${filteredStudents}");
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

      List<String> _studentData = [
        index.toString(),
        students[index].name,
        students[index].studentClass,
        students[index].section,
        students[index].contact
      ];

      if (photoIndex != -1 && students[index].photo.length > photoIndex) {
        _studentData.add(students[index].photo[photoIndex].value);
      } else if (photoIndex != -1) {
        _studentData.add(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/1024px-No_image_available.svg.png');
      }

      for (int i = 0; i < students[index].data.length; i++) {
        if (_isVisible[i] ?? false) {
          _studentData.add(students[index].data[i].value.toString());
        }
      }

      _data.add(_studentData);
    }

    // _data = List.generate(
    //   students.length,
    //   (index) {

    //     List<String> _studentData = [
    //       index.toString(),
    //       students[index].name,
    //       students[index].studentClass,
    //       students[index].section,
    //       students[index].contact
    //     ];

    //     if (photoIndex != -1) {
    //       _studentData.add(students[index].photo[photoIndex].value);
    //     }

    //     for (int i = 0; i < students[index].data.length; i++) {
    //       if (_isVisible[i] ?? false) {
    //         _studentData.add(students[index].data[i].value.toString());
    //       }
    //     }

    //     return _studentData;

    //     // "id": index,
    //     // "name": students[index].name,
    //     // "class": students[index].studentClass,
    //     // "section": students[index].section,
    //     // "contact": students[index].contact,
    //   },
    // );
  }

  // Generate some made-up data

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
      cells: List<DataCell>.generate(_data[index].length, (value) {
        if (value == 5 && photoIndex != -1) {
          return DataCell(
            Image.network(
              _data[index][value],
              height: 100,
              width: 100,
            ),
          );
        }

        return DataCell(
          // showEditIcon: value == 0 ? true : false,
          onTap: () {
            logger.d(students[index].id);
            showDialog(
              context: context,
              builder: (context) => StudentDialog(
                student: students[index],
              ),
            );
          },
          Text(
            _data[index][value].toString(),
          ),
        );
      }),
    );
  }
}
