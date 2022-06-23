import 'package:flutter/material.dart';

class AddSchoolPage extends StatefulWidget {
  const AddSchoolPage({Key? key}) : super(key: key);

  @override
  State<AddSchoolPage> createState() => _AddSchoolPageState();
}

class _AddSchoolPageState extends State<AddSchoolPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add School'),
      ),
    );
  }
}
