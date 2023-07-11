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
          id: "")
      .obs;

  var schoolLabels = SchoolLabels(
    success: false,
    labels: [],
    photoLabels: [],
  ).obs;

  var role = 0.obs;

  School get getSchool => school.value;
  List<SchoolAdmin> get getAdmins => admins.value.schoolAdmins;
  List<Teacher> get getTeachers => teachers.value.teachers;
  List<Student> get getStudents => students.value.students;
  List<IdCard> get getIdCards => idCardList.value.idCards;
  SchoolLabels get getSchoolLabels => schoolLabels.value;

  Student getStudentById(String studentId) =>
      students.value.students.firstWhere((element) => element.id == studentId);

  SchoolAdmin getAdminById(String adminId) =>
      admins.value.schoolAdmins.firstWhere((element) => element.id == adminId);

  Teacher getTeacherById(String teacherId) =>
      teachers.value.teachers.firstWhere((element) => element.id == teacherId);

  set setLoading(bool value) => isLoading.value = value;

  Future<List<String>> addStudents(
      String schoolId, String excelFile, bool? updateOnly) async {
    try {
      isLoading(true);
      return await _remoteServices.addStudentData(
          schoolId, excelFile, updateOnly);
    } finally {
      await fetchStudents(schoolId);
      isLoading(false);
    }
  }

  void addStudent(Map<String, String?> studentData) async {
    try {
      isLoading(true);
      await _remoteServices.addStudent(studentData);
      schoolId = studentData['currentSchool']!;
    } finally {
      fetchStudents(schoolId);
      isLoading(false);
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

  Future<void> fetchStudents(String schoolId) async {
    logger.d("API -> $schoolId");
    try {
      var students = await _remoteServices.getStudentData(schoolId, role.value);
      this.students.value = students;
    } finally {
      // isLoading(false);
    }
  }

  Future<void> fetchIdCardList(String schoolId) async {
    try {
      // isLoading(true);
      var idCardList =
          await _remoteServices.getIdCardList(schoolId, role.value);
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

  Future<void> fetchAdmins(String schoolId) async {
    try {
      // isLoading(true);
      var admins = await _remoteServices.getSchoolAdmins(schoolId, role.value);
      this.admins.value = admins;
    } finally {
      // isLoading(false);
    }
  }

  Future<void> fetchSchool(String schoolId) async {
    try {
      // isLoading(true);
      logger.i("Fetching Schools ${schoolId}");
      school.value = await _remoteServices.getSchoolById(schoolId, role.value);
    } finally {
      // isLoading(false);
    }
  }

  Future<void> fetchSchoolLabels(String schoolId) async {
    try {
      // isLoading(true);
      logger.i("Fetching School Labels ${schoolId}");
      schoolLabels.value =
          await _remoteServices.getSchoolLabels(schoolId, role.value);
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

  Future<void> fetchTeachers(String schoolId) async {
    try {
      // isLoading(true);
      var teachers =
          await _remoteServices.getSchoolTeachers(schoolId, role.value);
      this.teachers.value = teachers;

      logger.d("Teachers Fetched");
    } finally {
      // isLoading(false);
    }
  }

  void deleteStudent(String studentId, String schoolId) async {
    try {
      // students.value.students.removeWhere((element) => element.id == studentId);
      await _remoteServices.deleteStudent(studentId);
    } finally {
      fetchStudents(schoolId);
    }
  }

  Future<bool> deleteStudentPhoto(
      String photoUrl, String studentId, String schoolId) async {
    try {
      await _remoteServices.deleteStudentPhoto(photoUrl, studentId);
      return true;
    } catch (e) {
      return false;
    } finally {
      fetchStudents(schoolId);
    }
  }

  void editSchoolAdmin(SchoolAdmin admin) async {
    try {
      admins.value.schoolAdmins
          .removeWhere((element) => element.id == admin.id);
      admins.value.schoolAdmins.add(admin);
      await _remoteServices.editSchoolAdmin(admin);
      fetchAdmins(admin.school);
    } catch (e) {
      logger.d("Edit Admin Error:- $e");
    }
  }

  void deleteSchoolAdmin(String adminId, String schoolId) async {
    try {
      await _remoteServices.deleteSchoolAdmin(adminId);
    } finally {
      fetchAdmins(schoolId);
    }
  }

  void editSchoolTeacher(Teacher teacher) async {
    try {
      teachers.value.teachers
          .removeWhere((element) => element.id == teacher.id);
      teachers.value.teachers.add(teacher);
      await _remoteServices.editSchoolTeacher(teacher);
      fetchTeachers(teacher.currentSchool);
    } catch (e) {
      logger.d("Edit Admin Error:- $e");
    }
  }

  void deleteSchoolTeacher(String teacherId, String schoolId) async {
    try {
      await _remoteServices.deleteSchoolTeacher(teacherId);

      teachers.value.teachers.removeWhere((element) => element.id == teacherId);
    } finally {
      fetchAdmins(schoolId);
    }
  }

  void setRole(int role) {
    this.role.value = role;
  }
}
