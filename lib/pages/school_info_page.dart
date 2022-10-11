import 'package:fluent_ui/fluent_ui.dart';

import '../widgets/titlebar/navigation_app_bar.dart';
import 'school/home.dart';

class SchoolInfoPage extends StatefulWidget {
  final String schoolId;
  const SchoolInfoPage({super.key, required this.schoolId});

  @override
  State<SchoolInfoPage> createState() => _SchoolInfoPageState();
}

class _SchoolInfoPageState extends State<SchoolInfoPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: customNavigationAppBar("School Info", context),
      pane: NavigationPane(
        selected: index,
        onChanged: (newIndex) {
          setState(() {
            index = newIndex;
          });
        },
        displayMode: PaneDisplayMode.auto,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text("Home"),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.people),
            title: const Text("Students"),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.i_d_badge),
            title: const Text("ID Cards"),
          ),
        ],
      ),
      content: NavigationBody(
        index: index,
        children: [
          Home(
            schoolId: widget.schoolId,
            key: Key(widget.schoolId),
          ),
          const Text("Students"),
          const Text("ID Cards"),
        ],
      ),
    );
  }
}
