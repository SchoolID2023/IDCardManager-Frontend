import 'package:fluent_ui/fluent_ui.dart';

import '../models/student_model.dart';

class EditStudent extends StatefulWidget {
  final Student student;
  const EditStudent({Key? key, required this.student}) : super(key: key);

  @override
  State<EditStudent> createState() => _EditStudentState();
}

class _EditStudentState extends State<EditStudent> {
  bool isLoading = true;
  late Student student;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    student = widget.student;
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      actions: [
        Button(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Button(
          child: Text("Save"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      title: const Text("Edit Student"),
      content: isLoading == true
          ? const Center(child: ProgressRing())
          : ListView.builder(
              shrinkWrap: true,
              itemCount: student.data.length,
              itemBuilder: (context, index) {
                return TextBox(
                  placeholder: widget.student.data[index].value.toString(),
                  header: widget.student.data[index].field.toString(),
                  onChanged: (value) {
                    student.data[index].value = value;
                  },
                );
              },
            ),
    );
  }
}
