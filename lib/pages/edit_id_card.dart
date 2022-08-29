import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/school_controller.dart';
import 'package:idcard_maker_frontend/models/id_card_generation_model.dart';
import 'package:idcard_maker_frontend/services/remote_services.dart';
import 'package:idcard_maker_frontend/widgets/generate_id_card.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:idcard_maker_frontend/widgets/preview_id_card.dart';
import '../controllers/student_controller.dart';
import '../models/id_card_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/route_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter/material.dart' as mat;
import 'package:google_fonts/google_fonts.dart';
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

  int editableIndex = -1;
  String _pickedColor = "0xFF000000";

  RemoteServices _remoteServices = RemoteServices();
  late StudentController _studentController;

  void updateEditIndex(int index, bool isChecked) {
    print("Update Edit Font:- ${_fontName}");
    if (isInit || !isChecked) {
      _fontSizeController.text = _idCard.labels[index].fontSize.toString();
      _pickedColor = _idCard.labels[index].color;
      _heightController.text = _idCard.labels[index].height.toString();
      _widthController.text = _idCard.labels[index].width.toString();
      _idCard.labels[index].fontName = _fontName;

      isInit = false;
    } else {
      _idCard!.labels[index].color = _pickedColor;
      _idCard!.labels[index].fontName = _fontName;
      _idCard!.labels[index].fontSize = int.parse(_fontSizeController.text);
    }

    setState(() {
      editableIndex = index;
    });
  }

  void _updatePostion(int pos, int x, int y, int height, int width) {
    setState(() {
      _idCard!.labels[pos].x = x as double;
      _idCard!.labels[pos].y = y as double;
    });
  }

  // void uploadForegroundImage() async {
  //   final result = await FilePicker.platform.pickFiles(allowMultiple: false);
  //   if (result == null) return;
  //   setState(() {
  //     frontfile = result.files.first;
  //     _idCard!.foregroundImagePath = frontfile.path.toString();
  //   });
  // }

  // void uploadBackgroundImage() async {
  //   final result = await FilePicker.platform.pickFiles(allowMultiple: false);
  //   if (result == null) return;
  //   setState(() {
  //     backfile = result.files.first;
  //     _idCard.backgroundImagePath = backfile.path.toString();
  //   });
  // }

  bool isLoading = true;

  void fetchIdCard() async {
    final idGenModel =
        await _remoteServices.getIdCardGenerationModel(widget.idCardId);

    _idCard = idGenModel.idcard;

    _studentController = Get.put(StudentController(_idCard.schoolId));

    // nonPhotoLabels = widget.labels.length;

    _idCard.labels.forEach((element) {
      dropDownButtons.add(
        MenuFlyoutItem(
          text: Text(element.title),
          onPressed: () {
            setState(() {
              print("Label Name--> ${element.title}");
              _idCard!.labels.add(
                Label(
                  title: element.title,
                  isPhoto: true,
                ),
              );
            });
          },
        ),
      );
    });
    setState(() {
      _idCard!.labels.forEach((label) {
        if (!label.isPhoto) {
          nonPhotoLabels++;
        }
      });

      isLoading = false;
    });
  }

  TextEditingController _titleController = TextEditingController();
  TextEditingController _fontSizeController = TextEditingController();
  TextEditingController _widthController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  String _fontName = 'Aldrich';
  String _alignment = 'left';
  double scaleFactor = 100.0;

  // Color _pickerColor = Color(0xffffffff);

  @override
  void initState() {
    // TODO: implement initState
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
          IconButton(
            icon: const Icon(FluentIcons.back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Edit ID Card',
              style: TextStyle(
                fontSize: 40,
                color: Colors.blue,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 100,
              child: Slider(
                max: 400.0,
                min: 100.0,
                value: scaleFactor,
                onChanged: (v) => setState(() => scaleFactor = v),
                // Label is the text displayed above the slider when the user is interacting with it.
                label: '${scaleFactor.toInt()}',
              ),
            ),
          ),
          Button(
              child: Text("Preview"),
              onPressed: () {
                if (_idCard != null) {
                  Navigator.of(context).push(
                    FluentPageRoute(
                      builder: (context) => PreviewIdCard(
                        idCard: _idCard,
                      ),
                    ),
                  );
                }

                // Navigator.of(context).push(

                // );
              }),
        ],
      ),
      content: isLoading
          ? Center(
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
                                  // Button(
                                  //   onPressed: uploadForegroundImage,
                                  //   child: const Text('Upload Front Image'),
                                  // ),
                                  SizedBox(
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
                                        SizedBox(
                                          width: 50,
                                        ),
                                        Image.memory(
                                          base64Decode(
                                              _idCard.foregroundImagePath),
                                          width: 80,
                                          height: 80,
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: SizedBox(
                            //     width: 400,
                            //     child: ToggleButton(
                            //       checked: _idCard.isPhoto,
                            //       onChanged: (value) {
                            //         setState(() {
                            //           _idCard.isPhoto = value;
                            //           _idCard.photoHeight = 51.0;
                            //           _idCard.photoWidth = 51.0;
                            //           _photoHeight.text = '51.0';
                            //           _photoWidth.text = '51.0';
                            //         });
                            //       },
                            //       child: const Text('Is Photo'),
                            //     ),
                            //   ),
                            // ),
                            // _idCard.isPhoto
                            //     ? Padding(
                            //         padding: const EdgeInsets.all(8.0),
                            //         child: Container(
                            //           width: 400,
                            //           child: Column(
                            //             children: [
                            //               TextBox(
                            //                 controller: _photoHeight,
                            //                 header: 'Photo Height',
                            //                 onChanged: (String value) {
                            //                   setState(() {
                            //                     _idCard.photoHeight =
                            //                         double.parse(value);
                            //                   });
                            //                 },
                            //               ),
                            //               TextBox(
                            //                 controller: _photoWidth,
                            //                 header: 'Photo Width',
                            //                 onChanged: (String value) {
                            //                   setState(() {
                            //                     _idCard.photoWidth =
                            //                         double.parse(value);
                            //                   });
                            //                 },
                            //               ),
                            //             ],
                            //           ),
                            //         ),
                            //       )
                            //     : Container(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text('Labels'),
                                // trailing: Button(
                                //   child: Icon(FluentIcons.add),
                                //   onPressed: () {
                                //     showDialog(
                                //       context: context,
                                //       builder: (BuildContext context) {
                                //         return ContentDialog(
                                //           title: Text('Welcome'),
                                //           content: SizedBox(
                                //             // height: 400,
                                //             width: 500,
                                //             child: Row(
                                //               children: [
                                //                 SizedBox(
                                //                   width: 150,
                                //                   child: Column(
                                //                     mainAxisSize: MainAxisSize.min,
                                //                     children: [
                                //                       SizedBox(
                                //                         child: TextBox(
                                //                           header: "Label Name",
                                //                           controller: _titleController,
                                //                         ),
                                //                       ),
                                //                       SizedBox(
                                //                         child: TextBox(
                                //                           header: "Font Size",
                                //                           controller:
                                //                               _fontSizeController,
                                //                         ),
                                //                       ),
                                //                     ],
                                //                   ),
                                //                 ),
                                //                 SizedBox(
                                //                   width: 150,
                                //                   height: 410,
                                //                   child: ColorPicker(
                                //                       colorPickerWidth: 150,
                                //                       portraitOnly: true,
                                //                       pickerColor: _pickerColor,
                                //                       onColorChanged: (color) {
                                //                         setState(() {
                                //                           _pickerColor = color;
                                //                         });
                                //                       }),
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //           actions: [
                                //             Button(
                                //               onPressed: () {
                                //                 Navigator.of(context).pop();
                                //               },
                                //               child: Text('CANCEL'),
                                //             ),
                                //             Button(
                                //               onPressed: () {
                                //                 String colorString = _pickerColor
                                //                     .toString(); // Color(0x12345678)
                                //                 String valueString = colorString
                                //                     .split('(0x')[1]
                                //                     .split(')')[0]; // kind of hacky..
                                //                 int value =
                                //                     int.parse(valueString, radix: 16);
                                //                 setState(() {
                                //                   _idCard.labels.add(
                                //                     Label(
                                //                       title: _titleController.text,
                                //                       fontSize: int.parse(
                                //                           _fontSizeController.text),
                                //                       color: valueString,
                                //                       x: 0,
                                //                       y: (_idCard.labels.length) * 50,
                                //                     ),
                                //                   );

                                //                   print(_idCard.labels.length);
                                //                   _titleController.clear();
                                //                   _fontSizeController.clear();
                                //                   Navigator.of(context).pop();
                                //                 });
                                //               },
                                //               child: Text('ACCEPT'),
                                //             ),
                                //           ],
                                //         );
                                //       },
                                //     );
                                //   },
                                // ),
                              ),
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
                                    if (_idCard.labels[index].isPhoto) {
                                      return Container();
                                    }
                                    return GestureDetector(
                                      onTap: () {
                                        // _fontSizeController.text =
                                        //     _idCard.labels[index].fontSize.toString();
                                        // _pickerColor = Color(
                                        //   int.parse(_idCard.labels[index].color,
                                        //       radix: 16),
                                        // );
                                        // _heightController.text =
                                        //     _idCard.labels[index].height.toString();
                                        // _widthController.text =
                                        //     _idCard.labels[index].width.toString();
                                        // setState(() {
                                        //   editableIndex = index;
                                        // });
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
                                          style: TextStyle(
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
                                                          .labels[index]
                                                          .isFront,
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
                                                          ? Text("On Front")
                                                          : Text("On Back"),
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

                                    // print(ind);
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
                                          style: TextStyle(
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
                                                          ? Text("On Front")
                                                          : Text("On Back"),
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

                                    _idCard.labels.forEach((label) {
                                      if (label.isPrinted && label.isPhoto) {
                                        photoColumns.add(label.title
                                            .toString()
                                            .toLowerCase());
                                      }
                                    });

                                    // print(idCardModelToJson(_idCard));
                                    // String idCardId =
                                    //     await _remoteServices.addIdCard(_idCard);
                                    // print(idCardId);

                                    RemoteServices().editIdCard(_idCard.labels,
                                        _idCard.id, _idCard.schoolId);

                                    // await _remoteServices.addStudentData(
                                    //     idCardId, widget.excelPath);

                                    // var pickedFile = await FilePicker.platform
                                    //     .pickFiles(
                                    //         allowMultiple: false,
                                    //         allowedExtensions: ['.zip']);

                                    // String? zipFile =
                                    //     pickedFile?.files.first.path.toString();

                                    // if (zipFile != null) {
                                    // await _remoteServices.uploadStudentPhotos(
                                    //   photoColumns,
                                    //   zipFile,
                                    //   widget.schoolId,
                                    // );
                                    // }

                                    Navigator.of(context).pop();

                                    // Navigator.of(context).push(
                                    //   FluentPageRoute(
                                    //     builder: (context) => GenerateIdCard(
                                    //         idCard: _idCard,
                                    //         updateIdCardPosition: _updatePostion),
                                    //   ),
                                    // );
                                    // Get.to(() => GenerateIdCard(
                                    //     idCard: _idCard,
                                    //     updateIdCardPosition: _updatePostion));
                                  },
                                  child: const Text('Edit and Save')),
                            ),

                            // SizedBox(
                            //   width: 300,
                            //   height: 100,
                            //   child: MaterialColorPicker(
                            //     onColorChange: (Color color) {
                            //       // Handle color changes
                            //     },
                            //     selectedColor: Colors.red,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: cheight,
                      child: GenerateIdCard(
                        idCard: _idCard,
                        updateIdCardPosition: _updatePostion,
                        updateEditIndex: updateEditIndex,
                        scaleFactor: scaleFactor,
                        isEdit: true,
                      ),
                    ),
                  ),
                  Container(
                    width: 400,
                    height: cheight,
                    child: editableIndex == -1
                        ? Center(
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
                                        : double.parse(_heightController.text);
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
                                        : double.parse(_widthController.text);
                                  });
                                },
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Selected Color",
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => ContentDialog(
                                          actions: [
                                            Button(
                                                child: Text("OK"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                }),
                                          ],
                                          title: Text('Select Color'),
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
                                      print('Helooooooo $_fontName');
                                      print(
                                          "Helloo3___${_idCard.labels[editableIndex].fontName}");
                                      print("Hiiiiiiiiiii");
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