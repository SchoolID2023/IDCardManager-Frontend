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

  @override
  void onInit() {
    super.onInit();
    fetchSchools();
  }

  void fetchSchools() async {
    try {
      isLoading(true);
      var schools = await _remoteServices.getSchools();
      this.schools.value = schools;
    } catch (e) {
      throw Exception(e);
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
    } finally {
      isLoading(false);
    }
  }

  void deleteSchool(String schoolId) async {
    try {
      isLoading(true);
      await _remoteServices.deleteSchool(schoolId);
      schools.value.schools.removeWhere((element) => element.id == schoolId);
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
