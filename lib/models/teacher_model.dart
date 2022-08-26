// To parse this JSON data, do
//
//     final teacherModel = teacherModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

TeacherModel teacherModelFromJson(String str) => TeacherModel.fromJson(json.decode(str));

String teacherModelToJson(TeacherModel data) => json.encode(data.toJson());

class TeacherModel {
    TeacherModel({
        required this.name,
        required this.username,
        required this.password,
        required this.contact,
        required this.teacherModelClass,
        required this.section,
        required this.school,
    });

    String name;
    String username;
    String password;
    String contact;
    String teacherModelClass;
    String section;
    String school;

    factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
        name: json["name"],
        username: json["username"],
        password: json["password"],
        contact: json["contact"],
        teacherModelClass: json["class"],
        section: json["section"],
        school: json["school"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "username": username,
        "password": password,
        "contact": contact,
        "class": teacherModelClass,
        "section": section,
        "school": school,
    };
}
