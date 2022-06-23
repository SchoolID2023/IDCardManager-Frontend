import 'dart:io';

import 'package:flutter/material.dart';

import '../models/id_card_model.dart';
import 'package:get/get.dart';

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
  final labelList = <Widget>[];

  @override
  Widget build(BuildContext context) {
    
    labelList.add(
      Image.file(
        File(
          widget.idCard.backgroundImagePath,
        ),
      ),
    );

    if(widget.idCard.isPhoto) {
      labelList.add(
        Positioned(
          height: widget.idCard.photoX?.toDouble(),
          width: widget.idCard.photoY?.toDouble(),
          child: Draggable(
            feedback: Image.network(
              "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
              height: widget.idCard.photoHeight?.toDouble() ?? 0.0,
              width: widget.idCard.photoWidth?.toDouble() ?? 0.0,
            ),
            childWhenDragging: Container(),
            child: Image.network(
              "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
              height: widget.idCard.photoHeight?.toDouble() ?? 0.0,
              width: widget.idCard.photoWidth?.toDouble() ?? 0.0,
            ),
            onDragEnd: (dragDetails) {
              setState(() {
                widget.idCard.photoX = dragDetails.offset.dx.toInt();
                widget.idCard.photoY = dragDetails.offset.dy.toInt();
                // widget.updateIdCardPosition(widget.idCard);
              });
              
            }
          ),
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
                color: Color(widget.idCard.labels[i].color),
              ),
            ),
            childWhenDragging: Container(),
            child: Text(
              widget.idCard.labels[i].title,
              style: TextStyle(
                fontSize: widget.idCard.labels[i].fontSize.toDouble(),
                color: Color(widget.idCard.labels[i].color),
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
      body: Stack(children: labelList),
    );
  }
}
