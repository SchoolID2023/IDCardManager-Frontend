// To parse this JSON data, do
//
//     final photosList = photosListFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

PhotosList photosListFromJson(String str) =>
    PhotosList.fromJson(json.decode(str));

String photosListToJson(PhotosList data) => json.encode(data.toJson());

class PhotosList {
  PhotosList({
    required this.classes,
  });

  final List<Class> classes;

  factory PhotosList.fromJson(Map<String, dynamic> json) => PhotosList(
        classes:
            List<Class>.from(json["classes"].map((x) => Class.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "classes": List<dynamic>.from(classes.map((x) => x.toJson())),
      };
}

class Class {
  Class({
    required this.name,
    required this.sections,
  });

  final String name;
  final List<Section> sections;

  factory Class.fromJson(Map<String, dynamic> json) => Class(
        name: json["name"],
        sections: List<Section>.from(
            json["sections"].map((x) => Section.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "sections": List<dynamic>.from(sections.map((x) => x.toJson())),
      };
}

class Section {
  Section({
    required this.name,
    required this.photos,
  });

  final String name;
  final List<Photo> photos;

  factory Section.fromJson(Map<String, dynamic> json) => Section(
        name: json["name"],
        photos: List<Photo>.from(json["photos"].map((x) => Photo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "photos": List<dynamic>.from(photos.map((x) => x.toJson())),
      };
}

class Photo {
  Photo({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
        name: json["name"],
        url: json["URL"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "URL": url,
      };
}
