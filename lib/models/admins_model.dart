// To parse this JSON data, do
//
//     final adminsModel = adminsModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

AdminsModel adminsModelFromJson(String str) => AdminsModel.fromJson(json.decode(str));

String adminsModelToJson(AdminsModel data) => json.encode(data.toJson());

class AdminsModel {
    AdminsModel({
        required this.success,
        required this.message,
        required this.schoolAdmins,
    });

    bool success;
    String message;
    List<SchoolAdmin> schoolAdmins;

    factory AdminsModel.fromJson(Map<String, dynamic> json) => AdminsModel(
        success: json["success"],
        message: json["message"],
        schoolAdmins: List<SchoolAdmin>.from(json["schoolAdmins"].map((x) => SchoolAdmin.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "schoolAdmins": List<dynamic>.from(schoolAdmins.map((x) => x.toJson())),
    };
}

class SchoolAdmin {
    SchoolAdmin({
        required this.id,
        required this.email,
        required this.password,
        required this.name,
        required this.school,
        required this.contact,
        required this.v,
    });

    String id;
    String email;
    String password;
    String name;
    String school;
    String contact;
    int v;

    factory SchoolAdmin.fromJson(Map<String, dynamic> json) => SchoolAdmin(
        id: json["_id"],
        email: json["email"],
        password: json["password"],
        name: json["name"],
        school: json["school"],
        contact: json["contact"],
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "email": email,
        "password": password,
        "name": name,
        "school": school,
        "contact": contact,
        "__v": v,
    };
}
