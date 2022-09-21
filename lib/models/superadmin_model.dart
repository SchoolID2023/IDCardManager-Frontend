// To parse this JSON data, do
//
//     final superAdmin = superAdminFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

SuperAdmin superAdminFromJson(String str) => SuperAdmin.fromJson(json.decode(str));

String superAdminToJson(SuperAdmin data) => json.encode(data.toJson());

class SuperAdmin {
    SuperAdmin({
        required this.email,
        required this.password,
        required this.name,
        required this.contact,
        required this.username,
    });

    final String email;
    final String password;
    final String name;
    final String contact;
    final String username;

    factory SuperAdmin.fromJson(Map<String, dynamic> json) => SuperAdmin(
        email: json["email"],
        password: json["password"],
        name: json["name"],
        contact: json["contact"],
        username: json["username"],
    );

    Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
        "name": name,
        "contact": contact,
        "username": username,
    };
}
