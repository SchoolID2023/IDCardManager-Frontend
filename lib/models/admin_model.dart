// To parse this JSON data, do
//
//     final adminModel = adminModelFromJson(jsonString);

import 'dart:convert';

AdminModel adminModelFromJson(String str) =>
    AdminModel.fromJson(json.decode(str));

String adminModelToJson(AdminModel data) => json.encode(data.toJson());

class AdminModel {
  AdminModel({
    required this.admins,
  });

  List<Admin> admins;

  factory AdminModel.fromJson(Map<String, dynamic> json) => AdminModel(
        admins: List<Admin>.from(json["admins"].map((x) => Admin.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "admins": List<dynamic>.from(admins.map((x) => x.toJson())),
      };
}

class Admin {
  Admin({
    required this.id,
    required this.name,
    required this.school,
    required this.contact,
  });

  String name;
  String school;
  String contact;
  String id;

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
        id: json["_id"],
        name: json["name"],
        school: json["school"],
        contact: json["contact"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "school": school,
        "contact": contact,
      };
}
