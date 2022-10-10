import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';

import 'package:idcard_maker_frontend/services/remote_services.dart';
import 'package:idcard_maker_frontend/widgets/generate_id_card.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:idcard_maker_frontend/widgets/preview_id_card.dart';
import '../controllers/student_controller.dart';
import '../models/id_card_model.dart';

import 'package:flutter/material.dart' as mat;
import 'package:google_fonts/google_fonts.dart';

import '../models/student_model.dart';
import '../services/logger.dart';
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class EditIdCardPage extends StatefulWidget {
  final String idCardId;
  const EditIdCardPage({
    Key? key,
    required this.idCardId,
  }) : super(key: key);

  @override
  State<EditIdCardPage> createState() => _EditIdCardPageState();
}

class _EditIdCardPageState extends State<EditIdCardPage> {
  List<MenuFlyoutItem> dropDownButtons = [];
  String imagePath = '';
  var frontfile;
  var backfile;
  late IdCardModel _idCard;
  int nonPhotoLabels = 0;
  bool isInit = true;
  ScrollController horizontalScroll = ScrollController();
  ScrollController verticalScroll = ScrollController();

  int editableIndex = -1;
  String _pickedColor = "0xFF000000";

  final RemoteServices _remoteServices = RemoteServices();
  late StudentController _studentController;

  void updateEditIndex(int index, bool isChecked) {
    logger.d("Update Edit Font:- ${_fontName}");
    if (isInit || !isChecked) {
      _fontSizeController.text = _idCard.labels[index].fontSize.toString();
      _pickedColor = _idCard.labels[index].color;
      _heightController.text = _idCard.labels[index].height.toString();
      _widthController.text = _idCard.labels[index].width.toString();
      _idCard.labels[index].fontName = _fontName;

      isInit = false;
    } else {
      _idCard.labels[index].color = _pickedColor;
      _idCard.labels[index].fontName = _fontName;
      _idCard.labels[index].fontSize = int.parse(_fontSizeController.text);
    }

    setState(() {
      editableIndex = index;
    });
  }

  void _updatePostion(int pos, int x, int y, int height, int width) {
    setState(() {
      _idCard.labels[pos].x = x as double;
      _idCard.labels[pos].y = y as double;
    });
  }

  Student dummyStudent = Student(
    name: 'Dummy Name',
    contact: 'Dummy Contact',
    currentSchool: 'currentSchool',
    data: [],
    id: 'id',
    photo: [],
    section: 'section',
    studentClass: 'studentClass',
    username: 'username',
  );

  // Color _pickerColor = Color(0xffffffff);

  Future<void> getDummyStudent() async {
    await _studentController.fetchStudents(_idCard.schoolId);

    if (_studentController.students.value.students.isNotEmpty) {
      dummyStudent = _studentController.students.value.students[0];
    }

    logger.d("Dummy Student:- ${dummyStudent.name}");

    setState(() {
      for (var label in _idCard.labels) {
        if (!label.isPhoto) {
          nonPhotoLabels++;
        }
      }

      isLoading = false;
    });
  }

  bool isLoading = true;

  void fetchIdCard() async {
    final idGenModel =
        await _remoteServices.getIdCardGenerationModel(widget.idCardId);

    _idCard = idGenModel.idcard;

    _studentController = Get.put(StudentController(_idCard.schoolId));

    // nonPhotoLabels = widget.labels.length;

    for (var element in _idCard.labels) {
      dropDownButtons.add(
        MenuFlyoutItem(
          text: Text(element.title),
          onPressed: () {
            setState(() {
              logger.d("Label Name--> ${element.title}");
              _idCard.labels.add(
                Label(
                  title: element.title,
                  isPhoto: true,
                ),
              );
            });
          },
        ),
      );
    }

    await getDummyStudent();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _fontSizeController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _fontName = 'Aldrich';
  final String _alignment = 'left';
  double scaleFactor = 100.0;

  // Color _pickerColor = Color(0xffffffff);

  @override
  void initState() {
    fetchIdCard();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double cwidth = MediaQuery.of(context).size.width;
    double cheight = MediaQuery.of(context).size.height;

    return ScaffoldPage(
      header: Row(
        children: [
          Expanded(
              child: Container(
            color: Colors.red,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(FluentIcons.back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Text(
                  "Edit tour ID Card",
                ),
              ],
            ),
          ))
        ],
      ),

      // header: Row(
      //   children: [
      // IconButton(
      //   icon: const Icon(FluentIcons.back),
      //   onPressed: () {
      //     Navigator.of(context).pop();
      //   },
      // ),
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: Text(
      //         'Edit ID Card',
      //         style: TextStyle(
      //           fontSize: 40,
      //           color: Colors.blue,
      //         ),
      //       ),
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: SizedBox(
      //         width: 100,
      //         child: Slider(
      //           max: 400.0,
      //           min: 100.0,
      //           value: scaleFactor,
      //           onChanged: (v) => setState(() => scaleFactor = v),
      //           // Label is the text displayed above the slider when the user is interacting with it.
      //           label: '${scaleFactor.toInt()}',
      //         ),
      //       ),
      //     ),
      //     Button(
      //         child: const Text("Preview"),
      //         onPressed: () {
      //           if (_idCard != null) {
      //             Navigator.of(context).push(
      //               FluentPageRoute(
      //                 builder: (context) => PreviewIdCard(
      //                   idCard: _idCard,
      //                   isEdit: true,
      //                   dummyStudent: dummyStudent,
      //                 ),
      //               ),
      //             );
      //           }

      //           // Navigator.of(context).push(

      //           // );
      //         }),
      //   ],
      // ),
      content: isLoading
          ? const Center(
              child: ProgressRing(),
            )
          : Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 400,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 50,
                                  ),
                                  Image.memory(
                                    base64Decode(_idCard.foregroundImagePath),
                                    width: 80,
                                    height: 80,
                                  ),
                                ],
                              ),
                            ),
                            _idCard.isDual
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 50,
                                        ),
                                        Image.memory(
                                          base64Decode(
                                              _idCard.backgroundImagePath),
                                          width: 80,
                                          height: 80,
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text('Labels'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                controller: ScrollController(),
                                itemCount: _idCard.labels.length,
                                itemBuilder: (context, index) {
                                  if (_idCard.labels[index].isPhoto) {
                                    return Container();
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      updateEditIndex(index, false);
                                    },
                                    child: ListTile(
                                      leading: Checkbox(
                                        checked:
                                            _idCard.labels[index].isPrinted,
                                        onChanged: (value) {
                                          setState(() {
                                            _idCard.labels[index].isPrinted =
                                                !_idCard
                                                    .labels[index].isPrinted;
                                          });
                                          if (value ?? false) {
                                            // editableIndex = index;
                                            updateEditIndex(index, true);
                                          }
                                        },
                                      ),
                                      title: Text(
                                        _idCard.labels[index].title,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                      trailing: SizedBox(
                                        width: 200,
                                        child: Row(
                                          children: [
                                            _idCard.isDual
                                                ? ToggleSwitch(
                                                    checked: _idCard
                                                        .labels[index].isFront,
                                                    onChanged: (_) {
                                                      setState(() {
                                                        _idCard.labels[index]
                                                                .isFront =
                                                            !_idCard
                                                                .labels[index]
                                                                .isFront;
                                                      });
                                                    },
                                                    content: _idCard
                                                            .labels[index]
                                                            .isFront
                                                        ? const Text("On Front")
                                                        : const Text("On Back"),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            DropDownButton(
                              leading: const Icon(FluentIcons.add),
                              title: const Text('Add Photo Element'),
                              items: dropDownButtons,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                // height: 400,
                                // width: 200,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  controller: ScrollController(),
                                  itemCount: _idCard.labels.length,
                                  itemBuilder: (context, index) {
                                    // index = index + nonPhotoLabels;
                                    int ind = index;

                                    if (!_idCard.labels[ind].isPhoto) {
                                      return Container();
                                    }

                                    // logger.d(ind);
                                    return GestureDetector(
                                      onTap: () {
                                        // _fontSizeController.text =
                                        //     _idCard.labels[ind].fontSize.toString();
                                        // _pickerColor = Color(
                                        //   int.parse(_idCard.labels[ind].color,
                                        //       radix: 16),
                                        // );
                                        // _heightController.text =
                                        //     _idCard.labels[ind].height.toString();
                                        // _widthController.text =
                                        //     _idCard.labels[ind].width.toString();
                                        // setState(() {
                                        //   editableIndex = ind;
                                        // });
                                        updateEditIndex(ind, false);
                                      },
                                      child: ListTile(
                                        leading: Checkbox(
                                          checked:
                                              _idCard.labels[ind].isPrinted,
                                          onChanged: (value) {
                                            setState(() {
                                              _idCard.labels[ind].isPrinted =
                                                  !_idCard
                                                      .labels[ind].isPrinted;
                                            });

                                            if (value ?? false) {
                                              // editableIndex = ind;
                                              updateEditIndex(ind, true);
                                            }
                                          },
                                        ),
                                        title: Text(
                                          _idCard.labels[ind].title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xff000000),
                                          ),
                                        ),
                                        trailing: SizedBox(
                                          width: 200,
                                          child: Row(
                                            children: [
                                              _idCard.isDual
                                                  ? ToggleSwitch(
                                                      checked: _idCard
                                                          .labels[ind].isFront,
                                                      onChanged: (_) {
                                                        setState(() {
                                                          _idCard.labels[ind]
                                                                  .isFront =
                                                              !_idCard
                                                                  .labels[ind]
                                                                  .isFront;
                                                        });
                                                      },
                                                      content: _idCard
                                                              .labels[ind]
                                                              .isFront
                                                          ? const Text(
                                                              "On Front")
                                                          : const Text(
                                                              "On Back"),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Button(
                                  onPressed: () async {
                                    List<String> photoColumns = [];

                                    for (var label in _idCard.labels) {
                                      if (label.isPrinted && label.isPhoto) {
                                        photoColumns.add(label.title
                                            .toString()
                                            .toLowerCase());
                                      }
                                    }

                                    // logger.d(idCardModelToJson(_idCard));
                                    // String idCardId =
                                    //     await _remoteServices.addIdCard(_idCard);
                                    // logger.d(idCardId);

                                    RemoteServices().editIdCard(_idCard.labels,
                                        _idCard.id, _idCard.schoolId);

                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Edit and Save')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: verticalScroll,
                      child: Scrollbar(
                        controller: horizontalScroll,
                        child: SingleChildScrollView(
                          controller: horizontalScroll,
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            child: GenerateIdCard(
                              idCard: _idCard,
                              updateIdCardPosition: _updatePostion,
                              updateEditIndex: updateEditIndex,
                              scaleFactor: scaleFactor,
                              isEdit: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    height: cheight,
                    child: editableIndex == -1
                        ? const Center(
                            child: Text(
                              "Please Select a Label",
                            ),
                          )
                        : Column(
                            children: [
                              TextBox(
                                header: 'Font Size',
                                controller: _fontSizeController,
                                onChanged: (_) {
                                  setState(() {
                                    _idCard.labels[editableIndex]
                                        .fontSize = _fontSizeController
                                            .text.isEmpty
                                        ? 0
                                        : int.parse(_fontSizeController.text);
                                  });
                                },
                              ),
                              TextBox(
                                header: 'Height',
                                controller: _heightController,
                                onChanged: (_) {
                                  setState(() {
                                    _idCard.labels[editableIndex]
                                        .height = _heightController
                                            .text.isEmpty
                                        ? 0.0
                                        : double.parse(_heightController.text)
                                            .toPrecision(2);
                                  });
                                },
                              ),
                              TextBox(
                                header: 'Width',
                                controller: _widthController,
                                onChanged: (_) {
                                  setState(() {
                                    _idCard.labels[editableIndex]
                                        .width = _widthController
                                            .text.isEmpty
                                        ? 0.0
                                        : double.parse(_widthController.text)
                                            .toPrecision(2);
                                  });
                                },
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "Selected Color",
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => ContentDialog(
                                          actions: [
                                            Button(
                                                child: const Text("OK"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                }),
                                          ],
                                          title: const Text('Select Color'),
                                          content: mat.Card(
                                            child: ColorPicker(
                                              portraitOnly: true,
                                              onColorChanged: (Color color) {
                                                setState(() {
                                                  _pickedColor = color
                                                      .toString()
                                                      .split('(0x')[1]
                                                      .split(')')[0];
                                                  _idCard.labels[editableIndex]
                                                          .color =
                                                      color
                                                          .toString()
                                                          .split('(0x')[1]
                                                          .split(')')[0];
                                                });
                                              },
                                              pickerColor: Color(
                                                int.parse(
                                                  _idCard.labels[editableIndex]
                                                      .color,
                                                  radix: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Container(
                                        color: Color(
                                          int.parse(
                                            _idCard.labels[editableIndex].color,
                                            radix: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              mat.Card(
                                child: mat.DropdownButton(
                                  items: GoogleFonts.asMap()
                                      .map((key, value) {
                                        return MapEntry(
                                          key,
                                          mat.DropdownMenuItem<String>(
                                            value: key,
                                            child: Text(key),
                                          ),
                                        );
                                      })
                                      .values
                                      .toList(),
                                  value: _fontName,
                                  onChanged: (fontName) {
                                    setState(() {
                                      _fontName = fontName.toString();
                                      _idCard.labels[editableIndex].fontName =
                                          _fontName;
                                      logger.d('Helooooooo $_fontName');
                                      logger.d(
                                          "Helloo3___${_idCard.labels[editableIndex].fontName}");
                                      logger.d("Hiiiiiiiiiii");
                                    });
                                  },
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 25.0,
                                    child: Button(
                                      child: Container(
                                        height: 24,
                                        width: 24,
                                        color:
                                            FluentTheme.of(context).accentColor,
                                        child:
                                            const Icon(FluentIcons.align_left),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _idCard.labels[editableIndex]
                                              .textAlign = "left";
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25.0,
                                    child: Button(
                                      child: Container(
                                        height: 24,
                                        width: 24,
                                        color:
                                            FluentTheme.of(context).accentColor,
                                        child: const Icon(
                                            FluentIcons.align_center),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _idCard.labels[editableIndex]
                                              .textAlign = "center";
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25.0,
                                    child: Button(
                                      child: Container(
                                        height: 24,
                                        width: 24,
                                        color:
                                            FluentTheme.of(context).accentColor,
                                        child:
                                            const Icon(FluentIcons.align_right),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _idCard.labels[editableIndex]
                                              .textAlign = "right";
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  )
                ],
              ),
            ),
    );
  }
}
