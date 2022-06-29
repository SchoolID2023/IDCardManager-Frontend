import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/widgets/generate_id_card.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/id_card_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/route_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class AddIdCardPage extends StatefulWidget {
  final List<Label> labels;
  final bool isDual;
  final double idCardWidth;
  final double idCardHeight;
  final String excelPath;
  const AddIdCardPage({
    Key? key,
    required this.labels,
    required this.isDual,
    required this.idCardWidth,
    required this.idCardHeight,
    required this.excelPath,
  }) : super(key: key);

  @override
  State<AddIdCardPage> createState() => _AddIdCardPageState();
}

class _AddIdCardPageState extends State<AddIdCardPage> {
  List<MenuFlyoutItem> dropDownButtons = [];
  String imagePath = '';
  var frontfile;
  var backfile;
  var _idCard;
  int nonPhotoLabels = 0;

  int editableIndex = -1;

  void _updatePostion(int pos, int x, int y) {
    setState(() {
      _idCard.labels[pos].x = x;
      _idCard.labels[pos].y = y;
    });
  }

  void uploadForegroundImage() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    setState(() {
      frontfile = result.files.first;
      _idCard.foregroundImagePath = frontfile.path.toString();
    });
  }

  void uploadBackgroundImage() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    setState(() {
      backfile = result.files.first;
      _idCard.backgroundImagePath = backfile.path.toString();
    });
  }

  TextEditingController _titleController = TextEditingController();
  TextEditingController _fontSizeController = TextEditingController();
  TextEditingController _widthController = TextEditingController();
  TextEditingController _heightController = TextEditingController();

  Color _pickerColor = Color(0xffffffff);

  @override
  void initState() {
    // TODO: implement initState
    _idCard = IdCardModel(
      labels: widget.labels,
      isDual: widget.isDual,
      width: widget.idCardWidth,
      height: widget.idCardHeight,
      foregroundImagePath: "",
    );

    nonPhotoLabels = widget.labels.length;

    widget.labels.forEach((element) {
      dropDownButtons.add(
        MenuFlyoutItem(
          text: Text(element.title),
          onPressed: () {
            setState(() {
              print("Label Name--> ${element.title}");
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
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double cwidth = MediaQuery.of(context).size.width;
    double cheight = MediaQuery.of(context).size.height;

    return ScaffoldPage(
      header: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Add ID Card',
          style: TextStyle(
            fontSize: 40,
            color: Colors.blue,
          ),
        ),
      ),
      content: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 400,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Button(
                            onPressed: uploadForegroundImage,
                            child: const Text('Upload Front Image'),
                          ),
                          SizedBox(
                            width: 50,
                          ),
                          frontfile == null
                              ? const Text('No file selected')
                              : Image.file(
                                  File(
                                    frontfile.path.toString(),
                                  ),
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
                                Button(
                                  onPressed: uploadBackgroundImage,
                                  child: const Text('Upload Back Image'),
                                ),
                                SizedBox(
                                  width: 50,
                                ),
                                backfile == null
                                    ? const Text('No file selected')
                                    : Image.file(
                                        File(
                                          backfile.path.toString(),
                                        ),
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
                          itemCount: nonPhotoLabels,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                _fontSizeController.text =
                                    _idCard.labels[index].fontSize.toString();
                                _pickerColor = Color(
                                  int.parse(_idCard.labels[index].color,
                                      radix: 16),
                                );
                                _heightController.text =
                                    _idCard.labels[index].height.toString();
                                _widthController.text =
                                    _idCard.labels[index].width.toString();
                                setState(() {
                                  editableIndex = index;
                                });
                              },
                              child: ListTile(
                                leading: Checkbox(
                                  checked: _idCard.labels[index].isPrinted,
                                  onChanged: (value) {
                                    setState(() {
                                      _idCard.labels[index].isPrinted =
                                          !_idCard.labels[index].isPrinted;
                                    });
                                  },
                                ),
                                title: Text(
                                  _idCard.labels[index].title,
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
                                              checked:
                                                  _idCard.labels[index].isFront,
                                              onChanged: (_) {
                                                setState(() {
                                                  _idCard.labels[index]
                                                          .isFront =
                                                      !_idCard.labels[index]
                                                          .isFront;
                                                });
                                              },
                                              content:
                                                  _idCard.labels[index].isFront
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
                          itemCount: _idCard.labels.length - nonPhotoLabels,
                          itemBuilder: (context, index) {
                            // index = index + nonPhotoLabels;
                            int ind = index + nonPhotoLabels;
                            print(ind);
                            return GestureDetector(
                              onTap: () {
                                _fontSizeController.text =
                                    _idCard.labels[ind].fontSize.toString();
                                _pickerColor = Color(
                                  int.parse(_idCard.labels[ind].color,
                                      radix: 16),
                                );
                                _heightController.text =
                                    _idCard.labels[ind].height.toString();
                                _widthController.text =
                                    _idCard.labels[ind].width.toString();
                                setState(() {
                                  editableIndex = ind;
                                });
                              },
                              child: ListTile(
                                leading: Checkbox(
                                  checked: _idCard.labels[ind].isPrinted,
                                  onChanged: (value) {
                                    setState(() {
                                      _idCard.labels[ind].isPrinted =
                                          !_idCard.labels[ind].isPrinted;
                                    });
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
                                              checked:
                                                  _idCard.labels[ind].isFront,
                                              onChanged: (_) {
                                                setState(() {
                                                  _idCard.labels[ind].isFront =
                                                      !_idCard
                                                          .labels[ind].isFront;
                                                });
                                              },
                                              content:
                                                  _idCard.labels[ind].isFront
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
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Button(
                    //       onPressed: () {
                    //         Navigator.of(context).push(
                    //           FluentPageRoute(
                    //             builder: (context) => GenerateIdCard(
                    //                 idCard: _idCard,
                    //                 updateIdCardPosition: _updatePostion),
                    //           ),
                    //         );
                    //         // Get.to(() => GenerateIdCard(
                    //         //     idCard: _idCard,
                    //         //     updateIdCardPosition: _updatePostion));
                    //       },
                    //       child: const Text('Save')),
                    // ),

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
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: frontfile != null
                    ? backfile != null || backfile == null && !_idCard.isDual
                        ? Container(
                            height: cheight,
                            child: GenerateIdCard(
                              idCard: _idCard,
                              updateIdCardPosition: _updatePostion,
                            ),
                          )
                        : Container()
                    : Container(),
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
                          onEditingComplete: () {
                            setState(() {
                              _idCard.labels[editableIndex].fontSize =
                                  int.parse(_fontSizeController.text);
                            });
                          },
                        ),
                        TextBox(
                          header: 'Height',
                          controller: _heightController,
                          onEditingComplete: () {
                            setState(() {
                              _idCard.labels[editableIndex].height =
                                  int.parse(_heightController.text);
                            });
                          },
                        ),
                        TextBox(
                          header: 'Width',
                          controller: _widthController,
                          onEditingComplete: () {
                            setState(() {
                              _idCard.labels[editableIndex].width =
                                  int.parse(_widthController.text);
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
                                    content: SingleChildScrollView(
                                      child: MaterialColorPicker(
                                        onColorChange: (Color color) {
                                          setState(() {
                                            _idCard.labels[editableIndex]
                                                    .color =
                                                color
                                                    .toString()
                                                    .split('(0x')[1]
                                                    .split(')')[0];
                                          });
                                        },
                                        selectedColor: Color(
                                          int.parse(
                                            _idCard.labels[editableIndex].color,
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
                            )
                          ],
                        )
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }
}
