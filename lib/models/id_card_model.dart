// To parse this JSON data, do
//
//     final IdCardModel = IdCardModelFromJson(jsonString);

// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

IdCardModel idCardModelFromJson(String str) =>
    IdCardModel.fromJson(json.decode(str));

String idCardModelToJson(IdCardModel data) => json.encode(data.toJson());

class IdCardModel {
  IdCardModel({
    required this.title,
    required this.id,
    required this.schoolId,
    required this.isDual,
    required this.foregroundImagePath,
    this.backgroundImagePath = "",
    required this.width,
    required this.height,
    required this.labels,
  });

  String title;
  String id;
  String schoolId;
  bool isDual;
  String foregroundImagePath;
  String backgroundImagePath;
  var width;
  var height;
  List<Label> labels;

  factory IdCardModel.fromJson(Map<String, dynamic> json) => IdCardModel(
        title: json["title"],
        isDual: json["isDual"],
        foregroundImagePath: json["foregroundImagePath"],
        backgroundImagePath: json["backgroundImagePath"] ?? "",
        width: json["width"],
        height: json["height"],
        labels: List<Label>.from(json["labels"].map((x) => Label.fromJson(x))),
        schoolId: json["schoolId"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "isDual": isDual,
        // "foregroundImagePath": foregroundImagePath,
        // "backgroundImagePath": backgroundImagePath,
        "width": width,
        "height": height,
        "labels": List<dynamic>.from(labels.map((x) => x.toJson())),
        "schoolId": schoolId,
      };
}

class Label {
  Label({
    required this.title,
    this.color = "ff000000",
    this.fontSize = 20,
    this.x = 0.0,
    this.y = 0.0,
    this.width = 100.0,
    this.height = 30.0,
    this.isPrinted = false,
    this.isFront = true,
    this.isPhoto = false,
    this.fontName = "Amiko",
    this.textAlign = "left",
  });

  String title;
  String color;
  int fontSize;
  var x;
  var y;
  var width;
  var height;
  bool isPrinted;
  bool isFront;
  bool isPhoto;
  String fontName;
  String textAlign;

  factory Label.fromJson(Map<String, dynamic> json) => Label(
        title: json["title"],
        color: json["color"],
        fontSize: json["fontSize"],
        x: json["x"],
        y: json["y"],
        width: json["width"],
        height: json["height"],
        isPrinted: json["isPrinted"],
        isFront: json["isFront"],
        isPhoto: json["isPhoto"],
        fontName: json["fontName"] ?? 'ABeeZee',
        textAlign: json["textAlign"] ?? 'left',
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "color": color,
        "fontSize": fontSize,
        "x": x,
        "y": y,
        "width": width,
        "height": height,
        "isPrinted": isPrinted,
        "isFront": isFront,
        "isPhoto": isPhoto,
        "fontName": fontName,
        "textAlign": textAlign,
      };
}
