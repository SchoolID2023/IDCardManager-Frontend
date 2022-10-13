import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:get/get.dart';

import '../../controllers/student_controller.dart';
import '../../models/student_model.dart';
import '../generate_id_card_list.dart';

class GenerateIdCard extends StatefulWidget {
  final String schoolId;
  final List<Student> students;
  final Map<String, bool> isSelected;
  const GenerateIdCard({
    super.key,
    required this.students,
    required this.isSelected,
    required this.schoolId,
  });

  @override
  State<GenerateIdCard> createState() => _GenerateIdCardState();
}

class _GenerateIdCardState extends State<GenerateIdCard> {
  late StudentController studentController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    studentController = Get.put(StudentController(widget.schoolId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = FluentTheme.of(context);
    return ContentDialog(
      title: Text(
        'Select the ID Card Template you want to use',
        style: theme.typography.title,
      ),
      content: SizedBox(
        height: 210,
        child: Scrollbar(
          controller: _scrollController,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: studentController.getIdCards.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      FluentPageRoute(
                        builder: (context) => GenerateIdCardList(
                          idCardId: studentController.getIdCards[index].id,
                          students: widget.students,
                          isSelected: widget.isSelected,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          children: [
                            Image.memory(
                              base64Decode(
                                studentController
                                    .getIdCards[index].foregroundImagePath,
                              ),
                              height: 120,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                studentController.getIdCards[index].title,
                                style: theme.typography.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      actions: [
        FilledButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, 'User canceled dialog'),
        ),
      ],
    );
  }
}
