import 'package:flutter/material.dart';

class AddIdCardPage extends StatefulWidget {
  const AddIdCardPage({Key? key}) : super(key: key);

  @override
  State<AddIdCardPage> createState() => _AddIdCardPageState();
}

class _AddIdCardPageState extends State<AddIdCardPage> {
  @override
  Widget build(BuildContext context) {
    double cwidth = MediaQuery.of(context).size.width;
    double cheight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Id Card'),
      ),
      body: Container(
        width: cwidth,
        child: Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: Colors.blue,
                  child: Text("Hello"),
                ),
              ),
              Container(
                width: 600,
                color: Colors.red,
                child: Text("Hello"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
