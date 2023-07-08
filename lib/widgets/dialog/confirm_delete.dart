import 'package:fluent_ui/fluent_ui.dart';

class ConfirmDelete extends StatefulWidget {
  final String type, name;
  final Function deleteDialogueFunction;
  final bool deletePhoto;
  const ConfirmDelete({
    super.key,
    required this.type,
    required this.name,
    required this.deleteDialogueFunction,
    required this.deletePhoto,
  });

  @override
  State<ConfirmDelete> createState() => _ConfirmDeleteState();
}

class _ConfirmDeleteState extends State<ConfirmDelete> {
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("Confirm Delete"),
      content: widget.deletePhoto
          ? Text(
              "Are you sure you want to delete photo for  ${widget.type} '${widget.name}' ?")
          : Text(
              "Are you sure you want to delete ${widget.type} '${widget.name}' ?"),
      actions: [
        Button(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FilledButton(
          child: const Text("Delete"),
          onPressed: () async {
            await widget.deleteDialogueFunction();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
