import 'package:get/state_manager.dart';
import '../models/schools_model.dart';
import '../models/superadmin_model.dart';
import '../services/remote_services.dart';
import '../services/logger.dart';

class SchoolController extends GetxController {
  final RemoteServices _remoteServices = RemoteServices();
  var isLoading = true.obs;
  // var isError = false.obs;
  var schools =
      SchoolsModel(success: false, message: "Schools List", schools: []).obs;

  var superAdmins = <SuperAdmin>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  List<School> get getSchools => schools.value.schools;
  List<SuperAdmin> get getSuperAdmins => superAdmins.value;

  set setLoading(bool value) => isLoading.value = value;

  Future<void> fetchSchools() async {
    try {
      var schools = await _remoteServices.getSchools();
      this.schools.value = schools;
    } catch (e) {
      throw Exception(e);
    } finally {}
  }

  Future<void> fetchSuperAdmins() async {
    try {
      var superAdmins = await _remoteServices.getSuperAdmins();
      this.superAdmins.value = superAdmins;
    } catch (e) {
      throw Exception(e);
    } finally {}
  }

  Future<void> deleteSuperAdmin(String superAdminId) async {
    try {
      isLoading(true);
      await _remoteServices.deleteSuperAdmin(superAdminId);
      superAdmins.value.removeWhere((element) => element.id == superAdminId);
      fetchSuperAdmins();
    } finally {
      isLoading(false);
    }
  }

  void addSchool(School school) async {
    logger.d("<------>");
    logger.d("Name-> ${school.name}");
    logger.d("Address-> ${school.address}");
    logger.d("Classes-> ${school.classes}");
    logger.d("Sections-> ${school.sections}");
    logger.d("Contact-> ${school.contact}");
    logger.d("Email-> ${school.email}");
    logger.d("<------>");

    try {
      isLoading(true);
      var newSchool = await _remoteServices.addSchool(school);
      schools.value.schools.add(newSchool);
      fetchSchools();
    } finally {
      isLoading(false);
    }
  }

  void deleteSchool(String schoolId) async {
    try {
      isLoading(true);
      await _remoteServices.deleteSchool(schoolId);
      schools.value.schools.removeWhere((element) => element.id == schoolId);
      fetchSchools();
    } finally {
      isLoading(false);
    }
  }

  void addSuperAdmin(SuperAdmin superAdmin) async {
    logger.d("<------>");
    logger.d("Name-> ${superAdmin.name}");
    logger.d("Email-> ${superAdmin.email}");
    logger.d("Contact-> ${superAdmin.contact}");
    logger.d("Username-> ${superAdmin.username}");
    logger.d("Password-> ${superAdmin.password}");
    logger.d("<------>");

    try {
      isLoading(true);
      await _remoteServices.addSuperAdmin(superAdmin);
      fetchSuperAdmins();
      // schools.value.schools.add(_newSuperAdmin);
    } finally {
      isLoading(false);
    }
  }

  School getSchoolById(String schoolId) {
    logger.d("School Id ---> $schoolId");
    return schools.value.schools.firstWhere((school) => school.id == schoolId);
  }
}
