// To parse this JSON data, do
//
//     final idCardListModel = idCardListModelFromJson(jsonString);

import 'dart:convert';

IdCardListModel idCardListModelFromJson(String str) =>
    IdCardListModel.fromJson(json.decode(str));

String idCardListModelToJson(IdCardListModel data) =>
    json.encode(data.toJson());

class IdCardListModel {
  IdCardListModel({
    required this.success,
    required this.message,
    required this.idCards,
  });

  bool success;
  String message;
  List<IdCard> idCards;

  factory IdCardListModel.fromJson(Map<String, dynamic> json) =>
      IdCardListModel(
        success: json["success"],
        message: json["message"],
        idCards:
            List<IdCard>.from(json["idCards"].map((x) => IdCard.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "idCards": List<dynamic>.from(idCards.map((x) => x.toJson())),
      };
}

class IdCard {
  IdCard({
    required this.id,
    required this.isDual,
    required this.foregroundImagePath,
    required this.schoolId,
    required this.labels,
    required this.width,
    required this.height,
    required this.v,
  });

  String id;
  bool isDual;
  String foregroundImagePath;
  String schoolId;
  String labels;
  final width;
  final height;
  int v;

  factory IdCard.fromJson(Map<String, dynamic> json) => IdCard(
        id: json["_id"],
        isDual: json["isDual"],
        foregroundImagePath: json["foregroundImagePath"],
        schoolId: json["schoolId"],
        labels: json["labels"],
        width: json["width"],
        height: json["height"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "isDual": isDual,
        "foregroundImagePath": foregroundImagePath,
        "schoolId": schoolId,
        "labels": labels,
        "width": width,
        "height": height,
        "__v": v,
      };
}
