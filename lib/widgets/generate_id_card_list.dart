import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
// import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idcard_maker_frontend/models/id_card_attach_model.dart';
import 'package:idcard_maker_frontend/models/id_card_generation_model.dart';
import 'package:idcard_maker_frontend/models/student_model.dart';
import 'package:idcard_maker_frontend/services/remote_services.dart';
import 'package:screenshot/screenshot.dart';
import '../services/logger.dart';
import 'dart:ui' as ui;

class GenerateIdCardList extends StatefulWidget {
  final String idCardId;
  final List<Student> students;
  final Map<String, bool> isSelected;
  const GenerateIdCardList(
      {Key? key,
      required this.idCardId,
      required this.students,
      required this.isSelected})
      : super(key: key);

  @override
  State<GenerateIdCardList> createState() => _GenerateIdCardListState();
}

class _GenerateIdCardListState extends State<GenerateIdCardList> {
  late IdCardGenerationModel _idCardGenerationModel;
  final TextEditingController _outputPath = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();
  bool _isLoading = true;
  bool _isGenerating = false;

  String frontPath = "";
  String backPath = "";

  int totalCount = 0;
  int currentCount = 0;
  bool isStop = false;

  final RemoteServices _remoteServices = RemoteServices();
  late IdCardAttachModel _idCardAttachModel;

  void fetchIdCardGenerationModel() async {
    _idCardGenerationModel =
        await _remoteServices.getIdCardGenerationModel(widget.idCardId);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    chooseOutputPath();

    fetchIdCardGenerationModel();

    for (var student in widget.students) {
      if (widget.isSelected[student.id] == true) {
        totalCount++;
      }
    }
    super.initState();

    _idCardAttachModel = IdCardAttachModel(
      idCard: widget.idCardId,
      students: widget.students,
    );
  }

  String getValue(Student student, bool isPhoto, String field) {
    field = field.toLowerCase();

    String value = "";

    logger.d("<---Field --> $field $isPhoto <---${student.name}--->");
    if (isPhoto) {
      // field = field.substring(0, field.length - 6);

      value = student.photo
          .firstWhere(
            (element) => element.field == field,
            orElse: () => Photo(field: field, value: "NullValue"),
          )
          .value;

      value = 'http${value.substring(5)}';
    } else {
      if (field == "name") {
        value = student.name;
      } else if (field == "contact") {
        value = student.contact;
      } else if (field == "class") {
        value = student.studentClass;
      } else if (field == "section") {
        value = student.section;
      } else {
        logger.i("Student Data else section-> ${field}");
        value = student.data
            .firstWhere((element) => element.field == field,
                orElse: () => student.data[0])
            .value
            .toString();
      }
    }

    logger.d("Value--> $value");
    return value;
  }

  Future<void> chooseOutputPath() async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output destination:',
      fileName: "1",
    );
    outputFile = outputFile?.substring(0, outputFile.lastIndexOf("\\") + 1);
    logger.d(outputFile);

    setState(() {
      _outputPath.text = outputFile!;
    });

    Directory destinationFolder = Directory('${outputFile}front');
    if (await destinationFolder.exists()) {
      frontPath = destinationFolder.path;
    } else {
      await destinationFolder.create(recursive: true);
      frontPath = destinationFolder.path;
    }

    destinationFolder = Directory('${outputFile}back');
    if (await destinationFolder.exists()) {
      backPath = destinationFolder.path;
    } else {
      await destinationFolder.create(recursive: true);
      backPath = destinationFolder.path;
    }
  }

  Future<void> capturePng(GlobalKey key, String path, String fileImage) async {
    final RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    await File('$path\\$fileImage.png').writeAsBytes(pngBytes);

    logger.d("Png Captured --> $path\\$fileImage.png");
  }

  Future<void> captureScreenshot(
      Widget idCard, String path, String fileImage) async {
    final Uint8List pngBytes = await screenshotController.captureFromWidget(
      idCard,
      pixelRatio: 3.0,
    );

    await File('$path\\$fileImage.png').writeAsBytes(pngBytes);
    logger.d("SS Png Captured --> $path\\$fileImage.png");
  }

  final Widget _widget = const Text("Start");

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Row(
        children: [
          Button(
              child: const Icon(FluentIcons.arrow_tall_up_left),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          Text(
            "Generating your ID Cards",
            style: TextStyle(
              fontSize: 40,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      content: _isLoading
          ? const Center(
              child: ProgressRing(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Output Folder:- ${_outputPath.text}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Total ID Cards to be exported :- $totalCount",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    child: totalCount > 0 && (currentCount / totalCount) <= 1
                        ? Row(
                            children: [
                              ProgressBar(
                                value: (currentCount / totalCount) * 100,
                              ),
                              Text(
                                "$currentCount/$totalCount",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                  if (!_isGenerating)
                    Button(
                      onPressed: (() async {
                        setState(() {
                          _isGenerating = true;
                        });

                        // await Future.forEach<Student>(widget.students,
                        //     (student) async {

                        for (Student student in widget.students) {
                          if (isStop) {
                            break;
                          }

                          if (widget.isSelected[student.id]!) {
                            logger.d(
                                "-=------>   ${student.name} ${student.contact} ${student.studentClass}");
                            GlobalKey globalFrontKey = GlobalKey();
                            GlobalKey globalBackKey = GlobalKey();
                            final labelList = <Widget>[];
                            final labelBackList = <Widget>[];

                            Map<String, List<int>> imageMap = {};

                            for (int i = 0; i < student.photo.length; i++) {
                              ByteData tempImage = (await NetworkAssetBundle(
                                      Uri.parse(student.photo[i].value))
                                  .load(student.photo[i].value));
                              Uint8List audioUint8List = tempImage.buffer
                                  .asUint8List(tempImage.offsetInBytes,
                                      tempImage.lengthInBytes);
                              imageMap[student.photo[i].field] =
                                  audioUint8List.cast<int>();
                              logger.d(student.photo[i].field);
                            }

                            for (int i = 0;
                                i < _idCardGenerationModel.idcard.labels.length;
                                i++) {
                              if (_idCardGenerationModel
                                  .idcard.labels[i].isPhoto) {
                                logger.d(
                                    "Photo--> ${_idCardGenerationModel.idcard.labels[i].title}");
                              }
                            }
                            labelList.add(
                              SizedBox(
                                width: _idCardGenerationModel.idcard.width,
                                height: _idCardGenerationModel.idcard.height,
                                child: Image.memory(
                                  base64Decode(
                                    _idCardGenerationModel
                                        .idcard.foregroundImagePath,
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            );

                            if (_idCardGenerationModel.idcard.isDual) {
                              labelBackList.add(
                                SizedBox(
                                  width: _idCardGenerationModel.idcard.width,
                                  height: _idCardGenerationModel.idcard.height,
                                  child: Image.memory(
                                    base64Decode(
                                      _idCardGenerationModel
                                          .idcard.backgroundImagePath,
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              );
                            }

                            for (int i = 0;
                                i < _idCardGenerationModel.idcard.labels.length;
                                i++) {
                              if (_idCardGenerationModel
                                      .idcard.labels[i].isPrinted &&
                                  _idCardGenerationModel
                                      .idcard.labels[i].isFront) {
                                labelList.add(
                                  Positioned(
                                    top: _idCardGenerationModel
                                        .idcard.labels[i].y
                                        .toDouble(),
                                    left: _idCardGenerationModel
                                        .idcard.labels[i].x
                                        .toDouble(),
                                    child: Container(
                                      height: _idCardGenerationModel
                                          .idcard.labels[i].height
                                          .toDouble(),
                                      width: _idCardGenerationModel
                                          .idcard.labels[i].width
                                          .toDouble(),
                                      decoration: BoxDecoration(
                                        image: _idCardGenerationModel
                                                .idcard.labels[i].isPhoto
                                            ? DecorationImage(
                                                // image: NetworkImage(
                                                //   getValue(
                                                //     student,
                                                //     _idCardGenerationModel
                                                //         .idcard
                                                //         .labels[i]
                                                //         .isPhoto,
                                                // _idCardGenerationModel
                                                //     .idcard.labels[i].title,
                                                //   ),
                                                // ),
                                                image: MemoryImage(
                                                  Uint8List.fromList(imageMap[
                                                      _idCardGenerationModel
                                                          .idcard
                                                          .labels[i]
                                                          .title
                                                          .toLowerCase()]!),
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: _idCardGenerationModel
                                              .idcard.labels[i].isPhoto
                                          ? Container()
                                          : Text(
                                              textAlign: _idCardGenerationModel
                                                          .idcard
                                                          .labels[i]
                                                          .textAlign ==
                                                      "left"
                                                  ? TextAlign.left
                                                  : _idCardGenerationModel
                                                              .idcard
                                                              .labels[i]
                                                              .textAlign ==
                                                          "right"
                                                      ? TextAlign.right
                                                      : TextAlign.center,
                                              getValue(
                                                student,
                                                _idCardGenerationModel
                                                    .idcard.labels[i].isPhoto,
                                                _idCardGenerationModel
                                                    .idcard.labels[i].title,
                                              ),
                                              //
                                              style: GoogleFonts.asMap()[
                                                  _idCardGenerationModel.idcard
                                                      .labels[i].fontName]!(
                                                color: Color(
                                                  int.parse(
                                                    _idCardGenerationModel
                                                        .idcard.labels[i].color,
                                                    radix: 16,
                                                  ),
                                                ),
                                                fontSize: _idCardGenerationModel
                                                    .idcard.labels[i].fontSize
                                                    .toDouble(),
                                                fontWeight: _idCardGenerationModel
                                                    .idcard.labels[i].isBold
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                fontStyle: _idCardGenerationModel
                                                    .idcard.labels[i].isItalic
                                                    ? FontStyle.italic
                                                    : FontStyle.normal,
                                                decoration: _idCardGenerationModel
                                                    .idcard.labels[i].isUnderline
                                                    ? TextDecoration.underline
                                                    : TextDecoration.none,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              } else if (_idCardGenerationModel
                                  .idcard.labels[i].isPrinted) {
                                labelBackList.add(
                                  Positioned(
                                    top: _idCardGenerationModel
                                        .idcard.labels[i].y
                                        .toDouble(),
                                    left: _idCardGenerationModel
                                        .idcard.labels[i].x
                                        .toDouble(),
                                    child: Container(
                                      height: _idCardGenerationModel
                                          .idcard.labels[i].height
                                          .toDouble(),
                                      width: _idCardGenerationModel
                                          .idcard.labels[i].width
                                          .toDouble(),
                                      decoration: BoxDecoration(
                                        image: _idCardGenerationModel
                                                .idcard.labels[i].isPhoto
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  getValue(
                                                    student,
                                                    _idCardGenerationModel
                                                        .idcard
                                                        .labels[i]
                                                        .isPhoto,
                                                    _idCardGenerationModel
                                                        .idcard.labels[i].title,
                                                  ),
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: _idCardGenerationModel
                                              .idcard.labels[i].isPhoto
                                          ? Container()
                                          : Text(
                                              getValue(
                                                student,
                                                _idCardGenerationModel
                                                    .idcard.labels[i].isPhoto,
                                                _idCardGenerationModel
                                                    .idcard.labels[i].title,
                                              ),
                                              style: TextStyle(
                                                fontSize: _idCardGenerationModel
                                                    .idcard.labels[i].fontSize
                                                    .toDouble(),
                                                color: Color(
                                                  int.parse(
                                                    _idCardGenerationModel
                                                        .idcard.labels[i].color,
                                                    radix: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              }
                            }

                            Widget frontWidget = Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              child: SizedBox(
                                height: _idCardGenerationModel.idcard.height
                                    .toDouble(),
                                width: _idCardGenerationModel.idcard.width
                                    .toDouble(),
                                child: Stack(children: labelList),
                              ),
                            );

                            Widget backWidget = _idCardGenerationModel
                                    .idcard.isDual
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                    child: RepaintBoundary(
                                      key: globalBackKey,
                                      child: SizedBox(
                                        height: _idCardGenerationModel
                                            .idcard.height
                                            .toDouble(),
                                        width: _idCardGenerationModel
                                            .idcard.width
                                            .toDouble(),
                                        child: Stack(children: labelBackList),
                                      ),
                                    ),
                                  )
                                : Container();

                            logger.d(
                                "FrontKey : ${globalFrontKey.currentState.toString()}");
                            logger.d(
                                "BackKey : ${globalBackKey.currentState.toString()}");

                            // await capturePng(
                            //     _globalFrontKey, "front", student.username);
                            await captureScreenshot(
                                frontWidget, "front", student.username);
                            if (_idCardGenerationModel.idcard.isDual) {
                              await captureScreenshot(
                                  backWidget, "back", student.username);
                            }
                          }

                          setState(() {
                            currentCount++;
                          });

                          // if (_idCardGenerationModel.idcard.isDual) {
                          //   await capturePng(
                          //       _globalBackKey, "back", student.username);
                          // }
                        }

                        await _remoteServices.attachIDCard(_idCardAttachModel);
                      }),
                      child: const Center(
                        child: const Text("Generate"),
                      ),
                    )
                  else
                    currentCount >= totalCount
                        ? Container(
                            child: Text(
                              "All ID Cards generated successfully !",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              Container(
                                height: 100,
                                child: Center(
                                  child: Text(
                                    "Generating... $currentCount/$totalCount",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Button(
                                  child: const Text("Stop Genrating"),
                                  onPressed: () {
                                    setState(() {
                                      isStop = true;
                                    });
                                  })
                            ],
                          ),
                ],
              ),
            ),
    );
  }
}
