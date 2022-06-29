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
  GlobalKey _globalFrontKey = GlobalKey();
  GlobalKey _globalBackKey = GlobalKey();
  final labelList = <Widget>[];
  final labelBackList = <Widget>[];

  @override
  void initState() {
    print(widget.idCard.backgroundImagePath);
    print(widget.idCard.foregroundImagePath);
    super.initState();
  }

  Future<void> _capturePng(GlobalKey key) async {
    final RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    String path = await FileSaver.instance.saveFile("images", pngBytes, "png");
    print(path);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.idCard.foregroundImagePath != '') {
      labelList.add(
        Image.file(
          File(
            widget.idCard.foregroundImagePath,
          ),
        ),
      );
    }

    if (widget.idCard.backgroundImagePath != '') {
      labelBackList.add(
        Image.file(
          File(
            widget.idCard.backgroundImagePath,
          ),
        ),
      );
    }

    // if (widget.idCard.isPhoto) {
    //   print(
    //       "${widget.idCard.photoX} ${widget.idCard.photoY} ${widget.idCard.photoWidth} ${widget.idCard.photoHeight}");
    //   labelList.add(
    //     Positioned(
    //       top: widget.idCard.photoY.toDouble(),
    //       left: widget.idCard.photoX.toDouble(),
    //       child: Draggable(
    //           feedback: SizedBox(
    //             height: (widget.idCard.photoHeight.toDouble()) * 3.779,
    //             width: (widget.idCard.photoWidth.toDouble()) * 3.779,
    //             child: Container(
    //               color: Colors.red,
    //               child: Image.network(
    //                 "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
    //               ),
    //             ),
    //           ),
    //           childWhenDragging: Container(),
    //           child: SizedBox(
    //             height: (widget.idCard.photoHeight.toDouble()) * 3.779,
    //             width: (widget.idCard.photoWidth.toDouble()) * 3.779,
    //             child: Container(
    //               color: Colors.blue,
    //               child: Image.network(
    //                 "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
    //                 height: (widget.idCard.photoHeight.toDouble()) * 3.779,
    //                 width: (widget.idCard.photoWidth.toDouble()) * 3.779,
    //               ),
    //             ),
    //           ),
    //           onDragEnd: (dragDetails) {
    //             setState(() {
    //               widget.idCard.photoX = dragDetails.offset.dx - 416;
    //               widget.idCard.photoY = dragDetails.offset.dy - 90;
    //               // widget.updateIdCardPosition(widget.idCard);
    //             });
    //           }),
    //     ),
    //   );
    // }
    for (int i = 0; i < widget.idCard.labels.length; i++) {
      if (widget.idCard.labels[i].isPrinted &&
          widget.idCard.labels[i].isFront) {
        labelList.add(
          Positioned(
            top: widget.idCard.labels[i].y.toDouble(),
            left: widget.idCard.labels[i].x.toDouble(),
            child: Draggable(
              feedback: Container(
                height: widget.idCard.labels[i].height.toDouble(),
                width: widget.idCard.labels[i].width.toDouble(),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                  image: widget.idCard.labels[i].isPhoto
                      ? DecorationImage(
                          image: NetworkImage(
                            "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Text(
                  widget.idCard.labels[i].title,
                  style: TextStyle(
                    fontSize: widget.idCard.labels[i].fontSize.toDouble(),
                    color: Color(
                        int.parse(widget.idCard.labels[i].color, radix: 16)),
                  ),
                ),
              ),
              childWhenDragging: Container(),
              child: Container(
                height: widget.idCard.labels[i].height.toDouble(),
                width: widget.idCard.labels[i].width.toDouble(),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                  image: widget.idCard.labels[i].isPhoto
                      ? DecorationImage(
                          image: NetworkImage(
                            "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Text(
                  widget.idCard.labels[i].title,
                  style: TextStyle(
                    fontSize: widget.idCard.labels[i].fontSize.toDouble(),
                    color: Color(
                        int.parse(widget.idCard.labels[i].color, radix: 16)),
                  ),
                ),
              ),
              onDragEnd: (dragDetails) {
                setState(() {
                  widget.idCard.labels[i].y =
                      dragDetails.offset.dy.toInt() - 90;
                  widget.idCard.labels[i].x =
                      dragDetails.offset.dx.toInt() - 416;
                });

                widget.updateIdCardPosition(
                    i, widget.idCard.labels[i].x, widget.idCard.labels[i].y);
              },
            ),
          ),
        );
      } else if (widget.idCard.labels[i].isPrinted) {
        labelBackList.add(
          Positioned(
            top: widget.idCard.labels[i].y.toDouble(),
            left: widget.idCard.labels[i].x.toDouble(),
            child: Draggable(
              feedback: Text(
                widget.idCard.labels[i].title,
                style: TextStyle(
                  fontSize: widget.idCard.labels[i].fontSize.toDouble(),
                  color: Color(
                      int.parse(widget.idCard.labels[i].color, radix: 16)),
                ),
              ),
              childWhenDragging: Container(),
              child: Container(
                height: widget.idCard.labels[i].height.toDouble(),
                width: widget.idCard.labels[i].width.toDouble(),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.idCard.labels[i].title,
                  style: TextStyle(
                    fontSize: widget.idCard.labels[i].fontSize.toDouble(),
                    color: Color(
                        int.parse(widget.idCard.labels[i].color, radix: 16)),
                  ),
                ),
              ),
              onDragEnd: (dragDetails) {
                setState(() {
                  widget.idCard.labels[i].y =
                      dragDetails.offset.dy.toInt() - 90;
                  widget.idCard.labels[i].x = dragDetails.offset.dx.toInt() -
                      (416 + widget.idCard.width.toInt());
                });

                widget.updateIdCardPosition(
                    i, widget.idCard.labels[i].x, widget.idCard.labels[i].y);
              },
            ),
          ),
        );
      }
    }

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                height: widget.idCard.height.toDouble(),
                width: widget.idCard.width.toDouble(),
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
                      height: widget.idCard.height.toDouble(),
                      width: widget.idCard.width.toDouble(),
                      child: Stack(children: labelBackList),
                    ),
                  ),
                )
              : Container()

          // Column(
          //   children: [
          //     ElevatedButton(
          //         onPressed: () {
          //           Navigator.of(context).pop();
          //         },
          //         child: const Text('Save')),
          //     ElevatedButton(
          //         onPressed: _capturePng, child: Text('Download Sample')),
          //   ],
          // )
        ],
      ),
    );

    // return Stack(children: labelList);
  }
}
