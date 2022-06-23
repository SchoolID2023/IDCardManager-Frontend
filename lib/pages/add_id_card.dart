import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/widgets/generate_id_card.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double cwidth = MediaQuery.of(context).size.width;
    double cheight = MediaQuery.of(context).size.height;

    TextEditingController _titleController = TextEditingController();
    TextEditingController _fontSizeController = TextEditingController();

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
                  Row(
                    children: [
                      Text('Add Title'),
                      const SizedBox(
                        width: 8.0,
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Welcome'),
                                content: SizedBox(
                                  height: 400,
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: _titleController,
                                      ),
                                      TextField(
                                        controller: _fontSizeController,
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
                                      setState(() {
                                        _idCard.labels.add(
                                          Label(
                                            title: _titleController.text,
                                            fontSize: int.parse(
                                                _fontSizeController.text),
                                            color: 0xff000000,
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
                    ],
                  ),
                  Container(
                    height: 400,
                    width: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _idCard.labels.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_idCard.labels[index].title),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {},
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
          ],
        ),
      ),
    );
  }
}
