// To parse this JSON data, do
//
//     final idCardGenerationModel = idCardGenerationModelFromJson(jsonString);

import 'dart:convert';
import './id_card_model.dart';

IdCardGenerationModel idCardGenerationModelFromJson(String str) =>
    IdCardGenerationModel.fromJson(json.decode(str));

String idCardGenerationModelToJson(IdCardGenerationModel data) =>
    json.encode(data.toJson());

class IdCardGenerationModel {
  IdCardGenerationModel({
    required this.success,
    required this.message,
    required this.idcard,
  });

  bool success;
  String message;
  IdCardModel idcard;

  factory IdCardGenerationModel.fromJson(Map<String, dynamic> json) =>
      IdCardGenerationModel(
        success: json["success"],
        message: json["message"],
        idcard: IdCardModel.fromJson(json["idcard"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "idcard": idcard.toJson(),
      };
}

// class Idcard {
//   Idcard({
//     required this.id,
//     required this.isDual,
//     required this.foregroundImagePath,
//     required this.schoolId,
//     required this.labels,
//     this.backgroundImagePath,
//     required this.width,
//     required this.height,
    
//   });

//   String id;
//   bool isDual;
//   String foregroundImagePath;
//   String schoolId;
//   List<Label> labels;
//   String? backgroundImagePath;
//   final width;
//   final height;
  

//   factory Idcard.fromJson(Map<String, dynamic> json) => Idcard(
//         id: json["_id"],
//         isDual: json["isDual"],
//         foregroundImagePath: json["foregroundImagePath"],
//         schoolId: json["schoolId"],
//         labels: List<Label>.from(json["labels"].map((x) => Label.fromJson(x))),
//         backgroundImagePath: json["backgroundImagePath"],
//         width: json["width"],
//         height: json["height"],
        
//       );

//   Map<String, dynamic> toJson() => {
//         "_id": id,
//         "isDual": isDual,
//         "foregroundImagePath": foregroundImagePath,
//         "schoolId": schoolId,
//         "labels": List<dynamic>.from(labels.map((x) => x.toJson())),
//         "backgroundImagePath": backgroundImagePath,
//         "width": width,
//         "height": height,
        
//       };
// }

// class Label {
//   Label({
//     required this.title,
//     required this.color,
//     required this.fontSize,
//     required this.x,
//     required this.y,
//     required this.width,
//     required this.height,
//     required this.isPrinted,
//     required this.isFront,
//     required this.isPhoto,
//     required this.fontName,
//     required this.textAlign,
//   });

//   String title;
//   String color;
//   int fontSize;
//   double x;
//   double y;
//   double width;
//   double height;
//   bool isPrinted;
//   bool isFront;
//   bool isPhoto;
//   String fontName;
//   String textAlign;

//   factory Label.fromJson(Map<String, dynamic> json) => Label(
//         title: json["title"],
//         color: json["color"],
//         fontSize: json["fontSize"],
//         x: json["x"],
//         y: json["y"],
//         width: json["width"],
//         height: json["height"],
//         isPrinted: json["isPrinted"],
//         isFront: json["isFront"],
//         isPhoto: json["isPhoto"],
        // fontName: json["fontName"] == null ? 'ABeeZee' : json["fontName"],
        // textAlign: json["textAlign"] == null ? 'left' : json["textAlign"],
        

//       );

//   Map<String, dynamic> toJson() => {
//         "title": title,
//         "color": color,
//         "fontSize": fontSize,
//         "x": x,
//         "y": y,
//         "width": width,
//         "height": height,
//         "isPrinted": isPrinted,
//         "isFront": isFront,
//         "isPhoto": isPhoto,
//         "fontName": fontName,
//         "textAlign": textAlign,
//       };
// }
