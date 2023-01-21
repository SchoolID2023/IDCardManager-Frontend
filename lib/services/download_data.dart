import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:idcard_maker_frontend/models/photos_list_model.dart';

import 'logger.dart';

class DownloadData {
  static Future<void> downloadAndSavePhotos(
      String schoolId, String classes, String sections, String label) async {
    final String response = await rootBundle.loadString('./data.json');
    final data = await json.decode(response) as Map<String, dynamic>;
    final photosList = PhotosList.fromJson(data);
    final classes = photosList.classes;

    for (int i = 0; i < classes.length; i++) {
      for (int j = 0; j < classes[i].sections.length; j++) {
        for (int k = 0; k < classes[i].sections[j].photos.length; k++) {
          final photo = classes[i].sections[j].photos[k];
          String savename = photo.name;
          String savePath =
              "C:/Users/chira/downloads/classes/${classes[i].name}/${classes[i].sections[j].name}/$savename";
          logger.i(savePath);
          try {
            await Dio().download(photo.url, savePath,
                onReceiveProgress: (received, total) {
              if (total != -1) {
                print((received / total * 100).toStringAsFixed(0) + "%");
              }
            });
          } on DioError catch (e) {
            print(e.message);
          }
        }
      }
    }
  }
}
