import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';

import 'pages/add_id_card.dart';
import 'pages/add_school.dart';
import 'pages/manage_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController page = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            controller: page,
            // onDisplayModeChanged: (mode) {
            //   print(mode);
            // },
            style: SideMenuStyle(
              displayMode: SideMenuDisplayMode.auto,
              hoverColor: Colors.blue[100],
              selectedColor: Colors.lightBlue,
              selectedTitleTextStyle: const TextStyle(color: Colors.white),
              selectedIconColor: Colors.white,
            ),
            title: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 150,
                    maxWidth: 150,
                  ),
                  child: Image.network(
                    'https://www.seekpng.com/png/detail/806-8066056_debit-card-clipart-id-card-id-card-icon.png',
                  ),
                ),
                const Divider(
                  indent: 8.0,
                  endIndent: 8.0,
                ),
              ],
            ),

            footer: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Id Card Manager',
                style: TextStyle(fontSize: 15),
              ),
            ),
            items: [
              SideMenuItem(
                priority: 0,
                title: 'Add School',
                onTap: () {
                  page.jumpToPage(0);
                },
                icon: const Icon(Icons.home),
              ),
              SideMenuItem(
                priority: 1,
                title: 'Add Id Card',
                onTap: () {
                  page.jumpToPage(1);
                },
                icon: const Icon(Icons.supervisor_account),
              ),
              SideMenuItem(
                priority: 2,
                title: 'Manage Data',
                onTap: () {
                  page.jumpToPage(2);
                },
                icon: const Icon(Icons.file_copy_rounded),
              ),
            ],
          ),
          Container(
            width: 600,
            child: PageView(
              controller: page,
              children: [
                AddSchoolPage(),
                AddIdCardPage(),
                ManageDataPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
