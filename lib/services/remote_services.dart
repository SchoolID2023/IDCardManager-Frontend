import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import '../models/admin_model.dart';
import '../models/id_card_attach_model.dart';
import '../models/id_card_list_model.dart';
import '../models/id_card_model.dart';
import '../models/student_model.dart';
import '../models/teacher_list_model.dart';
import '../models/teacher_model.dart';
import '../models/admins_model.dart';
import '../models/id_card_generation_model.dart';
import '../models/schools_model.dart';

class RemoteServices {
  static var client = http.Client();
  Dio dio = Dio();

  final String baseUrl = 'https://idcardmaker-1.herokuapp.com';

  Future<String> login(String email, String password, bool isSuperAdmin) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String userType = isSuperAdmin ? 'superAdmin' : 'schoolAdmin';

    final response = await http.post(
      Uri.parse('${baseUrl}/${userType}/login'),
      body: {
        'email': email,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      prefs.setString('token', data['token']);
      prefs.setString('userType', userType);
      prefs.setString('schoolId', data['schoolId']);

      return data['schoolId'];
    } else {
      throw Exception(response.statusCode);
    }
  }

  Future<SchoolsModel> getSchools() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${baseUrl}/superAdmin/viewSchools'),
      headers: {
        'Authorization': 'Biatch $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SchoolsModel.fromJson(data);
    } else {
      throw Exception(response.statusCode);
    }
  }

  Future<School> addSchool(School newSchool) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print("<########>");
    print(json.encode(newSchool.toJson()));
    print("<####>");

    final response = await http.post(
      Uri.parse('${baseUrl}/superAdmin/addSchool'),
      headers: {
        'Authorization': 'Biatch $token',
        "Content-Type": "application/json"
      },
      body: json.encode(newSchool.toJson()),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      data = data['school'];
      print("Data--> ${data}");
      return School.fromJson(data);
    } else {
      throw Exception(response.body);
    }
  }

  Future<School> editSchool(School editSchool) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print("<########>");
    print(json.encode(editSchool.toJson()));
    print("<####>");

    final response = await http.post(
      Uri.parse('${baseUrl}/superAdmin/editSchool'),
      headers: {
        'Authorization': 'Biatch $token',
        "Content-Type": "application/json"
      },
      body: json.encode(editSchool.toJson()),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      data = data['school'];
      print("Data--> ${data}");
      return School.fromJson(data);
    } else {
      throw Exception(response.body);
    }
  }

  Future<void> addSchoolAdmin({
    required String name,
    required String email,
    required String password,
    required String contact,
    required String schoolId,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    AdminModel _admins = AdminModel(admins: [
      Admin(
          name: name,
          school: schoolId,
          contact: contact,
          email: email,
          password: password)
    ]);

    final response = await http.post(
      Uri.parse('${baseUrl}/superAdmin/addSchoolAdmin'),
      headers: {
        'Authorization': 'Biatch $token',
        "Content-Type": "application/json"
      },
      body: json.encode(_admins.toJson()),
    );

    print(response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
    } else {
      throw Exception(response.statusCode);
    }
  }

  Future<void> addSchoolTeacher({
    required String name,
    required String username,
    required String password,
    required String contact,
    required String schoolId,
    required String className,
    required String section,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userType = prefs.getString('userType');

    TeacherModel _teacher = TeacherModel(
      name: name,
      username: username,
      password: password,
      contact: contact,
      teacherModelClass: className,
      section: section,
      school: schoolId,
    );

    final response = await http.post(
      Uri.parse('${baseUrl}/${userType}/addTeacher'),
      headers: {
        'Authorization': 'Biatch $token',
        "Content-Type": "application/json"
      },
      body: json.encode(_teacher.toJson()),
    );

    print(response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      print('Teacher Added');
    } else {
      throw Exception(response.statusCode);
    }
  }

  Future<void> deleteIdCard(String idCardId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userType = prefs.getString('userType');

    final response = await http.post(
      Uri.parse('${baseUrl}/${userType}/deleteIdCard'),
      headers: {
        'Authorization': 'Biatch $token',
        "Content-Type": "application/json"
      },
      body: json.encode({'idCardId': idCardId}),
    );

    print(response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      print('ID Card Deleted');
    } else {
      throw Exception(response.statusCode);
    }
  }

  Future<AdminsModel> getSchoolAdmins(String schoolId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userType = prefs.getString('userType');

    var url = userType == "superAdmin"
        ? '${baseUrl}/${userType}/viewSchoolAdmins/${schoolId}'
        : '${baseUrl}/${userType}/viewSchoolAdmins';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Biatch $token',
        "Content-Type": "application/json"
      },
    );

    print(response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);

      return AdminsModel.fromJson(data);
    } else {
      throw Exception(response.statusCode);
    }
  }

  Future<TeacherListModel> getSchoolTeachers(String schoolId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userType = prefs.getString('userType');

    var url = userType == "superAdmin"
        ? '${baseUrl}/${userType}/getAllTeachers/${schoolId}'
        : '${baseUrl}/${userType}/getAllTeachers';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Biatch $token',
        "Content-Type": "application/json"
      },
    );

    print(response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);

      return TeacherListModel.fromJson(data);
    } else {
      throw Exception(response.statusCode);
    }
  }

  Future<School> getSchoolById(String schoolId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userType = prefs.getString('userType');

    final response = await http.get(
      Uri.parse('${baseUrl}/${userType}/viewSchoolById/${schoolId}'),
      headers: {
        'Authorization': 'Biatch $token',
        "Content-Type": "application/json"
      },
    );

    print(response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data["school"]);

      return School.fromJson(data["school"]);
    } else {
      throw Exception(response.statusCode);
    }
  }

  Future<String> addIdCard(IdCardModel idCard) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print('<########>');
    print(idCard.toJson());
    print('<########>');

    var headers = {
      'Authorization': 'Biatch $token',
    };

    var formMap = idCard.toJson();
    print(idCard.foregroundImagePath);

    formMap['foregroundImagePath'] =
        await MultipartFile.fromFile(idCard.foregroundImagePath);
    if (idCard.isDual) {
      print(idCard.backgroundImagePath);
      formMap['backgroundImagePath'] =
          await MultipartFile.fromFile(idCard.backgroundImagePath);
    }

    var formData = FormData.fromMap(formMap);

    try {
      Response<String> response = await dio.post(
        '${baseUrl}/superAdmin/addIdCard',
        data: formData,
        options: Options(
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.data ?? "") as Map<String, dynamic>;
        var idCardId = data['idCard']['_id'];
        print("Id--> ${idCardId}");
        return idCardId;
      } else {
        throw Exception(response.data);
      }
    } catch (e) {
      print(e);
      return "Error";
    }
  }

  Future<String> editIdCard(
      List<Label> labels, String idCardId, String schoolId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // print('<########>');
    // print(idCard.toJson());
    // print('<########>');

    var headers = {
      'Authorization': 'Biatch $token',
    };

    // var formMap = idCard.toJson();
    // print(idCard.foregroundImagePath);

    // formMap['foregroundImagePath'] =
    //     await MultipartFile.fromFile(idCard.foregroundImagePath);
    // if (idCard.isDual) {
    //   print(idCard.backgroundImagePath);
    //   formMap['backgroundImagePath'] =
    //       await MultipartFile.fromFile(idCard.backgroundImagePath);
    // }

    // var formData = FormData.fromMap(formMap);

    print('Edit Id Card Id-> ${idCardId}');

    Response<String> response = await dio.post(
      '${baseUrl}/superAdmin/editIdCard',
      data: {
        "_id": idCardId,
        "labels": List<dynamic>.from(labels.map((x) => x.toJson())),
      },
      options: Options(
        headers: headers,
      ),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.data ?? "") as Map<String, dynamic>;

      print("Id--> ${idCardId}");
      print("ID Card edited");
      return idCardId;
    } else {
      throw Exception(response.statusCode);
    }
  }

  Future<void> addStudentData(String schoolId, String excelPath) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var headers = {
      'Authorization': 'Biatch $token',
    };

    var formData = FormData.fromMap({
      'schoolId': schoolId,
      'student_list': await MultipartFile.fromFile(excelPath),
    });

    var response;

    try {
      response = await dio.post(
        '${baseUrl}/superAdmin/upload',
        data: formData,
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        print("Added Student Data");
      } else {
        print("Errorrrrr");
        throw Exception(response.data);
      }
    } on DioError catch (e) {
      print(e.response);
    } catch (e) {
      print("Error----->");
      print(e);
    }
  }

  Future<void> editStudent(Student newStudent) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var headers = {
      'Authorization': 'Biatch $token',
    };

    var response;

    print("Edited Student Data:- ${newStudent.toJson()}");

    try {
      response = await dio.post(
        '${baseUrl}/superAdmin/editStudent',
        data: newStudent.toJson(),
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        print("Edited Student Data");
      } else {
        print("Errorrrrr");
        throw Exception(response.data);
      }
    } on DioError catch (e) {
      print(e.response);
    } catch (e) {
      print("Error----->");
      print(e);
    }
  }

  Future<void> deleteStudent(String studentId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var headers = {
      'Authorization': 'Biatch $token',
    };

    var response;

    print("Edited Student Data:- ${studentId}");

    try {
      response = await dio.post(
        '${baseUrl}/superAdmin/deleteStudent',
        data: {
        "id": studentId,
       
      },
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        print("Edited Student Data");
      } else {
        print("Errorrrrr");
        throw Exception(response.data);
      }
    } on DioError catch (e) {
      print(e.response);
    } catch (e) {
      print("Error----->");
      print(e);
    }
  }

  Future<void> uploadStudentPhotos(
      List<String> columns, String filePath, String schoolId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print("Column-> ${columns}");

    var headers = {
      'Authorization': 'Biatch $token',
    };

    var formMap = {
      'columns': jsonEncode(columns),
      'schoolId': schoolId,
      'passportPhotos': await MultipartFile.fromFile(
        filePath,
        filename: 'file.zip',
      ),
    };

    print(formMap);

    var formData = FormData.fromMap(formMap);

    var response;

    try {
      response = await dio.post(
        '${baseUrl}/superAdmin/addStudentPhotos',
        data: formData,
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        print("Added Student Photos");
      } else {
        print("Errorrrrr");
        throw Exception(response.data);
      }
    } on DioError catch (e) {
      print(e.response);
    } catch (e) {
      print("Error----->");
      print(e);
    }
  }

  Future<StudentModel> getStudentData(String schoolId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userType = prefs.getString('userType');

    var headers = {
      'Authorization': 'Biatch $token',
    };

    Response<String> response;

    print("School ID-> ${schoolId}");

    var url = userType == "superAdmin"
        ? '${baseUrl}/${userType}/getStudentData/${schoolId}'
        : '${baseUrl}/${userType}/getStudentData';

    print("School URL- ${url}");
    try {
      response = await dio.get(
        url,
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.data!);
        return StudentModel.fromJson(data);
      } else {
        print("Errorrrrr");
        throw Exception(response.data);
      }
    } on DioError catch (e) {
      print(e.response);
      throw Exception("Dio Error");
    } catch (e) {
      print("Error----->");
      print(e);
      throw Exception("Normal Error");
    }
  }

  Future<IdCardListModel> getIdCardList(String schoolId) async {
    print("School ID-> ${schoolId}");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userType = prefs.getString('userType');

    var headers = {
      'Authorization': 'Biatch $token',
    };

    var url = userType == "superAdmin"
        ? '${baseUrl}/${userType}/getIdCardsBySchool/${schoolId}'
        : '${baseUrl}/${userType}/getIdCardsBySchool';

    Response<String> response;
    try {
      response = await dio.get(
        url,
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.data!);
        // print(data);

        print("Id Card List Added");
        return IdCardListModel.fromJson(data);
      } else {
        print("Errorrrrr");
        throw Exception(response.data);
      }
    } on DioError catch (e) {
      print(e.response);
      throw Exception("Dio Error");
    } catch (e) {
      print("Error----->");
      print(e);
      throw Exception("Normal Error");
    }
  }

  Future<void> generateExcel(
      String schoolId, String className, String section) async {
    print("School ID-> ${schoolId}");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userType = prefs.getString('userType');

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output destination:',
      fileName: "students_${schoolId}_${className}_${section}.xlsx",
    );
    print('Excell Token-> $token');
    var headers = {
      'Authorization': 'Biatch $token',
    };
    var body = {
      "school": schoolId,
      "class": className,
      "section": section,
    };

    var url = userType == "superAdmin"
        ? '${baseUrl}/${userType}/generateExcel'
        : '${baseUrl}/${userType}/generateExcel';

    final response;
    try {
      response = await dio.download(
        url,
        outputFile,
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: body,
      );
      print(response);

      if (response.statusCode == 200) {
        // final data = json.decode(response.data!);
        // print(data);
        print(response.toString());

        print("Excel added");
        return;
      } else {
        print("Errorrrrr");
        throw Exception(response.data);
      }
    } on DioError catch (e) {
      print(e.response);
      throw Exception("Dio Error");
    } catch (e) {
      print("Error----->");
      print(e);
      throw Exception("Normal Error");
    }
  }

  Future<void> attachIDCard(IdCardAttachModel idCard) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userType = prefs.getString('userType');

    var headers = {
      'Authorization': 'Biatch $token',
    };

    var url = '${baseUrl}/${userType}/attachId';

    final response;

    try {
      response = await dio.post(
        url,
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: json.encode(idCard.toJson()),
      );
      print(response);

      if (response.statusCode == 200) {
        // final data = json.decode(response.data!);
        // print(data);
        print(response.toString());

        print("Students Attached");
        return;
      } else {
        print("Errorrrrr");
        throw Exception(response.data);
      }
    } on DioError catch (e) {
      print(e.response);
      throw Exception("Dio Error");
    } catch (e) {
      print("Error----->");
      print(e);
      throw Exception("Normal Error");
    }
  }

  Future<void> downloadPhotos(
      String schoolId, String className, String section, String label) async {
    print("School ID-> ${schoolId}");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userType = prefs.getString('userType');

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output destination:',
      fileName: "students_${schoolId}_${className}_${section}_photos.zip",
    );
    print('Excell Token-> $token');
    var headers = {
      'Authorization': 'Biatch $token',
    };
    var body = {
      "school": schoolId,
      "class": className,
      "section": section,
      "photos": [label]
    };

    var url = userType == "superAdmin"
        ? '${baseUrl}/${userType}/downloadPhotos'
        : '${baseUrl}/${userType}/downloadPhotos';

    final response;
    try {
      response = await dio.download(
        url,
        outputFile,
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: body,
      );
      print(response);

      if (response.statusCode == 200) {
        // final data = json.decode(response.data!);
        // print(data);
        print(response.toString());

        print("Excel added");
        return;
      } else {
        print("Errorrrrr");
        throw Exception(response.data);
      }
    } on DioError catch (e) {
      print(e.response);
      throw Exception("Dio Error");
    } catch (e) {
      print("Error----->");
      print(e);
      throw Exception("Normal Error");
    }
  }

  Future<IdCardGenerationModel> getIdCardGenerationModel(
      String schoolId) async {
    print("School ID-> ${schoolId}");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var headers = {
      'Authorization': 'Biatch $token',
    };

    Response<String> response;
    try {
      response = await dio.get(
        '${baseUrl}/superAdmin/getIdDetails/${schoolId}',
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.data!);

        print(data);

        print("Id Card Generation Model Added");
        return IdCardGenerationModel.fromJson(data);
      } else {
        print("Errorrrrr");
        throw Exception(response.data);
      }
    } on DioError catch (e) {
      print(e.response);
      throw Exception("Dio Error");
    } catch (e) {
      print("Error----->");
      print(e);
      throw Exception("Normal Error");
    }
  }
}
