import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as IMG;

import '../models/id_card_generation_model.dart';
import '../models/student_model.dart';
import '../services/logger.dart';
import '../services/remote_services.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
class ImageGenerationIsolate {
  static Future<void> generateImages(
    List<Student> students,
    Map<String, bool> isSelected,
    String dpi,
    String outputPath,
    String frontPath,
    String backPath,
    String foregroundImagePath,
    String backgroundImagePath,
    SendPort sendPort,
    IdCardGenerationModel idCardGenerationModel,
  ) async {
    final imageMap = <String, List<int>>{};
    final labelList = <Widget>[];
    final labelBackList = <Widget>[];
    
    
    String getValue(Student student, bool isPhoto, String field) {
      field = field.toLowerCase();

      String value = "";

      logger.d("<---Field --> $field $isPhoto <---${student.name}--->");
      if (isPhoto) {
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

    try {
      final foregroundImageBytes = await _loadImageBytes(foregroundImagePath);
      Uint8List? backgroundImageBytes;
      if (backgroundImagePath.isNotEmpty) {
        backgroundImageBytes = await _loadImageBytes(backgroundImagePath);
      }

      for (final student in students) {
        if (isSelected[student.id] == true) {
          for (int i = 0; i < student.photo.length; i++) {
            final photo = student.photo[i];
            
final photoResponse =
                await http.get(Uri.parse(photo.value));
            // final photoBytes = await _loadImageBytes(photo.value);
            final photoBytes =  photoResponse.bodyBytes;
            imageMap[photo.field] = photoBytes;
          }

          labelList.clear();
          labelList.add(
            SizedBox(
              width: idCardGenerationModel.idcard.width,
              height: idCardGenerationModel.idcard.height,
              child: Image.memory(
                Uint8List.fromList(foregroundImageBytes!),
                fit: BoxFit.fill,
              ),
            ),
          );

          if (idCardGenerationModel.idcard.isDual &&
              backgroundImageBytes != null) {
            labelBackList.clear();
            labelBackList.add(
              SizedBox(
                width: idCardGenerationModel.idcard.width,
                height: idCardGenerationModel.idcard.height,
                child: Image.memory(
                  backgroundImageBytes,
                  fit: BoxFit.fill,
                ),
              ),
            );
          }

          for (final label in idCardGenerationModel.idcard.labels) {
            final isPrinted = label.isPrinted &&
                (!label.isFront || !idCardGenerationModel.idcard.isDual);
            final isFront =
                label.isFront || !idCardGenerationModel.idcard.isDual;

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
                              image: MemoryImage(Uint8List.fromList(
                                  imageMap[label.title.toLowerCase()]!)),
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
                              color: Color(int.parse(label.color, radix: 16))
                                  .withOpacity(1.0),
                              fontSize: label.fontSize.toDouble(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              );
            }

            if (isPrinted && !isFront && idCardGenerationModel.idcard.isDual) {
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
                              image: MemoryImage(Uint8List.fromList(
                                  imageMap[label.title.toLowerCase()]!)),
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
                              color: Color(int.parse(label.color, radix: 16))
                                  .withOpacity(1.0),
                              fontSize: label.fontSize.toDouble(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              );
            }
          }

          final frontImage = await _generateImage(
              labelList,
              idCardGenerationModel.idcard.width,
              idCardGenerationModel.idcard.height,
              dpi,
              frontPath,
              student.name);

          sendPort.send({
            'studentId': student.id,
            'imageType': 'front',
            'imageBytes': frontImage,
          });

          if (idCardGenerationModel.idcard.isDual &&
              backgroundImageBytes != null) {
            final backImage = await _generateImage(
                labelBackList,
                idCardGenerationModel.idcard.width,
                idCardGenerationModel.idcard.height,
                dpi,
                backPath,
                student.name);

            sendPort.send({
              'studentId': student.id,
              'imageType': 'back',
              'imageBytes': backImage,
            });
          }
        }
      }
    } catch (e, stackTrace) {
      print('Image generation error: $e\n$stackTrace');
    }
  }

  static Future<Uint8List?> _loadImageBytes(String imagePath) async {
    final File imageFile = File(imagePath);
    final Uint8List bytes = await imageFile.readAsBytes();
    return bytes;
  }

  static Future<Uint8List?> _generateImage(
      List<Widget> labelList,
      double width,
      double height,
      String dpi,
      String outputFilePath,
      String studentName) async {
    final RepaintBoundary boundary = RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: labelList,
      ),
    );
    final ui.Image image =
        await _renderWidgetToImage(boundary as RenderRepaintBoundary);
    final ByteData? byteData = await image.toByteData();
    final Uint8List resizedImageData = byteData!.buffer.asUint8List();
    final IMG.Image resizedImage = IMG.decodeImage(resizedImageData)!;

    final Uint8List outputImageBytes = IMG.encodePng(resizedImage);
    final outputImageFile =
        File(outputFilePath.replaceFirst('%studentName%', studentName));
    await outputImageFile.writeAsBytes(outputImageBytes);
    return outputImageBytes;
  }

  static Future<ui.Image> _renderWidgetToImage(
      RenderRepaintBoundary boundary) async {
    final image = await boundary.toImage(pixelRatio: 1.0);
    return image;
  }
}

class ScaffoldPageList extends StatefulWidget {
  final String idCardId;
  final List<Student> students;
  final Map<String, bool> isSelected;

  const ScaffoldPageList({
    Key? key,
    required this.idCardId,
    required this.students,
    required this.isSelected,
  }) : super(key: key);

  @override
  _ScaffoldPageState createState() => _ScaffoldPageState();
}

class _ScaffoldPageState extends State<ScaffoldPageList> {
  late final List<Student> students;

  final Map<String, bool> isSelected = {};

  String dpi = '300';
  String outputPath = '';
  String frontPath = '';
  String backPath = '';
  String foregroundImagePath = '';
  String backgroundImagePath = '';

  List<ReceivePort> isolatePorts = [];
  late IdCardGenerationModel _idCardGenerationModel;
  final RemoteServices _remoteServices = RemoteServices();
  List<Isolate> isolates = [];

  @override
  void initState() {
    super.initState();
    students = [];
    () async {
      await initializeIdCardGenerationModel();
    }();
    for (final data in widget.students) {
      isSelected[data.id] = true;
      students.add(data);
    }
  }

  @override
  void dispose() {
    for (final port in isolatePorts) {
      port.close();
    }
    super.dispose();
  }

  Future<void> initializeIdCardGenerationModel() async {
    _idCardGenerationModel =
        await _remoteServices.getIdCardGenerationModel(widget.idCardId);
  }

  Future<void> startImageGeneration() async { 
    isolatePorts.clear();
    isolates.clear();

    final int numberOfIsolates = Platform.numberOfProcessors;

    final sendPorts = <SendPort>[];
    for (int i = 0; i < numberOfIsolates; i++) {
      final receivePort = ReceivePort();
      isolatePorts.add(receivePort);

      final isolate = await Isolate.spawn(
        _isolateEntry,
        receivePort.sendPort,
      );
      isolates.add(isolate);

      sendPorts.add(await receivePort.first);
    }

    final studentsPerIsolate = students.length ~/ numberOfIsolates;

    int start = 0;
    int end = studentsPerIsolate;
    for (int i = 0; i < numberOfIsolates - 1; i++) {
      final subList = students.sublist(start, end);
      sendPorts[i].send({
       'students': subList,
        'idCardGenerationModel': _idCardGenerationModel,
        'dpi': dpi,
        'isSelected': isSelected, 
        'outputPath': outputPath,
        'frontPath': frontPath,
        'backPath': backPath,
        'foregroundImagePath': foregroundImagePath,
        'backgroundImagePath': backgroundImagePath,
      });
      start = end;
      end += studentsPerIsolate;
    }

    final subList = students.sublist(start);
    sendPorts[numberOfIsolates - 1].send({
      'students': subList,
      'idCardGenerationModel': _idCardGenerationModel,
      'dpi': dpi,
      'isSelected': isSelected, 
      'outputPath': outputPath,
      'frontPath': frontPath,
      'backPath': backPath,
      'foregroundImagePath': foregroundImagePath,
      'backgroundImagePath': backgroundImagePath,
    });
  }

  static void _isolateEntry(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message is Map<String, dynamic>) {
        final students = message['students'] as List<Student>;
        final idCardGenerationModel =
            message['idCardGenerationModel'] as IdCardGenerationModel;

        final dpi =
            message['dpi'] as String; 
            
        final outputPath = message['outputPath'] as String; 
        final frontPath = message['frontPath'] as String; 
        final backPath = message['backPath'] as String; 
        final foregroundImagePath =
            message['foregroundImagePath'] as String; 
        final backgroundImagePath =
            message['backgroundImagePath'] as String; 
final isSelected = message['isSelected'] as Map<String, bool>;
        ImageGenerationIsolate.generateImages(
          students,
          isSelected,
          dpi,
          outputPath,
          frontPath,
          backPath,
          foregroundImagePath,
          backgroundImagePath,
          sendPort,
          idCardGenerationModel,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Generation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Select Students',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (BuildContext context, int index) {
                  final student = students[index];
                  return CheckboxListTile(
                    title: Text(student.name),
                    value: isSelected[student.id],
                    onChanged: (bool? value) {
                      setState(() {
                        isSelected[student.id] = value ?? false;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'DPI:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Slider(
              value: double.parse(dpi),
              min: 100,
              max: 600,
              divisions: 11,
              label: dpi,
              onChanged: (double value) {
                setState(() {
                  dpi = value.toStringAsFixed(0);
                });
              },
            ),
            const SizedBox(height: 10),
            const Text(
              'Output Path:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              outputPath,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.getDirectoryPath();
                if (result != null) {
                  setState(() {
                    outputPath = result;
                  });
                }
              },
              child: const Text('Select Output Path'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Front Image Path:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              frontPath,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  setState(() {
                    frontPath = result.files.single.path!;
                  });
                }
              },
              child: const Text('Select Front Image'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Back Image Path:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              backPath,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  setState(() {
                    backPath = result.files.single.path!;
                  });
                }
              },
              child: const Text('Select Back Image'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Foreground Image Path:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              foregroundImagePath,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  setState(() {
                    foregroundImagePath = result.files.single.path!;
                  });
                }
              },
              child: const Text('Select Foreground Image'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Background Image Path:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              backgroundImagePath,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  setState(() {
                    backgroundImagePath = result.files.single.path!;
                  });
                }
              },
              child: const Text('Select Background Image'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: startImageGeneration,
              child: const Text('Generate Images'),
            ),
          ],
        ),
      ),
    );
  }
}
