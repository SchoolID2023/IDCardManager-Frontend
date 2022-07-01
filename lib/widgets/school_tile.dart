import 'package:fluent_ui/fluent_ui.dart';
import '../models/schools_model.dart';

class SchoolTile extends StatelessWidget {
  final School school;
  const SchoolTile({Key? key, required this.school}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return ContentDialog();
            },
          );
        },
        child: Card(
          child: ListTile(
            title: Text(school.name),
            subtitle: Text(school.address),
          ),
        ),
      ),
    );
  }
}
