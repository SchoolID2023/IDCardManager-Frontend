import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/controllers/student_controller.dart';

class IdCard extends StatefulWidget {
  final String schoolId;
  const IdCard({super.key, required this.schoolId});

  @override
  State<IdCard> createState() => _IdCardState();
}

class _IdCardState extends State<IdCard> {
  late StudentController studentController;

  int selectedIndex = 0;

  @override
  void initState() {
    studentController = Get.put(StudentController(widget.schoolId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = FluentTheme.of(context);

    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                         Text(
                          "Your ID Cards",
                          style: theme.typography.title,
                        ),
                        IconButton(
                          icon: const Icon(FluentIcons.add),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    studentController.getIdCards.isEmpty
                        ? const Center(
                            child: Text("No ID Cards"),
                          )
                        : ListView.builder(
                            itemCount: studentController.getIdCards.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.accentColor,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Column(
                                          children: [
                                            Image.memory(
                                              base64Decode(
                                                studentController
                                                    .getIdCards[index]
                                                    .foregroundImagePath,
                                              ),
                                              height: 200,
                                              width: 200,
                                              fit: BoxFit.cover,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Text(
                                                studentController
                                                    .getIdCards[index].title,
                                                style: theme.typography.body,
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
                  ],
                ),
              ),
              studentController.getIdCards.isEmpty
                  ? Container()
                  : Flexible(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                studentController
                                    .getIdCards[selectedIndex].title,
                                style: theme.typography.title,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.memory(
                                      base64Decode(
                                        studentController
                                            .getIdCards[selectedIndex]
                                            .foregroundImagePath,
                                      ),
                                      // height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  studentController
                                          .getIdCards[selectedIndex].isDual
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.memory(
                                            base64Decode(
                                              studentController
                                                      .getIdCards[selectedIndex]
                                                      .backgroundImagePath ??
                                                  studentController
                                                      .getIdCards[selectedIndex]
                                                      .foregroundImagePath,
                                            ),
                                            // height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: FilledButton(
                                      child: Text("Edit"),
                                      onPressed: () {},
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Button(
                                      child: Text("Delete"),
                                      onPressed: () {},
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
            ],
          ),
        ),
      );
    });
  }
}
