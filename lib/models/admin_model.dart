// To parse this JSON data, do
//
//     final adminModel = adminModelFromJson(jsonString);

import 'dart:convert';

AdminModel adminModelFromJson(String str) => AdminModel.fromJson(json.decode(str));

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
        required this.name,
        required this.school,
        required this.contact,
        required this.email,
        required this.password,
    });

    String name;
    String school;
    String contact;
    String email;
    String password;

    factory Admin.fromJson(Map<String, dynamic> json) => Admin(
        name: json["name"],
        school: json["school"],
        contact: json["contact"],
        email: json["email"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "school": school,
        "contact": contact,
        "email": email,
        "password": password,
    };
}
