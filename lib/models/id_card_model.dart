// class IdCardModel {
//   List<Label> labels;
//   bool isPhoto;
//   String backgroundImagePath;
//   String? photoPath;
//   int? photoWidth;
//   int? photoHeight;
//   int? photoX;
//   int? photoY;

//   IdCardModel({
//     required this.labels,
//     required this.isPhoto,
//     required this.backgroundImagePath,
//     this.photoPath,
//     this.photoWidth,
//     this.photoHeight,
//     this.photoX,
//     this.photoY,
//   });
// }

// class Label {
//   String title;
//   int color;
//   int fontSize;
//   int x, y;
//   Label({required this.title, required this.color, required this.fontSize, required this.x, required this.y});
// }

// To parse this JSON data, do
//
//     final idCardModel = idCardModelFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

IdCardModel idCardModelFromMap(String str) =>
    IdCardModel.fromMap(json.decode(str));

String idCardModelToMap(IdCardModel data) => json.encode(data.toMap());

class IdCardModel {
  IdCardModel({
    required this.isPhoto,
    required this.backgroundImagePath,
    this.photoPath = '',
    this.photoWidth = 0.0,
    this.photoHeight = 0.0,
    this.photoX = 200.0,
    this.photoY = 200.0,
    required this.labels,
  });

  bool isPhoto;
  String backgroundImagePath;
  String photoPath;
  double photoWidth;
  double photoHeight;
  double photoX;
  double photoY;
  List<Label> labels;

  factory IdCardModel.fromMap(Map<String, dynamic> json) => IdCardModel(
        isPhoto: json["isPhoto"],
        backgroundImagePath: json["backgroundImagePath"],
        photoPath: json["photoPath"],
        photoWidth: json["photoWidth"],
        photoHeight: json["photoHeight"],
        photoX: json["photoX"],
        photoY: json["photoY"],
        labels: List<Label>.from(json["labels"].map((x) => Label.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "isPhoto": isPhoto,
        "backgroundImagePath": backgroundImagePath,
        "photoPath": photoPath,
        "photoWidth": photoWidth,
        "photoHeight": photoHeight,
        "photoX": photoX,
        "photoY": photoY,
        "labels": List<dynamic>.from(labels.map((x) => x.toMap())),
      };
}

class Label {
  Label({
    required this.title,
    required this.color,
    required this.fontSize,
    required this.x,
    required this.y,
  });

  String title;
  String color;
  int fontSize;
  int x;
  int y;

  factory Label.fromMap(Map<String, dynamic> json) => Label(
        title: json["title"],
        color: json["color"],
        fontSize: json["fontSize"],
        x: json["x"],
        y: json["y"],
      );

  Map<String, dynamic> toMap() => {
        "title": title,
        "color": color,
        "fontSize": fontSize,
        "x": x,
        "y": y,
      };
}
