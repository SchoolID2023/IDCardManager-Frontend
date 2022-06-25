import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/widgets/generate_id_card.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/id_card_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/route_manager.dart';

class AddIdCardPage extends StatefulWidget {
  const AddIdCardPage({Key? key}) : super(key: key);

  @override
  State<AddIdCardPage> createState() => _AddIdCardPageState();
}

class _AddIdCardPageState extends State<AddIdCardPage> {
  String imagePath = '';
  var file;
  final _idCard =
      IdCardModel(labels: [], backgroundImagePath: "", isPhoto: false);

  void _updatePostion(int pos, int x, int y) {
    setState(() {
      _idCard.labels[pos].x = x;
      _idCard.labels[pos].y = y;
    });
  }

  void uploadImage() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return;

    setState(() {
      file = result.files.first;
      _idCard.backgroundImagePath = file.path.toString();
    });

    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    print(result.files.first.name);
    print(result.files.first.size);
    print(result.files.first.path);
    print(result.files.first.runtimeType);

    // imagePath = await FilePicker.getFilePath(type: FileType.image);
  }

  TextEditingController _titleController = TextEditingController();
  TextEditingController _fontSizeController = TextEditingController();
  TextEditingController _photoWidth = TextEditingController();
  TextEditingController _photoHeight = TextEditingController();

  Color _pickerColor = Color(0xffffffff);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double cwidth = MediaQuery.of(context).size.width;
    double cheight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Id Card'),
      ),
      body: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 400,
                child: Column(
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: uploadImage,
                          child: const Text('Upload Image'),
                        ),
                        file == null
                            ? const Text('No file selected')
                            : Image.file(
                                File(
                                  file.path.toString(),
                                ),
                                width: 80,
                                height: 80,
                              ),
                      ],
                    ),
                    SizedBox(
                      width: 400,
                      child: SwitchListTile(
                        value: _idCard.isPhoto,
                        onChanged: (value) {
                          setState(() {
                            _idCard.isPhoto = value;
                            _idCard.photoHeight = 51.0;
                            _idCard.photoWidth = 51.0;
                            _photoHeight.text = '51.0';
                            _photoWidth.text = '51.0';
                          });
                        },
                        title: const Text('Is Photo'),
                      ),
                    ),
                    _idCard.isPhoto
                        ? Container(
                            width: 400,
                            child: Column(
                              children: [
                                TextField(
                                  controller: _photoHeight,
                                  decoration: const InputDecoration(
                                    labelText: 'Photo Height',
                                  ),
                                  onChanged: (String value) {
                                    setState(() {
                                      _idCard.photoHeight = double.parse(value);
                                    });
                                  },
                                ),
                                TextField(
                                  controller: _photoWidth,
                                  decoration: const InputDecoration(
                                    labelText: 'Photo Width',
                                  ),
                                  onChanged: (String value) {
                                    setState(() {
                                      _idCard.photoWidth = double.parse(value);
                                    });
                                  },
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    ListTile(
                      title: Text('Add Title'),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Welcome'),
                                content: SizedBox(
                                  // height: 400,
                                  width: 375,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              child: TextField(
                                                decoration: InputDecoration(
                                                  label: Text("label Name"),
                                                ),
                                                controller: _titleController,
                                              ),
                                            ),
                                            SizedBox(
                                              child: TextField(
                                                decoration: InputDecoration(
                                                  label: Text("Font Size"),
                                                ),
                                                controller: _fontSizeController,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        height: 310,
                                        child: ColorPicker(
                                            colorPickerWidth: 150,
                                            portraitOnly: true,
                                            pickerColor: _pickerColor,
                                            onColorChanged: (color) {
                                              setState(() {
                                                _pickerColor = color;
                                              });
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  FlatButton(
                                    textColor: Colors.black,
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text('CANCEL'),
                                  ),
                                  FlatButton(
                                    textColor: Colors.black,
                                    onPressed: () {
                                      String colorString = _pickerColor
                                          .toString(); // Color(0x12345678)
                                      String valueString = colorString
                                          .split('(0x')[1]
                                          .split(')')[0]; // kind of hacky..
                                      int value =
                                          int.parse(valueString, radix: 16);
                                      setState(() {
                                        _idCard.labels.add(
                                          Label(
                                            title: _titleController.text,
                                            fontSize: int.parse(
                                                _fontSizeController.text),
                                            color: valueString,
                                            x: 0,
                                            y: (_idCard.labels.length) * 50,
                                          ),
                                        );
                                        print(_idCard.labels.length);
                                        _titleController.clear();
                                        _fontSizeController.clear();
                                        Get.back();
                                      });
                                    },
                                    child: Text('ACCEPT'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      // height: 400,
                      // width: 200,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _idCard.labels.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _idCard.labels[index].title,
                              style: TextStyle(
                                fontSize:
                                    _idCard.labels[index].fontSize.toDouble(),
                                color: Color(
                                  int.parse(_idCard.labels[index].color,
                                      radix: 16),
                                ),
                              ),
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          _titleController.text =
                                              _idCard.labels[index].title;
                                          _fontSizeController.text = _idCard
                                              .labels[index].fontSize
                                              .toString();
                                          _pickerColor = Color(
                                            int.parse(
                                                _idCard.labels[index].color,
                                                radix: 16),
                                          );
                                          return AlertDialog(
                                            title: Text('Welcome'),
                                            content: SizedBox(
                                              // height: 400,
                                              width: 375,
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 150,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        SizedBox(
                                                          child: TextField(
                                                            decoration:
                                                                InputDecoration(
                                                              label: Text(
                                                                  "label Name"),
                                                            ),
                                                            controller:
                                                                _titleController,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          child: TextField(
                                                            decoration:
                                                                InputDecoration(
                                                              label: Text(
                                                                  "Font Size"),
                                                            ),
                                                            controller:
                                                                _fontSizeController,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 200,
                                                    height: 310,
                                                    child: ColorPicker(
                                                        colorPickerWidth: 150,
                                                        portraitOnly: true,
                                                        pickerColor:
                                                            _pickerColor,
                                                        onColorChanged:
                                                            (color) {
                                                          setState(() {
                                                            _pickerColor =
                                                                color;
                                                          });
                                                        }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              FlatButton(
                                                textColor: Colors.black,
                                                onPressed: () {
                                                  Get.back();
                                                },
                                                child: Text('CANCEL'),
                                              ),
                                              FlatButton(
                                                textColor: Colors.black,
                                                onPressed: () {
                                                  String colorString = _pickerColor
                                                      .toString(); // Color(0x12345678)
                                                  String valueString =
                                                      colorString
                                                              .split('(0x')[1]
                                                              .split(')')[
                                                          0]; // kind of hacky..
                                                  int value = int.parse(
                                                      valueString,
                                                      radix: 16);
                                                  setState(() {
                                                    _idCard.labels[index]
                                                            .title =
                                                        _titleController.text;
                                                    _idCard.labels[index]
                                                            .fontSize =
                                                        int.parse(
                                                            _fontSizeController
                                                                .text);
                                                    _idCard.labels[index]
                                                        .color = valueString;
                                                    _idCard.labels[index].x = 0;
                                                    _idCard.labels[index].y =
                                                        index * 50;
                                                    Get.back();
                                                  });
                                                },
                                                child: Text('ACCEPT'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        _idCard.labels.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Get.to(() => GenerateIdCard(
                              idCard: _idCard,
                              updateIdCardPosition: _updatePostion));
                        },
                        child: const Text('Save')),
                  ],
                ),
              ),
            ),
            // Container(
            //   width: cwidth * 0.5,
            //   height: cheight,
            //   child: GenerateIdCard(
            //     idCard: _idCard,
            //     updateIdCardPosition: _updatePostion,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
