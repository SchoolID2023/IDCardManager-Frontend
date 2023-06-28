import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/services/logger.dart';
import 'package:idcard_maker_frontend/services/remote_services.dart';

import '../controllers/student_controller.dart';

class LoadPhotos extends StatefulWidget {
  final String schoolId;
  final List<String> fields;

  const LoadPhotos({super.key, required this.schoolId, required this.fields});
  @override
  State<LoadPhotos> createState() => _LoadPhotosState();
}

class _LoadPhotosState extends State<LoadPhotos> {
  final RemoteServices _remoteServices = RemoteServices();

  TextEditingController _columns = TextEditingController();

  List<String> photoColumns = [];

  int uploadedFiles = 0;
  int totalFiles = 1;

  Future<void> uploadPhotos() async {
    var nav = Navigator.of(context);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    var encoder = ZipFileEncoder();

    var file = result?.files.first;

    // int batchCounter = 0;

    String outputPath =
        "${file!.path.toString().substring(0, file.path.toString().lastIndexOf("\\") + 1)}file.zip";
    setState(() {
      totalFiles = result!.files.length;
    });

    for (int counter = 0; counter < result!.files.length;) {
      if (counter % 10 == 0) {
        encoder.create(outputPath);
        for (int i = counter; i < min(counter + 10, totalFiles); i++) {
          await encoder.addFile(File(result.files[i].path.toString()));
        }
        encoder.close();

        await _remoteServices.uploadStudentPhotos(
          photoColumns,
          outputPath,
          widget.schoolId,
        );

        setState(() {
          counter = min(counter + 10, totalFiles);

          uploadedFiles = counter;
          logger.d("Uploaded $counter files");
          logger.d("Value = ${(uploadedFiles /totalFiles) * 100}");
        });
        await File(outputPath).delete();

        // batchCounter++;
        // outputPath =
        //     "${file.path.toString().substring(0, file.path.toString().lastIndexOf("\\") + 1)}file$batchCounter.zip";
      }
    }

    // encoder.create(outputPath);
    // for (var element in result!.files) {
    //   await encoder.addFile(File(element.path.toString()));
    // }
    // encoder.close();
    // await _remoteServices.uploadStudentPhotos(
    //   photoColumns,
    //   outputPath,
    //   widget.schoolId,
    // );
    nav.pop();
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    StudentController _studentController =
        Get.put(StudentController(widget.schoolId));
    return ContentDialog(
      title: const Text("Upload Photos"),
      actions: [
        // Button(
        //   child: Text("OK"),
        //   onPressed: () {},
        // ),
        Button(
            child: const Text("CANCEL"),
            onPressed: () => Navigator.pop(context)),
      ],
      content: SizedBox(
        width: 500,
        child: isLoading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Photos Uploading -> $uploadedFiles/$totalFiles"),
                  ProgressBar(
                    value: (uploadedFiles/totalFiles) * 100,
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Expanded(
                      //   child: TextBox(
                      //     controller: _columns,
                      //     header: "Photo Colums",
                      //   ),
                      // ),
                      Expanded(
                        child: DropDownButton(
                          title: const Text("Select Columns"),
                          items: List<MenuFlyoutItemBase>.generate(
                            widget.fields.length,
                            (index) => MenuFlyoutItem(
                              leading: Checkbox(
                                checked:
                                    photoColumns.contains(widget.fields[index]),
                                onChanged: (value) {
                                  setState(() {
                                    if (photoColumns
                                        .contains(widget.fields[index])) {
                                      photoColumns.remove(widget.fields[index]);
                                    } else {
                                      photoColumns.add(widget.fields[index]);
                                    }
                                  });
                                },
                              ),
                              text: Text(widget.fields[index]),
                              onPressed: () {
                                setState(() {
                                  if (photoColumns
                                      .contains(widget.fields[index])) {
                                    photoColumns.remove(widget.fields[index]);
                                  } else {
                                    photoColumns.add(widget.fields[index]);
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      Button(
                        child: const Text("Upload Photos"),
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await uploadPhotos();
                        },
                      ),
                    ],
                  ),
                  Text("Selected Columns: ${photoColumns.join(", ")}"),
                ],
              ),
      ),
    );
  }
}
