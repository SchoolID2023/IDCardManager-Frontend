// To parse this JSON data, do
//
//     final studentModel = studentModelFromJson(jsonString);

import 'dart:convert';

StudentModel studentModelFromJson(String str) =>
    StudentModel.fromJson(json.decode(str));

String studentModelToJson(StudentModel data) => json.encode(data.toJson());

class StudentModel {
  StudentModel({
    required this.success,
    required this.message,
    required this.students,
  });

  bool success;
  String message;
  List<Student> students;

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        success: json["success"],
        message: json["message"],
        students: List<Student>.from(
            json["students"].map((x) => Student.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "students": List<dynamic>.from(students.map((x) => x.toJson())),
      };
}

class Student {
  Student({
    required this.admno,
    required this.name,
    required this.contact,
    required this.username,
    required this.studentClass,
    required this.section,
    required this.currentSchool,
    required this.id,
    required this.photo,
    required this.data,
  });

  String admno;
  String name;
  String contact;
  String username;
  String studentClass;
  String section;
  String currentSchool;
  String id;
  List<Photo> photo;
  List<Datum> data;

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        admno: json["admno"],
        name: json["name"],
        contact: json["contact"],
        username: json["username"],
        studentClass: json["class"],
        section: json["section"],
        currentSchool: json["currentSchool"],
        id: json["_id"],
        photo: List<Photo>.from(json["photo"].map((x) => Photo.fromJson(x))),
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "admno": admno,
        "name": name,
        "contact": contact,
        "username": username,
        "class": studentClass,
        "section": section,
        "currentSchool": currentSchool,
        "_id": id,
        "photo": List<dynamic>.from(photo.map((x) => x.toJson())),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    required this.value,
    required this.field,
  });

  dynamic value;
  String field;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        value: json["value"],
        field: json["field"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "field": field,
      };
}

class Photo {
  static const String no_photo =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/1024px-No_image_available.svg.png";
  Photo({
    required this.field,
    required this.value,
  });

  String field;
  String value;

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
        field: json["field"],
        value: json["value"] ?? no_photo,
      );

  Map<String, dynamic> toJson() => {
        "field": field,
        "value": value,
      };
}
