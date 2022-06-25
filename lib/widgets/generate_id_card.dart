import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:string_to_hex/string_to_hex.dart';

import '../models/id_card_model.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_saver/file_saver.dart';

class GenerateIdCard extends StatefulWidget {
  GenerateIdCard({
    Key? key,
    required this.idCard,
    required this.updateIdCardPosition,
  }) : super(key: key);

  IdCardModel idCard;
  Function updateIdCardPosition;

  @override
  State<GenerateIdCard> createState() => _GenerateIdCardState();
}

class _GenerateIdCardState extends State<GenerateIdCard> {
  GlobalKey _globalKey = new GlobalKey();
  final labelList = <Widget>[];

  Future<void> _capturePng() async {
    final RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    String path = await FileSaver.instance.saveFile("images", pngBytes, "png");
    print(path);
  }

  @override
  Widget build(BuildContext context) {
    labelList.add(
      Image.file(
        File(
          widget.idCard.backgroundImagePath,
        ),
      ),
    );

    if (widget.idCard.isPhoto) {
      print(
          "${widget.idCard.photoX} ${widget.idCard.photoY} ${widget.idCard.photoWidth} ${widget.idCard.photoHeight}");
      labelList.add(
        Positioned(
          top: widget.idCard.photoY.toDouble(),
          left: widget.idCard.photoX.toDouble(),
          child: Draggable(
              feedback: SizedBox(
                height: (widget.idCard.photoHeight.toDouble()) * 3.779,
                width: (widget.idCard.photoWidth.toDouble()) * 3.779,
                child: Container(
                  color: Colors.red,
                  child: Image.network(
                    "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
                  ),
                ),
              ),
              childWhenDragging: Container(),
              child: SizedBox(
                height: (widget.idCard.photoHeight.toDouble()) * 3.779,
                width: (widget.idCard.photoWidth.toDouble()) * 3.779,
                child: Container(
                  color: Colors.blue,
                  child: Image.network(
                    "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
                    height: (widget.idCard.photoHeight.toDouble()) * 3.779,
                    width: (widget.idCard.photoWidth.toDouble()) * 3.779,
                  ),
                ),
              ),
              onDragEnd: (dragDetails) {
                setState(() {
                  widget.idCard.photoX = dragDetails.offset.dx;
                  widget.idCard.photoY = dragDetails.offset.dy;
                  // widget.updateIdCardPosition(widget.idCard);
                });
              }),
        ),
      );
    }
    for (int i = 0; i < widget.idCard.labels.length; i++) {
      labelList.add(
        Positioned(
          top: widget.idCard.labels[i].y.toDouble(),
          left: widget.idCard.labels[i].x.toDouble(),
          child: Draggable(
            feedback: Text(
              widget.idCard.labels[i].title,
              style: TextStyle(
                fontSize: widget.idCard.labels[i].fontSize.toDouble(),
                color:
                    Color(int.parse(widget.idCard.labels[i].color, radix: 16)),
              ),
            ),
            childWhenDragging: Container(),
            child: Text(
              widget.idCard.labels[i].title,
              style: TextStyle(
                fontSize: widget.idCard.labels[i].fontSize.toDouble(),
                color:
                    Color(int.parse(widget.idCard.labels[i].color, radix: 16)),
              ),
            ),
            onDragEnd: (dragDetails) {
              setState(() {
                widget.idCard.labels[i].y = dragDetails.offset.dy.toInt();
                widget.idCard.labels[i].x = dragDetails.offset.dx.toInt();
              });

              widget.updateIdCardPosition(
                i,
                dragDetails.offset.dx.toInt(),
                dragDetails.offset.dy.toInt(),
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          RepaintBoundary(
            key: _globalKey,
            child: Stack(children: labelList),
          ),
          Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Save')),
              ElevatedButton(
                  onPressed: _capturePng, child: Text('Download Sample')),
            ],
          )
        ],
      ),
    );

    // return Stack(children: labelList);
  }
}
