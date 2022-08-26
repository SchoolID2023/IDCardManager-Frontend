// To parse this JSON data, do
//
//     final idCardAttachModel = idCardAttachModelFromJson(jsonString);

import 'package:meta/meta.dart';
import './student_model.dart';
import 'dart:convert';

IdCardAttachModel idCardAttachModelFromJson(String str) => IdCardAttachModel.fromJson(json.decode(str));

String idCardAttachModelToJson(IdCardAttachModel data) => json.encode(data.toJson());

class IdCardAttachModel {
    IdCardAttachModel({
        required this.idCard,
        required this.students,
    });

    String idCard;
    List<Student> students;

    factory IdCardAttachModel.fromJson(Map<String, dynamic> json) => IdCardAttachModel(
        idCard: json["idCard"],
        students: List<Student>.from(json["students"].map((x) => Student.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "idCard": idCard,
        "students": List<dynamic>.from(students.map((x) => x.toJson())),
    };
}

