import 'package:fluent_ui/fluent_ui.dart';

class ConfirmDelete extends StatefulWidget {
  final String type, name;
  final Function deleteFunction;
  const ConfirmDelete({super.key, required this.type, required this.name, required this.deleteFunction});

  @override
  State<ConfirmDelete> createState() => _ConfirmDeleteState();
}

class _ConfirmDeleteState extends State<ConfirmDelete> {
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("Confirm Delete"),
      content: Text("Are you sure you want to delete ${widget.type} '${widget.name}' ?"),
      actions: [
        Button(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FilledButton(
          child: const Text("Delete"),          
          onPressed: () {
            widget.deleteFunction();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
