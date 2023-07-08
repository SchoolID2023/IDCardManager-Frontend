// To parse this JSON data, do
//
//     final teacherModel = teacherModelFromJson(jsonString);

import 'dart:convert';

TeacherModel teacherModelFromJson(String str) =>
    TeacherModel.fromJson(json.decode(str));

String teacherModelToJson(TeacherModel data) => json.encode(data.toJson());

class TeacherModel {
  TeacherModel({
    required this.name,
    required this.contact,
    required this.teacherModelClass,
    required this.section,
    required this.school,
  });

  String name;
  String contact;
  String teacherModelClass;
  String section;
  String school;

  factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
        name: json["name"],
        contact: json["contact"],
        teacherModelClass: json["class"],
        section: json["section"],
        school: json["school"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "contact": contact,
        "class": teacherModelClass,
        "section": section,
        "school": school,
      };
}
