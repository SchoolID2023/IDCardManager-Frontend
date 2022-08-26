import 'package:get/state_manager.dart';
import 'package:idcard_maker_frontend/models/admins_model.dart';
import 'package:idcard_maker_frontend/models/id_card_model.dart';
import 'package:idcard_maker_frontend/models/teacher_list_model.dart';
import '../models/id_card_list_model.dart';
import '../models/student_model.dart';
import '../models/schools_model.dart';
import '../services/remote_services.dart';

class StudentController extends GetxController {
  StudentController(this.schoolId);

  RemoteServices _remoteServices = RemoteServices();
  String schoolId;
  var isLoading = false.obs;
  var idCardList =
      IdCardListModel(success: false, message: "Id Card List", idCards: []).obs;

  var students =
      StudentModel(success: false, message: "Student List", students: []).obs;
  var admins =
      AdminsModel(success: false, message: "Admins", schoolAdmins: []).obs;
  var teachers =
      TeacherListModel(success: false, message: "Teachers", teachers: []).obs;

  var school = School(
    address: "",
    classes: [],
    sections: [],
    contact: "",
    email: "",
    name: "",
    id: "",
  ).obs;

  @override
  void onInit() {
    super.onInit();
    // fetchIdCardList(schoolId);
    // fetchStudents(schoolId);
    // fetchSchool(schoolId);
  }

  void addStudents(String schoolId, String excelFile) async {
    try {
      isLoading(true);
      var _students = await _remoteServices.addStudentData(schoolId, excelFile);
    } finally {
      fetchStudents(schoolId);
      isLoading(false);
    }
  }

  void fetchStudents(String schoolId) async {
    print("API -> ${schoolId}");
    try {
      var _students = await _remoteServices.getStudentData(schoolId);
      students.value = _students;
    } finally {
      // isLoading(false);
    }
  }

  void fetchIdCardList(String schoolId) async {
    try {
      // isLoading(true);
      var _idCardList = await _remoteServices.getIdCardList(schoolId);
      idCardList.value = _idCardList;
    } finally {
      // isLoading(false);
    }
  }

  void deleteIdCard(String idCardId) async {
    try {
      await _remoteServices.deleteIdCard(idCardId);
    } finally {
      fetchIdCardList(schoolId);
      // isLoading(false);
    }
  }

  Future<String> addIdCard(IdCardModel idCard) async {
    try {
      var idCardId = await _remoteServices.addIdCard(idCard);

      return idCardId;
    } finally {
      fetchIdCardList(schoolId);
    }
  }

  void fetchAdmins(String schoolId) async {
    try {
      var _admins = await _remoteServices.getSchoolAdmins(schoolId);
      admins.value = _admins;
    } finally {
      // isLoading(false);
    }
  }

  void fetchSchool(String schoolId) async {
    try {
      var _school = await _remoteServices.getSchoolById(schoolId);
      school.value = _school;
    } finally {
      // isLoading(false);
    }
  }

  void editSchool(School editSchool) async {
    try {
      school.value = editSchool;
      await _remoteServices.editSchool(editSchool);
    } catch (e) {
      print("Edit School Error:- ${e}");
    }
  }

  void fetchTeachers(String schoolId) async {
    try {
      var _teachers = await _remoteServices.getSchoolTeachers(schoolId);
      teachers.value = _teachers;

      print("Teachers Fetched");
    } finally {
      // isLoading(false);
    }
  }
}
