import 'package:flutter/material.dart';

class ManageDataPage extends StatefulWidget {
  const ManageDataPage({Key? key}) : super(key: key);

  @override
  State<ManageDataPage> createState() => _ManageDataPageState();
}

class _ManageDataPageState extends State<ManageDataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Data'),
      ),
    );
  }
}