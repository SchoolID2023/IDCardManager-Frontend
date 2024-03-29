// To parse this JSON data, do
//
//     final teacherListModel = teacherListModelFromJson(jsonString);

import 'dart:convert';

TeacherListModel teacherListModelFromJson(String str) =>
    TeacherListModel.fromJson(json.decode(str));

String teacherListModelToJson(TeacherListModel data) =>
    json.encode(data.toJson());

class TeacherListModel {
  TeacherListModel({
    required this.success,
    required this.message,
    required this.teachers,
  });

  bool success;
  String message;
  List<Teacher> teachers;

  factory TeacherListModel.fromJson(Map<String, dynamic> json) =>
      TeacherListModel(
        success: json["success"],
        message: json["message"],
        teachers: List<Teacher>.from(
            json["teachers"].map((x) => Teacher.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "teachers": List<dynamic>.from(teachers.map((x) => x.toJson())),
      };
}

class Teacher {
  Teacher({
    required this.id,
    required this.name,
    required this.currentSchool,
    required this.contact,
    required this.teacherClass,
    required this.section,
    required this.v,
  });

  String id;
  String name;
  String currentSchool;
  String contact;
  String teacherClass;
  String section;
  int v;

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
        id: json["_id"],
        name: json["name"],
        currentSchool: json["currentSchool"],
        contact: json["contact"],
        teacherClass: json["class"],
        section: json["section"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "currentSchool": currentSchool,
        "contact": contact,
        "class": teacherClass,
        "section": section,
        "__v": v,
      };
}
