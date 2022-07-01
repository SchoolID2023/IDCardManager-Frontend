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
}
