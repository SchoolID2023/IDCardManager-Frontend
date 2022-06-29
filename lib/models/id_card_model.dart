// To parse this JSON data, do
//
//     final IdCardModel = IdCardModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

IdCardModel idCardModelFromJson(String str) =>
    IdCardModel.fromJson(json.decode(str));

String idCardModelToJson(IdCardModel data) => json.encode(data.toJson());

class IdCardModel {
  IdCardModel({
    required this.isDual,
    required this.foregroundImagePath,
    this.backgroundImagePath = "",
    required this.width,
    required this.height,
    required this.labels,
  });

  bool isDual;
  String foregroundImagePath;
  String backgroundImagePath;
  double width;
  double height;
  List<Label> labels;

  factory IdCardModel.fromJson(Map<String, dynamic> json) => IdCardModel(
        isDual: json["isDual"],
        foregroundImagePath: json["foregroundImagePath"],
        backgroundImagePath: json["backgroundImagePath"],
        width: json["width"],
        height: json["height"],
        labels: List<Label>.from(json["labels"].map((x) => Label.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "isDual": isDual,
        "foregroundImagePath": foregroundImagePath,
        "backgroundImagePath": backgroundImagePath,
        "width": width,
        "height": height,
        "labels": List<dynamic>.from(labels.map((x) => x.toJson())),
      };
}

class Label {
  Label({
    required this.title,
    this.color = "ff000000",
    this.fontSize = 20,
    this.x = 0,
    this.y = 0,
    this.width = 100,
    this.height = 20,
    this.isPrinted = false,
    this.isFront = true,
    this.isPhoto = false,
  });

  String title;
  String color;
  int fontSize;
  int x;
  int y;
  int width;
  int height;
  bool isPrinted;
  bool isFront;
  bool isPhoto;

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
      };
}
