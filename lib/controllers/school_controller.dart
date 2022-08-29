import 'package:get/state_manager.dart';
import '../models/schools_model.dart';
import '../services/remote_services.dart';

class SchoolController extends GetxController {
  RemoteServices _remoteServices = RemoteServices();
  var isLoading = true.obs;
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
      var _schools = await _remoteServices.getSchools();
      schools.value = _schools;
    } finally {
      isLoading(false);
    }
  }

  void addSchool(School school) async {
    print("<------>");
    print("Name-> ${school.name}");
    print("Address-> ${school.address}");
    print("Classes-> ${school.classes}");
    print("Sections-> ${school.sections}");
    print("Contact-> ${school.contact}");
    print("Email-> ${school.email}");
    print("<------>");

    try {
      isLoading(true);
      var _newSchool = await _remoteServices.addSchool(school);
      schools.value.schools.add(_newSchool);
    } finally {
      isLoading(false);
    }
  }

  School getSchoolById(String schoolId) {
    print("School Id ---> ${schoolId}");
    return schools.value.schools.firstWhere((school) => school.id == schoolId);
  }
}