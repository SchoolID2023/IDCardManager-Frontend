import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';


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
            //   logger.d(mode);
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
          Expanded(
            child: Container(
                //             child: ResizebleWidget(
                //               child: Text(
                //                 '''I've just did simple prototype to show main idea.
                // 1. Draw size handlers with container;
                // 2. Use GestureDetector to get new variables of sizes
                // 3. Refresh the main container size.''',
                //               ),
                //             ), // width: 600,
                ),
          ),
        ],
      ),
    );
  }
}
