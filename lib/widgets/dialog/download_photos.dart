import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';
import 'package:idcard_maker_frontend/services/remote_services.dart';

import '../../models/photos_list_model.dart';
import '../../services/logger.dart';

class DownloadPhotosDialog extends StatefulWidget {
  final String schoolId;
  const DownloadPhotosDialog({super.key, required this.schoolId});

  @override
  State<DownloadPhotosDialog> createState() => _DownloadPhotosDialogState();
}

class _DownloadPhotosDialogState extends State<DownloadPhotosDialog> {
  bool isDownloading = false;
  String selectedPath = "";

  Future<void> chooseOutputPath() async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output destination:',
      fileName: "1",
    );
    outputFile = outputFile?.substring(0, outputFile.lastIndexOf("\\") + 1);
    logger.d(outputFile);

    Directory destinationFolder =
        Directory('${outputFile}$schoolName\\$selectedLabel');
    if (await destinationFolder.exists()) {
      selectedPath = destinationFolder.path;
    } else {
      await destinationFolder.create(recursive: true);
      selectedPath = destinationFolder.path;
    }

    downloadAndSavePhotos().then((value) {
      Navigator.of(context).pop();
    });
  }

  Future<void> downloadAndSavePhotos() async {
    toSaveLabelName = toSaveLabelName.isEmpty ? selectedLabel : toSaveLabelName ;
    final photosList = await RemoteServices().downloadPhotos(
      widget.schoolId,
      selectedClass,
      selectedSection,
      selectedLabel,
      toSaveLabelName
    );
    final classes = photosList.classes;

    for (int i = 0; i < classes.length; i++) {
      for (int j = 0; j < classes[i].sections.length; j++) {
        for (int k = 0; k < classes[i].sections[j].photos.length; k++) {
          final photo = classes[i].sections[j].photos[k]; 
          String savename = photo.name;
          String savePath =
              "$selectedPath/${classes[i].name}/${classes[i].sections[j].name}/$savename";
          logger.i(savePath);
          try {
            await Dio().download(photo.url, savePath,
                onReceiveProgress: (received, total) {
              if (total != -1) {
                // print((receiv`ed / total * 100).toStringAsFixed(0) + "%");
              }
            });
          } catch (e) {
            logger.i(e);
          }
        }
      }
    }
  }

  late StudentController studentController;

  List<String> classes = [];
  List<String> sections = [];
  List<String> labels = [];

  String schoolName = "";

  String selectedClass = "All";
  String selectedSection = "All";
  String selectedLabel = "";
  String toSaveLabelName = '';

  @override
  void initState() {
    // TODO: implement initState
    studentController = Get.put(StudentController(widget.schoolId));

    classes = studentController.getSchool.classes;
    sections = studentController.getSchool.sections;
    schoolName = studentController.getSchool.name;
    labels = studentController.getSchoolLabels.photoLabels;
    classes.insert(0, "All");
    sections.insert(0, "All");

    selectedLabel = labels[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(isDownloading ? 'Downloading Photos' : 'Download Photos'),
      content: isDownloading
          ? ProgressRing()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    DropDownButton(
                      items: classes
                          .map((e) => MenuFlyoutItem(
                              text: Text(e),
                              onPressed: () {
                                setState(() {
                                  selectedClass = e;
                                });
                              }))
                          .toList(),
                      title: Text("${selectedClass} Class"),
                    ),
                    const SizedBox(width: 10),
                    DropDownButton(
                      items: sections
                          .map((e) => MenuFlyoutItem(
                              text: Text(e),
                              onPressed: () {
                                setState(() {
                                  selectedSection = e;
                                });
                              }))
                          .toList(),
                      title: Text("${selectedSection} Section"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    DropDownButton(
                      items: labels
                          .map((e) => MenuFlyoutItem(
                              text: Text(e),
                              onPressed: () {
                                setState(() {
                                  selectedLabel = e;
                                });
                              }))
                          .toList(),
                      title: Text(selectedLabel),
                    ),
                    const SizedBox(width: 10),
                    DropDownButton(
                      items: labels
                          .map(
                            (e) => MenuFlyoutItem(
                              text: Text(e),
                              onPressed: () {
                                setState(() {
                                  toSaveLabelName = e;
                                });
                              },
                            ),
                          )
                          .toList(),
                      title: toSaveLabelName.isNotEmpty
                          ? Text(toSaveLabelName)
                          : const Text('Save in Label ?'),
                    ),
                  ],
                ),
              ],
            ),

      actions: [
        Button(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: isDownloading
              ? null
              : () {
                  chooseOutputPath();
                  setState(() {
                    isDownloading = true;
                  });
                },
          child: Text('Download'),
        ),
      ],
    );
  }
}
