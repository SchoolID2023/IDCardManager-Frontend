// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:idcard_maker_frontend/widgets/resizable_widget.dart';

import '../models/id_card_model.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import '../services/logger.dart';

class GenerateIdCard extends StatefulWidget {
  GenerateIdCard({
    Key? key,
    required this.idCard,
    required this.updateIdCardPosition,
    required this.updateEditIndex,
    required this.scaleFactor,
    this.isEdit = false,
  }) : super(key: key);

  IdCardModel idCard;
  Function updateIdCardPosition;
  Function updateEditIndex;
  double scaleFactor;
  bool isEdit = false;

  @override
  State<GenerateIdCard> createState() => _GenerateIdCardState();
}

class _GenerateIdCardState extends State<GenerateIdCard> {
  final GlobalKey _globalFrontKey = GlobalKey();
  final GlobalKey _globalBackKey = GlobalKey();
  final labelList = <Widget>[];
  final labelBackList = <Widget>[];
  double myScale = 1.0;

  @override
  void initState() {
    logger.d(widget.idCard.backgroundImagePath);
    logger.d(widget.idCard.foregroundImagePath);
    super.initState();
  }

  Future<void> _capturePng(GlobalKey key, String folder) async {
    final RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: "1",
    );
    outputFile = outputFile?.substring(0, outputFile.lastIndexOf("\\") + 1);
    logger.d(outputFile);

    Directory destinationFolder = Directory('$outputFile${folder}');
    String path = "";
    if (await destinationFolder.exists()) {
      path = destinationFolder.path;
    } else {
      await destinationFolder.create(recursive: true);
      path = destinationFolder.path;
    }

    await File('${path}\\1.png').writeAsBytes(pngBytes);

    logger.d(destinationFolder.path);

    var destinationFile =
        await File(outputFile! + '1' + '.png').writeAsBytes(pngBytes);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.idCard.foregroundImagePath != '') {
      labelList.add(
        SizedBox(
          height: widget.idCard.height.toDouble() * widget.scaleFactor / 100,
          width: widget.idCard.width.toDouble() * widget.scaleFactor / 100,
          child: widget.isEdit
              ? Image.memory(
                  base64Decode(
                    widget.idCard.foregroundImagePath,
                  ),
                  fit: BoxFit.fill,
                )
              : Image.file(
                  File(
                    widget.idCard.foregroundImagePath,
                  ),
                  fit: BoxFit.fill,
                ),
        ),
      );
    }

    if (widget.idCard.backgroundImagePath != '') {
      labelBackList.add(
        SizedBox(
          height: widget.idCard.height.toDouble() * widget.scaleFactor / 100,
          width: widget.idCard.width.toDouble() * widget.scaleFactor / 100,
          child: widget.isEdit
              ? Image.memory(
                  base64Decode(
                    widget.idCard.backgroundImagePath,
                  ),
                  fit: BoxFit.fill,
                )
              : Image.file(
                  File(
                    widget.idCard.backgroundImagePath,
                  ),
                  fit: BoxFit.fill,
                ),
        ),
      );
    }

    for (int i = 0; i < widget.idCard.labels.length; i++) {
      if (widget.idCard.labels[i].isPrinted &&
          widget.idCard.labels[i].isFront) {
        labelList.add(
          GestureDetector(
            onTapUp: (_) {
              widget.updateEditIndex(i, false);
            },
            onLongPressMoveUpdate: (_) {
              widget.updateEditIndex(i, false);
            },
            child: ResizebleWidget(
              label: widget.idCard.labels[i],
              myScale: widget.scaleFactor / 100,
            ),
          ),
        );
      } else if (widget.idCard.labels[i].isPrinted) {
        labelBackList.add(
          GestureDetector(
            onTapUp: (_) {
              widget.updateEditIndex(i, false);
            },
            onLongPressMoveUpdate: (_) {
              widget.updateEditIndex(i, false);
            },
            child: ResizebleWidget(
              label: widget.idCard.labels[i],
              myScale: widget.scaleFactor / 100,
            ),
          ),
        );
      }
    }

    return Container(
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
            ),
            child: RepaintBoundary(
              key: _globalFrontKey,
              child: SizedBox(
                height:
                    widget.idCard.height.toDouble() * widget.scaleFactor / 100,
                width:
                    widget.idCard.width.toDouble() * widget.scaleFactor / 100,
                child: Stack(children: labelList),
              ),
            ),
          ),
          widget.idCard.isDual
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: RepaintBoundary(
                    key: _globalBackKey,
                    child: SizedBox(
                      height: widget.idCard.height.toDouble() *
                          widget.scaleFactor /
                          100,
                      width: widget.idCard.width.toDouble() *
                          widget.scaleFactor /
                          100,
                      child: Stack(children: labelBackList),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );

    // return Stack(children: labelList);
  }
}
