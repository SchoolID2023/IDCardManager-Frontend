import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/school_controller.dart';
import 'package:idcard_maker_frontend/pages/add_id_card.dart';
import 'package:idcard_maker_frontend/widgets/load_id_card_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/login_screen.dart';
import 'widgets/school_tile.dart';

class HomePage extends StatelessWidget {
  final SchoolController schoolController = Get.put(SchoolController());

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
          title: Center(child: const Text('Id Card Maker')),
          actions: Row(
            children: [
              Button(
                child: Text("Log Out"),
                onPressed: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('token');
                  Navigator.of(context)
                      .push(FluentPageRoute(builder: (context) => LoginPage()));
                },
              )
            ],
          )),
      content: ScaffoldPage(
        header: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Row(
            children: [
              Text(
                "Manage School",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.blue,
                ),
              ),
              Spacer(),
              Button(
                child: Text("Add School"),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // content: Center(
        //   child: Column(
        //     children: [

        //       Button(
        //         child: Text("Upload"),
        //         onPressed: () {
        //           showDialog(
        //               context: context, builder: (context) => LoadIdCardData());
        //         },
        //       ),
        //     ],
        //   ),
        // ),
        content: Obx(() {
          return schoolController.isLoading.value
              ? Center(
                  child: ProgressRing(),
                )
              : ListView.builder(
                  itemBuilder: ((context, index) {
                    return SchoolTile(
                      school: schoolController.schools.value.schools[index],
                    );
                  }),
                  itemCount: schoolController.schools.value.schools.length,
                );
          // : Text(schoolController.schools.value.schools.length.toString());
        }),
      ),
    );
  }
}
