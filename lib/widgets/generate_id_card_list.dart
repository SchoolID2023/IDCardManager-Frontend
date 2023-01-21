import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as IMG;

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
  final TextEditingController _dpi = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();

  bool _isLoading = true;
  bool _isGenerating = false;

  String frontPath = "";
  String backPath = "";

  int totalCount = 0;
  int currentCount = 0;
  bool isStop = false;

  late File errorFile;
  String errors = "Errors While Generating ID Cards:\n";

  final RemoteServices _remoteServices = RemoteServices();
  late IdCardAttachModel _idCardAttachModel;

  List<Student> idCardGeneratedStudent = [];

  List<int> foregroundImageBytes = [];
  List<int> backgroundImageBytes = [];

  Future<void> fetchIdCardGenerationModel() async {
    _idCardGenerationModel =
        await _remoteServices.getIdCardGenerationModel(widget.idCardId);
    setState(() {
      _isLoading = false;
    });
  }

  double pixelRatio = 1.0;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
      _dpi.text = '600';
    });

    () async {
      await chooseOutputPath();
      await fetchIdCardGenerationModel();
      ByteData tempImage = (await NetworkAssetBundle(
              Uri.parse(_idCardGenerationModel.idcard.foregroundImagePath))
          .load(_idCardGenerationModel.idcard.foregroundImagePath));
      Uint8List audioUint8List = tempImage.buffer
          .asUint8List(tempImage.offsetInBytes, tempImage.lengthInBytes);
      foregroundImageBytes = audioUint8List.cast<int>();

      if (_idCardGenerationModel.idcard.isDual) {
        ByteData tempImage = (await NetworkAssetBundle(
                Uri.parse(_idCardGenerationModel.idcard.backgroundImagePath))
            .load(_idCardGenerationModel.idcard.backgroundImagePath));
        Uint8List audioUint8List = tempImage.buffer
            .asUint8List(tempImage.offsetInBytes, tempImage.lengthInBytes);
        backgroundImageBytes = audioUint8List.cast<int>();
      }
    }();

    for (var student in widget.students) {
      if (widget.isSelected[student.id] == true) {
        totalCount++;
      }
    }
    super.initState();

    _idCardAttachModel = IdCardAttachModel(
      idCard: widget.idCardId,
      students: [],
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

    errorFile = File('${_outputPath.text}error.txt');

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
    var dpi = 300;
    pngBytes[13] = 1;
    pngBytes[14] = (dpi >> 8);
    pngBytes[15] = (dpi & 0xff);
    pngBytes[16] = (dpi >> 8);
    pngBytes[17] = (dpi & 0xff);
    await File('$path\\$fileImage.png').writeAsBytes(pngBytes);

    logger.d("Png Captured --> $path\\$fileImage.png");
  }

  Uint8List resizeImage(Uint8List data) {
    Uint8List? resizedData = data;
    IMG.Image? img = IMG.decodeImage(data);
    IMG.Image resized = IMG.copyResize(
      img!,
      width: img.width * double.parse(_dpi.text) ~/ 100,
      height: img.height * double.parse(_dpi.text) ~/ 100,
    );
    resizedData = Uint8List.fromList(IMG.encodeJpg(resized));
    return resizedData;
  }

  Future<void> captureScreenshot(
      Widget idCard, String path, String fileImage) async {
    Uint8List pngBytes = await screenshotController.captureFromWidget(
      idCard,
      pixelRatio: pixelRatio,
    );
    // var dpi = 300;
    // pngBytes[13] = 1;
    // pngBytes[14] = (dpi >> 8);
    // pngBytes[15] = (dpi & 0xff);
    // pngBytes[16] = (dpi >> 8);
    // pngBytes[17] = (dpi & 0xff);

    pngBytes = resizeImage(pngBytes);

    await File('$path\\$fileImage.jpeg').writeAsBytes(pngBytes);
    logger.d("SS Png Captured --> $path\\$fileImage.jpeg");
  }

  final Widget _widget = const Text("Start");
  Widget frontWidget = const SizedBox(
    height: 1.0,
  );

  int index = 0;

  @override
  Widget build(BuildContext context) {
    pixelRatio = MediaQuery.of(context).devicePixelRatio;
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
                            try {
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
                                  i <
                                      _idCardGenerationModel
                                          .idcard.labels.length;
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
                                    Uint8List.fromList(foregroundImageBytes),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              );

                              if (_idCardGenerationModel.idcard.isDual) {
                                labelBackList.add(
                                  SizedBox(
                                    width: _idCardGenerationModel.idcard.width,
                                    height:
                                        _idCardGenerationModel.idcard.height,
                                    child: Image.memory(
                                      Uint8List.fromList(backgroundImageBytes),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                );
                              }

                              for (int i = 0;
                                  i <
                                      _idCardGenerationModel
                                          .idcard.labels.length;
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
                                                    _idCardGenerationModel
                                                        .idcard
                                                        .labels[i]
                                                        .fontName]!(
                                                  color: Color(
                                                    int.parse(
                                                      _idCardGenerationModel
                                                          .idcard
                                                          .labels[i]
                                                          .color,
                                                      radix: 16,
                                                    ),
                                                  ),
                                                  fontSize:
                                                      _idCardGenerationModel
                                                          .idcard
                                                          .labels[i]
                                                          .fontSize
                                                          .toDouble(),
                                                  fontWeight:
                                                      _idCardGenerationModel
                                                              .idcard
                                                              .labels[i]
                                                              .isBold
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                  fontStyle:
                                                      _idCardGenerationModel
                                                              .idcard
                                                              .labels[i]
                                                              .isItalic
                                                          ? FontStyle.italic
                                                          : FontStyle.normal,
                                                  decoration:
                                                      _idCardGenerationModel
                                                              .idcard
                                                              .labels[i]
                                                              .isUnderline
                                                          ? TextDecoration
                                                              .underline
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
                                                          .idcard
                                                          .labels[i]
                                                          .title,
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
                                                  fontSize:
                                                      _idCardGenerationModel
                                                          .idcard
                                                          .labels[i]
                                                          .fontSize
                                                          .toDouble(),
                                                  color: Color(
                                                    int.parse(
                                                      _idCardGenerationModel
                                                          .idcard
                                                          .labels[i]
                                                          .color,
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

                              frontWidget = SizedBox(
                                height: _idCardGenerationModel.idcard.height
                                    .toDouble(),
                                width: _idCardGenerationModel.idcard.width
                                    .toDouble(),
                                child: Stack(children: labelList),
                              );

                              // frontWidget = Stack(children: labelList);

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

                              logger.d(
                                  "Height and Width : ${_idCardGenerationModel.idcard.height} ${_idCardGenerationModel.idcard.width}");

                              // await capturePng(
                              //     _globalFrontKey, "front", student.username);
                              await captureScreenshot(
                                  frontWidget, "front", student.username);
                              if (_idCardGenerationModel.idcard.isDual) {
                                await captureScreenshot(
                                    backWidget, "back", student.username);
                              }

                              _idCardAttachModel.students.add(student);
                            } catch (e) {
                              logger.e(
                                  "ID Card Gen Error ${student.name} --> $e");
                              errors += "ID Card Gen Error ${student.name}\n";
                              // TODO
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
                        errorFile.writeAsString(errors);
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 350,
                                child: TextBox(
                                  header: 'DPI of the ID Card to be generated:- ',
                                  controller: _dpi,
                                ),
                              ),
                            ),                          
                            const Center(child:  Text("Generate")),
                          ],
                        ),
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
                        : SingleChildScrollView(
                            child: Column(
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
                                    }),
                                frontWidget,
                              ],
                            ),
                          ),
                ],
              ),
            ),
    );
  }
}
