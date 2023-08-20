import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/scheduler.dart';
import 'package:image/image.dart' as IMG;

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idcard_maker_frontend/models/id_card_attach_model.dart';
import 'package:idcard_maker_frontend/models/id_card_generation_model.dart';
import 'package:idcard_maker_frontend/models/student_model.dart';
import 'package:idcard_maker_frontend/services/remote_services.dart';
import 'package:screenshot/screenshot.dart';
import '../services/logger.dart';
import 'package:path/path.dart' as pathFun;

class GenerateIdCardList extends StatefulWidget {
  final String idCardId;
  final List<Student> students;
  final Map<String, bool> isSelected;

  const GenerateIdCardList({
    Key? key,
    required this.idCardId,
    required this.students,
    required this.isSelected,
  }) : super(key: key);

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
  int batchIndex = 0;
  int imageIndex = 0;

  late File errorFile = File('');
  String errors = "Errors While Generating ID Cards:\n";

  final RemoteServices _remoteServices = RemoteServices();
  late final IdCardAttachModel _idCardAttachModel = IdCardAttachModel(
    idCard: widget.idCardId,
    students: [],
  );

  List<int> foregroundImageBytes = [];
  List<int> backgroundImageBytes = [];
  List<String> errorList = [];
  double pixelRatio = 1.0;
  bool showImagePreview = true; // Track if preview should be shown

  Uint8List previewImageBytes = Uint8List(0); // Replace with actual image bytes

  Future<void> fetchIdCardGenerationModel() async {
    if (isStop) {
      return;
    }
    _idCardGenerationModel =
        await _remoteServices.getIdCardGenerationModel(widget.idCardId);
  }

  String getValue(Student student, bool isPhoto, String field) {
    if (isStop) {
      return '';
    }
    field = field.toLowerCase();

    String value = "";

    logger.d("<---Field --> $field $isPhoto <---${student.name}--->");

    if (isPhoto) {
      final photo = student.photo.firstWhere(
        (element) => element.field == field,
        orElse: () => Photo(field: field, value: "NullValue"),
      );

      value = 'http${photo.value.substring(5)}';
      logger.d("<---Photo --> $photo --->");
      logger.d("<---Photo --> $value --->");
    } else {
      switch (field) {
        case "name":
          value = student.name;
          break;
        case "contact":
          value = student.contact;
          break;
        case "class":
          value = student.studentClass;
          break;
        case "section":
          value = student.section;
          break;
        case "admno":
          value = student.admno;
          break;
        default:
          final dataField = student.data.firstWhere(
            (element) => element.field == field,
            orElse: () => Datum(field: '', value: ''),
          );
          value = dataField.value.toString();
          break;
      }
    }

    logger.d("Value--> $value");
    return value;
  }

  Widget frontWidget = const SizedBox(
    height: 1.0,
  );

  Future<void> chooseOutputPath() async {
    String? outputFile;
    String? outputPath;
    if (isStop) {
      return;
    }

    if (Platform.isWindows) {
      outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output destination:',
        fileName: "1",
      );
      outputPath = outputFile?.substring(0, outputFile.lastIndexOf("\\") + 1);
    } else if (Platform.isMacOS) {
      outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output destination:',
        fileName: "1",
      );
      outputPath = outputFile?.substring(0, outputFile.lastIndexOf("/") + 1);
    }

    setState(() {
      _outputPath.text = outputPath!;
    });

    errorFile = File('${_outputPath.text}error.txt');

    Directory destinationFolder = Directory('${outputPath}front');
    logger.d(destinationFolder.toString());
    if (await destinationFolder.exists()) {
      frontPath = destinationFolder.path;
    } else {
      await destinationFolder.create(recursive: true);
      frontPath = destinationFolder.path;
    }

    setState(() {
      frontPath = destinationFolder.path;
    });
    logger.d('the output path is ---->  $frontPath');

    destinationFolder = Directory('${outputPath}back');
    if (await destinationFolder.exists()) {
      backPath = destinationFolder.path;
    } else {
      await destinationFolder.create(recursive: true);
      backPath = destinationFolder.path;
    }

    setState(() {
      backPath = backPath;
    });
    logger.d('the output path is ---->  $backPath');
  }

  Uint8List resizeImage(Uint8List data) {
    if (isStop) {
      return data;
    }
    Uint8List? resizedData = data;
    IMG.Image? img = IMG.decodeImage(data);
    IMG.Image resized = IMG.copyResize(
      img!,
      width: img.width * (pixelRatio / 10) * double.parse(_dpi.text) ~/ 100,
      height: img.height * (pixelRatio / 10) * double.parse(_dpi.text) ~/ 100,
    );
    resizedData = Uint8List.fromList(IMG.encodeJpg(resized));
    return resizedData;
  }

  Future<void> captureScreenshotAndPreview(
    Widget idCard,
    String path,
    String fileImage,
  ) async {
    try {
      if (isStop) {
        return;
      }
      Uint8List pngBytes = await screenshotController.captureFromWidget(
        idCard,
        pixelRatio: 10,
        delay: const Duration(
          milliseconds: 200,
        ),
      );

      pngBytes = resizeImage(pngBytes);
      path = '$path/';
      if (Platform.isMacOS) {
        path = '$path/';
        fileImage = pathFun.joinAll(fileImage.split('/'));
        fileImage = fileImage.replaceAll('/', '\\');
      }
      setState(() {
        previewImageBytes = pngBytes;
      });
      await File('$path$fileImage.jpeg').writeAsBytes(pngBytes);
      logger.d("SS Png Captured --> $path$fileImage.jpeg");
      // Display the preview image widget
    } catch (e, stackTrace) {
      logger.e("Error capturing screenshot: $e\n$stackTrace");
      logger.e("ID Card Gen Error $fileImage --> $e");
      errors += "ID Card Gen Error $fileImage\n";
      errorList.add("ID Card Gen Error $fileImage: $e");
    }
  }

  List<List<T>> splitList<T>(List<T> list, int batchSize) {
    final result = <List<T>>[];
    final length = list.length;
    if (isStop) {
      return result;
    }

    for (var i = 0; i < length; i += batchSize) {
      if (isStop) {
        return result;
      }
      final end = (i + batchSize < length) ? i + batchSize : length;
      result.add(list.sublist(i, end));
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
      _dpi.text = '600';
    });

    () async {
      await chooseOutputPath();
      await fetchIdCardGenerationModel();
      ByteData tempImage = await NetworkAssetBundle(
              Uri.parse(_idCardGenerationModel.idcard.foregroundImagePath))
          .load(_idCardGenerationModel.idcard.foregroundImagePath);
      Uint8List audioUint8List = tempImage.buffer
          .asUint8List(tempImage.offsetInBytes, tempImage.lengthInBytes);
      foregroundImageBytes = audioUint8List.cast<int>();
      previewImageBytes = audioUint8List;

      if (_idCardGenerationModel.idcard.isDual) {
        ByteData tempImage = (await NetworkAssetBundle(
                Uri.parse(_idCardGenerationModel.idcard.backgroundImagePath))
            .load(_idCardGenerationModel.idcard.backgroundImagePath));
        Uint8List audioUint8List = tempImage.buffer
            .asUint8List(tempImage.offsetInBytes, tempImage.lengthInBytes);
        backgroundImageBytes = audioUint8List.cast<int>();
      }

      totalCount = widget.students
          .where((student) => widget.isSelected[student.id] == true)
          .length;

      setState(() {
        _isLoading = false;
      });
    }();
  }

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
          const Text(
            "Generating your ID Cards",
            style: TextStyle(
              fontSize: 40,
            ),
          ),
        ],
      ),
      content: _isLoading
          ? const Center(
              child: ProgressRing(),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                          child: totalCount > 0 &&
                                  (currentCount / totalCount) <= 1
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                        Container(
                          width: _idCardGenerationModel.idcard.width,
                          height: _idCardGenerationModel.idcard.height,
                          margin: const EdgeInsets.all(20),
                          child: Image.memory(
                            Uint8List.fromList(previewImageBytes),
                            fit: BoxFit.contain,
                          ),
                        ),
                        if (!_isGenerating)
                          Button(
                            onPressed: () async {
                              await runGenerationLogic();
                              if (isStop) {
                                setState(() {
                                  isStop = false;
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 350,
                                      child: TextBox(
                                        placeholder:
                                            'DPI of the ID Card to be generated:- ',
                                        controller: _dpi,
                                      ),
                                    ),
                                  ),
                                  const Center(child: Text("Generate")),
                                ],
                              ),
                            ),
                          )
                        else
                          currentCount >= totalCount
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      isStop
                                          ? "Some ID Cards were generated successfully"
                                          : "All ID Cards generated successfully !",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 200,
                                      child: ListView.builder(
                                        itemCount: errorList.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(errorList[index]),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 100,
                                          child: Center(
                                              child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              !isStop
                                                  ? Text(
                                                      "Generating ... $currentCount/$totalCount and $imageIndex  and $batchIndex ",
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  : Text(
                                                      "Skipping ... $currentCount/$totalCount",
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                            ],
                                          )),
                                        ),
                                        Button(
                                            child:
                                                const Text("Stop Generating"),
                                            onPressed: () {
                                              setState(() {
                                                isStop = true;
                                              });
                                            }),
                                      ],
                                    ),
                                  ],
                                ),
                      ],
                    ),
                  ),
                ),
                // Expanded(
                //   flex: 2,
                //   child: frontWidget,
                // ),
              ],
            ),
    );
  }

  Future<void> runGenerationLogic() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final imageMap = <String, List<int>>{};
      final labelList = <Widget>[];
      final labelBackList = <Widget>[];

      final selectedStudents = widget.students
          .where((student) => widget.isSelected[student.id]!)
          .toList();
      final totalCount = selectedStudents.length;

      for (final student in selectedStudents) {
        if (isStop) {
          break;
        }

        await Future.wait(student.photo.map((photo) async {
          final tempImage = await NetworkAssetBundle(Uri.parse(photo.value))
              .load(photo.value);
          final imageBuffer = tempImage.buffer.asUint8List();
          imageMap[photo.field] = imageBuffer;
        }));
        // Clear label lists for each student
        labelList.clear();
        labelBackList.clear();

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
              height: _idCardGenerationModel.idcard.height,
              child: Image.memory(
                Uint8List.fromList(backgroundImageBytes),
                fit: BoxFit.fill,
              ),
            ),
          );
        }

        // ... (rest of your label and widget creation code)
        for (final label in _idCardGenerationModel.idcard.labels) {
          if (isStop) {
            break;
          }
          // ... (your label processing logic)

          final isPrinted = label.isPrinted &&
              (!label.isFront || !_idCardGenerationModel.idcard.isDual);
          final isFront =
              label.isFront || !_idCardGenerationModel.idcard.isDual;

          if (isPrinted && isFront) {
            labelList.add(
              Positioned(
                top: label.y.toDouble(),
                left: label.x.toDouble(),
                child: Container(
                  height: label.height.toDouble(),
                  width: label.width.toDouble(),
                  decoration: BoxDecoration(
                    image: label.isPhoto
                        ? DecorationImage(
                            image: MemoryImage(
                              Uint8List.fromList(
                                  imageMap[label.title.toLowerCase()]!),
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: label.isPhoto
                      ? Container()
                      : Text(
                          getValue(student, label.isPhoto, label.title),
                          textAlign: label.textAlign == "left"
                              ? TextAlign.left
                              : label.textAlign == "right"
                                  ? TextAlign.right
                                  : TextAlign.center,
                          style: GoogleFonts.asMap()[label.fontName]!(
                            color: Color(int.parse(label.color, radix: 16)),
                            fontSize: label.fontSize.toDouble(),
                            fontWeight: label.isBold
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontStyle: label.isItalic
                                ? FontStyle.italic
                                : FontStyle.normal,
                            decoration: label.isUnderline
                                ? TextDecoration.underline
                                : TextDecoration.none,
                          ),
                        ),
                ),
              ),
            );
          } else if (isPrinted) {
            labelBackList.add(
              Positioned(
                top: label.y.toDouble(),
                left: label.x.toDouble(),
                child: Container(
                  height: label.height.toDouble(),
                  width: label.width.toDouble(),
                  decoration: BoxDecoration(
                    image: label.isPhoto
                        ? DecorationImage(
                            image: NetworkImage(
                                getValue(student, label.isPhoto, label.title)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: label.isPhoto
                      ? Container()
                      : Text(
                          getValue(student, label.isPhoto, label.title),
                          style: TextStyle(
                            fontSize: label.fontSize.toDouble(),
                            color: Color(int.parse(label.color, radix: 16)),
                          ),
                        ),
                ),
              ),
            );
          }
        }

        // Create the frontWidget and backWidget
        final frontWidget = SizedBox(
          height: _idCardGenerationModel.idcard.height.toDouble(),
          width: _idCardGenerationModel.idcard.width.toDouble(),
          child: Stack(children: labelList),
        );

        final backWidget = _idCardGenerationModel.idcard.isDual
            ? Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                child: RepaintBoundary(
                  // key: globalBackKey,
                  child: SizedBox(
                    height: _idCardGenerationModel.idcard.height.toDouble(),
                    width: _idCardGenerationModel.idcard.width.toDouble(),
                    child: Stack(children: labelBackList),
                  ),
                ),
              )
            : Container();

        // Capture screenshots and show preview
        await captureScreenshotAndPreview(
          frontWidget,
          frontPath,
          student.username,
        );

        if (_idCardGenerationModel.idcard.isDual) {
          await captureScreenshotAndPreview(
            backWidget,
            backPath,
            student.username,
          );
        }

        // Add the student to _idCardAttachModel
        _idCardAttachModel.students.add(student);

        setState(() {
          imageIndex++;
          currentCount++;
        });
      }

      // Attach ID cards and update UI
      await errorFile.writeAsString(errors);
      await _remoteServices.attachIDCard(_idCardAttachModel);

      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          currentCount = totalCount;
          _isGenerating = false; // Set generating flag to false
        });
      });
      errorFile.writeAsString(errors);
    } catch (e, stackTrace) {
      logger.e("ID Card Gen Error: $e\n$stackTrace");
      // Handle the error
      setState(() {
        _isGenerating = false; // Set generating flag to false
      });
    }
  }
}
