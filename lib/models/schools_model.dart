// To parse this JSON data, do
//
//     final schoolsModel = schoolsModelFromJson(jsonString);

import 'dart:convert';

SchoolsModel schoolsModelFromJson(String str) =>
    SchoolsModel.fromJson(json.decode(str));

String schoolsModelToJson(SchoolsModel data) => json.encode(data.toJson());

class SchoolsModel {
  SchoolsModel({
    required this.success,
    required this.message,
    required this.schools,
  });

  bool success;
  String message;
  List<School> schools;

  factory SchoolsModel.fromJson(Map<String, dynamic> json) => SchoolsModel(
        success: json["success"],
        message: json["message"],
        schools:
            List<School>.from(json["schools"].map((x) => School.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "schools": List<dynamic>.from(schools.map((x) => x.toJson())),
      };
}

SchoolLabels schoolLabelsFromJson(String str) =>
    SchoolLabels.fromJson(json.decode(str));

String schoolLabelsToJson(SchoolLabels data) => json.encode(data.toJson());

class SchoolLabels {
  SchoolLabels({
    required this.success,
    required this.photoLabels,
    required this.labels,
  });

  final bool success;
  List<String> labels = [];
  List<String> photoLabels;

  factory SchoolLabels.fromJson(Map<String, dynamic> json) => SchoolLabels(
        success: json["success"],
        labels: List<String>.from(json["labels"] ?? [].map((x) => x)),
        photoLabels: List<String>.from(json["photoLabels"] ?? [].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "labels": List<dynamic>.from(labels.map((x) => x)),
        "photoLabels": List<dynamic>.from(photoLabels.map((x) => x)),
      };
}

class School {
  School({
    required this.id,
    required this.name,
    required this.address,
    required this.classes,
    required this.sections,
    required this.contact,
    required this.email,
  });

  String id;
  String name;
  String address;
  List<String> classes;
  List<String> sections;
  String contact;
  String email;

  factory School.fromJson(Map<String, dynamic> json) => School(
        id: json["_id"],
        name: json["name"],
        address: json["address"],
        classes: List<String>.from(json["classes"].map((x) => x)),
        sections: List<String>.from(json["sections"].map((x) => x)),
        contact: json["contact"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "schoolId": id,
        "name": name,
        "address": address,
        "classes": List<dynamic>.from(classes.map((x) => x)),
        "sections": List<dynamic>.from(sections.map((x) => x)),
        "contact": contact,
        "email": email,
      };
}
