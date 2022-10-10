import 'package:get/state_manager.dart';
import 'package:idcard_maker_frontend/models/admins_model.dart';
import 'package:idcard_maker_frontend/models/id_card_model.dart';
import 'package:idcard_maker_frontend/models/teacher_list_model.dart';
import '../models/id_card_list_model.dart';
import '../models/student_model.dart';
import '../models/schools_model.dart';
import '../services/remote_services.dart';
import '../services/logger.dart';

class StudentController extends GetxController {
  StudentController(this.schoolId);

  final RemoteServices _remoteServices = RemoteServices();
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


  void addStudents(String schoolId, String excelFile) async {
    try {
      isLoading(true);
      await _remoteServices.addStudentData(schoolId, excelFile);
    } finally {
      fetchStudents(schoolId);
      isLoading(false);
    }
  }

  Future<void> fetchStudents(String schoolId) async {
    logger.d("API -> $schoolId");
    try {
      var students = await _remoteServices.getStudentData(schoolId);
      this.students.value = students;
    } finally {
      // isLoading(false);
    }
  }

  void fetchIdCardList(String schoolId) async {
    try {
      // isLoading(true);
      var idCardList = await _remoteServices.getIdCardList(schoolId);
      this.idCardList.value = idCardList;
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
      var admins = await _remoteServices.getSchoolAdmins(schoolId);
      this.admins.value = admins;
    } finally {
      // isLoading(false);
    }
  }

  void fetchSchool(String schoolId) async {
    try {
      var school = await _remoteServices.getSchoolById(schoolId);
      this.school.value = school;
    } finally {
      // isLoading(false);
    }
  }

  void editSchool(School editSchool) async {
    try {
      school.value = editSchool;
      await _remoteServices.editSchool(editSchool);
    } catch (e) {
      logger.d("Edit School Error:- $e");
    }
  }

  void fetchTeachers(String schoolId) async {
    try {
      var teachers = await _remoteServices.getSchoolTeachers(schoolId);
      this.teachers.value = teachers;

      logger.d("Teachers Fetched");
    } finally {
      // isLoading(false);
    }
  }

  void editStudent(Student student) async {
    try {
      students.value.students
          .removeWhere((element) => element.id == student.id);
      students.value.students.add(student);
      await _remoteServices.editStudent(student);
      fetchStudents(student.currentSchool);
    } catch (e) {
      logger.d("Edit Student Error:- $e");
    }
  }

  void deleteStudent(String studentId) async {
    try {
      students.value.students.removeWhere((element) => element.id == studentId);
      await _remoteServices.deleteStudent(studentId);
    } finally {
      fetchStudents(schoolId);
    }
  }
}
