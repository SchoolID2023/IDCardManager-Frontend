import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:idcard_maker_frontend/services/remote_services.dart';
import 'package:idcard_maker_frontend/widgets/generate_id_card.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:idcard_maker_frontend/widgets/preview_id_card.dart';
import '../controllers/student_controller.dart';
import '../models/id_card_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' as mat;
import 'package:google_fonts/google_fonts.dart';

import '../models/student_model.dart';
import '../services/logger.dart';
import '../widgets/titlebar/navigation_app_bar.dart';
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class EditIdCardPage extends StatefulWidget {
  final String idCardId;

  const EditIdCardPage({
    Key? key,
    required this.idCardId,
  }) : super(key: key);

  @override
  State<EditIdCardPage> createState() => _EditIdCardPageState();
}

class _EditIdCardPageState extends State<EditIdCardPage> {
  List<MenuFlyoutItem> dropDownButtons = [];
  String imagePath = '';
  var frontfile;
  var backfile;
  var _idCard;
  int nonPhotoLabels = 0;
  bool isInit = true;
  bool isFrontView = true;

  int editableIndex = -1;
  String _pickedColor = "0xFF000000";

  final RemoteServices _remoteServices = RemoteServices();
  late StudentController _studentController;

  void updateEditIndex(int index, bool isChecked) {
    if (isInit || !isChecked) {
      _fontSizeController.text = _idCard.labels[index].fontSize.toString();
      _pickedColor = _idCard.labels[index].color;
      _heightController.text = _idCard.labels[index].height.toString();
      _widthController.text = _idCard.labels[index].width.toString();
      _idCard.labels[index].fontName = _fontName;
      isInit = false;
    } else {
      _idCard.labels[index].color = _pickedColor;
      _idCard.labels[index].fontName = _fontName;
      _idCard.labels[index].fontSize = int.parse(_fontSizeController.text);
    }

    setState(() {
      editableIndex = index;
    });
  }

  void _updatePostion(int dx, int dy) {
    setState(() {
      _idCard.labels[editableIndex].x += dx;
      _idCard.labels[editableIndex].y += dy;
    });
  }

  void uploadForegroundImage() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    setState(() {
      frontfile = result.files.first;
      _idCard.foregroundImagePath = frontfile.path.toString();
    });
  }

  void uploadBackgroundImage() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    setState(() {
      backfile = result.files.first;
      _idCard.backgroundImagePath = backfile.path.toString();
    });
  }

  void reorderData(int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final items = _idCard.labels.removeAt(oldindex);
      _idCard.labels.insert(newindex, items);
    });
  }

  bool showLabels = false;
  bool isTextLabelSection = true;
  bool isLoading = true;

  Set<String> ignoredPlaceholders = {
    "_id",
    "__v",
    "id",
    "currentSchool",
    "idCard",
    "otp",
    "password",
    "username",
  };

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _fontSizeController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _fontName = 'ABeeZee';
  final String _alignment = 'left';
  double scaleFactor = 100.0;

  Student dummyStudent = Student(
    admno: 'Dummy Admno',
    name: 'Dummy Name',
    contact: 'Dummy Contact',
    currentSchool: 'currentSchool',
    data: [],
    id: 'id',
    photo: [],
    section: 'section',
    studentClass: 'studentClass',
    username: 'username',
  );

  // Color _pickerColor = Color(0xffffffff);

  Future<void> getDummyStudent() async {
    await _studentController.fetchStudents(_idCard.schoolId);

    if (_studentController.students.value.students.isNotEmpty) {
      dummyStudent = _studentController.students.value.students[0];
    }

    setState(() {
      isLoading = false;
    });
  }

  void fetchIdCard() async {
    final idGenModel =
        await _remoteServices.getIdCardGenerationModel(widget.idCardId);

    _idCard = idGenModel.idcard;

    _studentController = Get.put(StudentController(_idCard.schoolId));

    // nonPhotoLabels = widget.labels.length;

    for (var element in _idCard.labels) {
      dropDownButtons.add(
        MenuFlyoutItem(
          text: Text(element.title),
          onPressed: () {
            setState(() {
              logger.d("Label Name--> ${element.title}");
              _idCard.labels.add(
                Label(
                  title: element.title,
                  isPhoto: true,
                ),
              );
            });
          },
        ),
      );
    }

    await getDummyStudent();
  }

  @override
  void initState() {
    fetchIdCard();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double cwidth = MediaQuery.of(context).size.width;
    double cheight = MediaQuery.of(context).size.height;
    ThemeData theme = FluentTheme.of(context);

    return isLoading
        ? const ScaffoldPage(
            content: Center(
              child: ProgressRing(),
            ),
          )
        : NavigationView(
            appBar: customNavigationAppBar(_idCard.title, context, actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Button(
                  onPressed: () {
                    Navigator.of(context).push(
                      FluentPageRoute(
                        builder: (context) => PreviewIdCard(
                          idCard: _idCard,
                          isEdit: true,
                          dummyStudent: dummyStudent,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Preview",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FilledButton(
                  onPressed: () async {
                    RemoteServices()
                        .editIdCard(
                            _idCard.labels, _idCard.id, _idCard.schoolId)
                        .then(
                          (value) => Navigator.of(context).pop(),
                        );
                  },
                  child: const Text(
                    "Edit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ]),
            content: ScaffoldPage(
              header: editableIndex == -1
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: mat.Card(
                                margin: EdgeInsets.zero,
                                elevation: 0,
                                color: theme.scaffoldBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: theme.acrylicBackgroundColor),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: mat.DropdownButton(
                                    items: GoogleFonts.asMap()
                                        .map((key, value) {
                                          return MapEntry(
                                            key,
                                            mat.DropdownMenuItem<String>(
                                              value: key,
                                              child: Text(
                                                key,
                                                // style: GoogleFonts.getFont(key),
                                              ),
                                            ),
                                          );
                                        })
                                        .values
                                        .toList(),
                                    value: _fontName,
                                    onChanged: (fontName) {
                                      setState(() {
                                        _fontName = fontName.toString();
                                        _idCard.labels[editableIndex].fontName =
                                            _fontName;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 160,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: theme.acrylicBackgroundColor),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      mat.VerticalDivider(
                                        color: theme.acrylicBackgroundColor,
                                        thickness: 1,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _idCard.labels[editableIndex]
                                                  .fontSize--;
                                              _fontSizeController.text = _idCard
                                                  .labels[editableIndex]
                                                  .fontSize
                                                  .toString();
                                            });
                                          },
                                          icon: const Icon(
                                            FluentIcons.calculator_subtract,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextBox(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 0,
                                            ),
                                          ),
                                          controller: _fontSizeController,
                                          onChanged: (_) {
                                            setState(() {
                                              _idCard.labels[editableIndex]
                                                      .fontSize =
                                                  _fontSizeController
                                                          .text.isEmpty
                                                      ? 0
                                                      : int.parse(
                                                          _fontSizeController
                                                              .text);
                                            });
                                          },
                                        ),
                                      ),
                                      mat.VerticalDivider(
                                        color: theme.acrylicBackgroundColor,
                                        thickness: 1,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _idCard.labels[editableIndex]
                                                  .fontSize++;
                                              _fontSizeController.text = _idCard
                                                  .labels[editableIndex]
                                                  .fontSize
                                                  .toString();
                                            });
                                          },
                                          icon: const Icon(
                                            FluentIcons.add,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: Icon(
                                  FluentIcons.font_color,
                                  color: Color(
                                    int.parse(
                                      _idCard.labels[editableIndex].color,
                                      radix: 16,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => ContentDialog(
                                      actions: [
                                        Button(
                                            child: const Text("OK"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            }),
                                      ],
                                      title: const Text('Select Color'),
                                      content: mat.Card(
                                        child: ColorPicker(
                                          portraitOnly: true,
                                          onColorChanged: (Color color) {
                                            setState(() {
                                              _pickedColor = color
                                                  .toString()
                                                  .split('(0x')[1]
                                                  .split(')')[0];
                                              _idCard.labels[editableIndex]
                                                      .color =
                                                  color
                                                      .toString()
                                                      .split('(0x')[1]
                                                      .split(')')[0];
                                            });
                                          },
                                          pickerColor: Color(
                                            int.parse(
                                              _idCard
                                                  .labels[editableIndex].color,
                                              radix: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: theme.acrylicBackgroundColor),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _idCard.labels[editableIndex]
                                                      .isBold =
                                                  !_idCard.labels[editableIndex]
                                                      .isBold;
                                            });
                                            logger.i(
                                                "Bold: ${_idCard.labels[editableIndex].isBold}");
                                          },
                                          icon: const Icon(FluentIcons.bold),
                                        ),
                                      ),
                                      mat.VerticalDivider(
                                        color: theme.acrylicBackgroundColor,
                                        thickness: 1,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _idCard.labels[editableIndex]
                                                      .isItalic =
                                                  !_idCard.labels[editableIndex]
                                                      .isItalic;
                                            });
                                            logger.i(
                                                "Italic: ${_idCard.labels[editableIndex].isItalic}");
                                          },
                                          icon: const Icon(FluentIcons.italic),
                                        ),
                                      ),
                                      mat.VerticalDivider(
                                        color: theme.acrylicBackgroundColor,
                                        thickness: 1,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _idCard.labels[editableIndex]
                                                      .isUnderline =
                                                  !_idCard.labels[editableIndex]
                                                      .isUnderline;
                                            });
                                            logger.i(
                                                "Underline: ${_idCard.labels[editableIndex].isUnderline}");
                                          },
                                          icon:
                                              const Icon(FluentIcons.underline),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: theme.acrylicBackgroundColor),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _idCard.labels[editableIndex]
                                                  .textAlign = "left";
                                            });
                                          },
                                          icon: const Icon(
                                              FluentIcons.align_left),
                                        ),
                                      ),
                                      mat.VerticalDivider(
                                        color: theme.acrylicBackgroundColor,
                                        thickness: 1,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _idCard.labels[editableIndex]
                                                  .textAlign = "center";
                                            });
                                          },
                                          icon: const Icon(
                                              FluentIcons.align_center),
                                        ),
                                      ),
                                      mat.VerticalDivider(
                                        color: theme.acrylicBackgroundColor,
                                        thickness: 1,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _idCard.labels[editableIndex]
                                                  .textAlign = "right";
                                            });
                                          },
                                          icon: const Icon(
                                              FluentIcons.align_right),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: theme.acrylicBackgroundColor),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: SizedBox(
                                          width: 100,
                                          child: TextBox(
                                            placeholder: 'Height',
                                            controller: _heightController,
                                            onChanged: (_) {
                                              setState(() {
                                                _idCard.labels[editableIndex]
                                                    .height = _heightController
                                                        .text.isEmpty
                                                    ? 0.0
                                                    : double.parse(
                                                            _heightController
                                                                .text)
                                                        .toPrecision(2);
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: SizedBox(
                                          width: 100,
                                          child: TextBox(
                                            placeholder: 'Width',
                                            controller: _widthController,
                                            onChanged: (_) {
                                              setState(() {
                                                _idCard.labels[editableIndex]
                                                    .width = _widthController
                                                        .text.isEmpty
                                                    ? 0.0
                                                    : double.parse(
                                                            _widthController
                                                                .text)
                                                        .toPrecision(2);
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
              content: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Image.network(
                                      _idCard.foregroundImagePath,
                                      width: 80,
                                      height: 80,
                                    ),
                                    _idCard.isDual
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.network(
                                              _idCard.backgroundImagePath,
                                              width: 80,
                                              height: 80,
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text("Show Labels"),
                                      Spacer(),
                                      ToggleSwitch(
                                        checked: showLabels,
                                        onChanged: (value) {
                                          setState(() {
                                            showLabels = value;
                                            editableIndex = -1;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        !showLabels
                            ? Container()
                            : Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 10.0),
                                            child: DropDownButton(
                                              items: [
                                                MenuFlyoutItem(
                                                  text:
                                                      const Text("Text Labels"),
                                                  onPressed: () {
                                                    setState(() {
                                                      isTextLabelSection = true;
                                                    });
                                                  },
                                                ),
                                                MenuFlyoutItem(
                                                  text: const Text(
                                                      "Image Labels"),
                                                  onPressed: () {
                                                    setState(() {
                                                      isTextLabelSection =
                                                          false;
                                                    });
                                                  },
                                                ),
                                              ],
                                              leading: const Icon(
                                                FluentIcons.badge,
                                              ),
                                              title: Text(isTextLabelSection
                                                  ? "Text Labels"
                                                  : "Image Labels"),
                                            ),
                                          ),
                                          isTextLabelSection
                                              ? ReorderableListView.builder(
                                                  shrinkWrap: true,
                                                  onReorder: reorderData,
                                                  // controller: ScrollController(),
                                                  itemCount:
                                                      _idCard.labels.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    if (_idCard.labels[index]
                                                        .isPhoto) {
                                                      return Container(
                                                        key: ValueKey(index),
                                                      );
                                                    }
                                                    return GestureDetector(
                                                      key: ValueKey(index),
                                                      onTap: () {
                                                        updateEditIndex(
                                                            index, false);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color: theme
                                                                  .accentColor,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          child: ListTile(
                                                            leading: Checkbox(
                                                              checked: _idCard
                                                                  .labels[index]
                                                                  .isPrinted,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  _idCard
                                                                          .labels[
                                                                              index]
                                                                          .isPrinted =
                                                                      !_idCard
                                                                          .labels[
                                                                              index]
                                                                          .isPrinted;
                                                                });
                                                                if (value ??
                                                                    false) {
                                                                  // editableIndex = index;
                                                                  updateEditIndex(
                                                                      index,
                                                                      true);
                                                                }
                                                              },
                                                            ),
                                                            title: Text(
                                                              _idCard
                                                                  .labels[index]
                                                                  .title,
                                                              style: theme
                                                                  .typography
                                                                  .bodyLarge,
                                                            ),
                                                            trailing: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 8,),
                                                              child: SizedBox(
                                                                width: 100,
                                                                child: Row(
                                                                  children: [
                                                                    _idCard.isDual
                                                                        ? ToggleSwitch(
                                                                            checked: _idCard
                                                                                .labels[index]
                                                                                .isFront,
                                                                            onChanged:
                                                                                (_) {
                                                                              setState(() {
                                                                                _idCard.labels[index].isFront = !_idCard.labels[index].isFront;
                                                                              });
                                                                            },
                                                                            content: _idCard.labels[index].isFront
                                                                                ? const Text("On Front")
                                                                                : const Text("On Back"),
                                                                          )
                                                                        : Container(),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    DropDownButton(
                                                      leading: const Icon(
                                                          FluentIcons.add),
                                                      title: const Text(
                                                          'Add Photo Element'),
                                                      items: dropDownButtons,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: ReorderableListView
                                                          .builder(
                                                        shrinkWrap: true,
                                                        onReorder: reorderData,
                                                        // controller: ScrollController(),
                                                        itemCount: _idCard
                                                            .labels.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          // index = index + nonPhotoLabels;
                                                          if (!_idCard
                                                              .labels[index]
                                                              .isPhoto) {
                                                            return Container(
                                                              key: ValueKey(
                                                                  index),
                                                            );
                                                          }
                                                          int ind = index +
                                                              nonPhotoLabels;
                                                          logger.d(ind);
                                                          return GestureDetector(
                                                            key: ValueKey(ind),
                                                            onTap: () {
                                                              updateEditIndex(
                                                                  ind, false);
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                    color: theme
                                                                        .accentColor,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                ),
                                                                child: ListTile(
                                                                  leading:
                                                                      Checkbox(
                                                                    checked: _idCard
                                                                        .labels[
                                                                            ind]
                                                                        .isPrinted,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        _idCard.labels[ind].isPrinted = !_idCard
                                                                            .labels[ind]
                                                                            .isPrinted;
                                                                      });

                                                                      if (value ??
                                                                          false) {
                                                                        // editableIndex = ind;
                                                                        updateEditIndex(
                                                                            ind,
                                                                            true);
                                                                      }
                                                                    },
                                                                  ),
                                                                  title: Text(
                                                                    _idCard
                                                                        .labels[
                                                                            ind]
                                                                        .title,
                                                                    style: theme
                                                                        .typography
                                                                        .bodyLarge,
                                                                  ),
                                                                  trailing:
                                                                      Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: SizedBox(
                                                                                                                                          width: 100,
                                                                                                                                          child: Row(
                                                                        children: [
                                                                          _idCard.isDual
                                                                              ? ToggleSwitch(
                                                                                  checked: _idCard.labels[ind].isFront,
                                                                                  onChanged: (_) {
                                                                                    setState(() {
                                                                                      _idCard.labels[ind].isFront = !_idCard.labels[ind].isFront;
                                                                                    });
                                                                                  },
                                                                                  content: _idCard.labels[ind].isFront ? const Text("On Front") : const Text("On Back"),
                                                                                )
                                                                              : Container(),
                                                                        ],
                                                                                                                                          ),
                                                                                                                                        ),
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: SizedBox(
                  //     width: 400,
                  //     child: SingleChildScrollView(
                  //       child: Column(
                  //         children: [
                  //           Padding(
                  //             padding: const EdgeInsets.all(8.0),
                  //             child: Row(
                  //               children: [
                  //                 Button(
                  //                   onPressed: uploadForegroundImage,
                  //                   child: const Text('Upload Front Image'),
                  //                 ),
                  //                 const SizedBox(
                  //                   width: 50,
                  //                 ),
                  //                 frontfile == null
                  //                     ? const Text('No file selected')
                  //                     : Image.file(
                  //                         File(
                  //                           frontfile.path.toString(),
                  //                         ),
                  //                         width: 80,
                  //                         height: 80,
                  //                       ),
                  //               ],
                  //             ),
                  //           ),

                  //           _idCard.isDual
                  //               ? Padding(
                  //                   padding: const EdgeInsets.all(8.0),
                  //                   child: Row(
                  //                     children: [
                  //                       Button(
                  //                         onPressed: uploadBackgroundImage,
                  //                         child: const Text('Upload Back Image'),
                  //                       ),
                  //                       const SizedBox(
                  //                         width: 50,
                  //                       ),
                  //                       backfile == null
                  //                           ? const Text('No file selected')
                  //                           : Image.file(
                  //                               File(
                  //                                 backfile.path.toString(),
                  //                               ),
                  //                               width: 80,
                  //                               height: 80,
                  //                             ),
                  //                     ],
                  //                   ),
                  //                 )
                  //               : Container(),

                  //           const Padding(
                  //             padding: EdgeInsets.all(8.0),
                  //             child: ListTile(
                  //               title: Text('Labels'),
                  //             ),
                  //           ),
                  //           Padding(
                  //             padding: const EdgeInsets.all(8.0),
                  // child: ListView.builder(
                  //   shrinkWrap: true,
                  //   controller: ScrollController(),
                  //   itemCount: nonPhotoLabels,
                  //   itemBuilder: (context, index) {
                  //     return GestureDetector(
                  //       onTap: () {
                  //         updateEditIndex(index, false);
                  //       },
                  //       child: ListTile(
                  //         leading: Checkbox(
                  //           checked: _idCard.labels[index].isPrinted,
                  //           onChanged: (value) {
                  //             setState(() {
                  //               _idCard.labels[index].isPrinted =
                  //                   !_idCard.labels[index].isPrinted;
                  //             });
                  //             if (value ?? false) {
                  //               // editableIndex = index;
                  //               updateEditIndex(index, true);
                  //             }
                  //           },
                  //         ),
                  //         title: Text(
                  //           _idCard.labels[index].title,
                  //           style: const TextStyle(
                  //             fontSize: 10,
                  //             color: Color(0xff000000),
                  //           ),
                  //         ),
                  //         trailing: SizedBox(
                  //           width: 200,
                  //           child: Row(
                  //             children: [
                  //               _idCard.isDual
                  //                   ? ToggleSwitch(
                  //                       checked:
                  //                           _idCard.labels[index].isFront,
                  //                       onChanged: (_) {
                  //                         setState(() {
                  //                           _idCard.labels[index]
                  //                                   .isFront =
                  //                               !_idCard.labels[index]
                  //                                   .isFront;
                  //                         });
                  //                       },
                  //                       content:
                  //                           _idCard.labels[index].isFront
                  //                               ? const Text("On Front")
                  //                               : const Text("On Back"),
                  //                     )
                  //                   : Container(),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                  //           ),
                  // DropDownButton(
                  //   leading: const Icon(FluentIcons.add),
                  //   title: const Text('Add Photo Element'),
                  //   items: dropDownButtons,
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: ListView.builder(
                  //     shrinkWrap: true,
                  //     controller: ScrollController(),
                  //     itemCount: _idCard.labels.length - nonPhotoLabels,
                  //     itemBuilder: (context, index) {
                  //       // index = index + nonPhotoLabels;
                  //       int ind = index + nonPhotoLabels;
                  //       logger.d(ind);
                  //       return GestureDetector(
                  //         onTap: () {
                  //           updateEditIndex(ind, false);
                  //         },
                  //         child: ListTile(
                  //           leading: Checkbox(
                  //             checked: _idCard.labels[ind].isPrinted,
                  //             onChanged: (value) {
                  //               setState(() {
                  //                 _idCard.labels[ind].isPrinted =
                  //                     !_idCard.labels[ind].isPrinted;
                  //               });

                  //               if (value ?? false) {
                  //                 // editableIndex = ind;
                  //                 updateEditIndex(ind, true);
                  //               }
                  //             },
                  //           ),
                  //           title: Text(
                  //             _idCard.labels[ind].title,
                  //             style: const TextStyle(
                  //               fontSize: 16,
                  //               color: Color(0xff000000),
                  //             ),
                  //           ),
                  //           trailing: SizedBox(
                  //             width: 200,
                  //             child: Row(
                  //               children: [
                  //                 _idCard.isDual
                  //                     ? ToggleSwitch(
                  //                         checked:
                  //                             _idCard.labels[ind].isFront,
                  //                         onChanged: (_) {
                  //                           setState(() {
                  //                             _idCard.labels[ind].isFront =
                  //                                 !_idCard
                  //                                     .labels[ind].isFront;
                  //                           });
                  //                         },
                  //                         content:
                  //                             _idCard.labels[ind].isFront
                  //                                 ? const Text("On Front")
                  //                                 : const Text("On Back"),
                  //                       )
                  //                     : Container(),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Button(
                  //       onPressed: () async {
                  //         List<String> photoColumns = [];

                  //         _idCard.labels.forEach((label) {
                  //           if (label.isPrinted && label.isPhoto) {
                  //             photoColumns.add(
                  //                 label.title.toString().toLowerCase());
                  //           }
                  //         });

                  //         String idCardId =
                  //             await _studentController.addIdCard(_idCard);

                  //         Navigator.of(context).pop();
                  //       },
                  //       child: const Text('Save')),
                  // ),

                  //           // SizedBox(
                  //           //   width: 300,
                  //           //   height: 100,
                  //           //   child: MaterialColorPicker(
                  //           //     onColorChange: (Color color) {
                  //           //       // Handle color changes
                  //           //     },
                  //           //     selectedColor: Colors.red,
                  //           //   ),
                  //           // ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Flexible(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.acrylicBackgroundColor,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: SingleChildScrollView(
                                      child: GenerateIdCard(
                                        idCard: _idCard,
                                        updateIdCardPosition: _updatePostion,
                                        updateEditIndex: updateEditIndex,
                                        scaleFactor: scaleFactor,
                                        isFrontView: isFrontView,
                                        isEdit: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  _idCard.isDual
                                      ? Row(
                                          children: [
                                            Text("Back"),
                                            ToggleSwitch(
                                              checked: isFrontView,
                                              onChanged: (_) {
                                                setState(() {
                                                  isFrontView = !isFrontView;
                                                });
                                              },
                                            ),
                                            Text("Front"),
                                          ],
                                        )
                                      : Container(),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 100,
                                      child: Slider(
                                        max: 400.0,
                                        min: 100.0,
                                        value: scaleFactor,
                                        onChanged: (v) =>
                                            setState(() => scaleFactor = v),
                                        // Label is the text displayed above the slider when the user is interacting with it.
                                        label: '${scaleFactor.toInt()}',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Container(
                  //   width: 400,
                  //   height: cheight,
                  //   child: editableIndex == -1
                  //       ? const Center(
                  //           child: Text(
                  //             "Please Select a Label",
                  //           ),
                  //         )
                  //       : Column(
                  //           children: [
                  //             TextBox(
                  //               header: 'Font Size',
                  //               controller: _fontSizeController,
                  //               onChanged: (_) {
                  //                 setState(() {
                  //                   _idCard.labels[editableIndex].fontSize =
                  //                       _fontSizeController.text.isEmpty
                  //                           ? 0
                  //                           : double.parse(_fontSizeController.text)
                  //                               .toPrecision(1);
                  //                 });
                  //               },
                  //             ),
                  //             TextBox(
                  //               header: 'Height',
                  //               controller: _heightController,
                  //               onChanged: (_) {
                  //                 setState(() {
                  //                   _idCard.labels[editableIndex].height =
                  //                       _heightController.text.isEmpty
                  //                           ? 0.0
                  //                           : double.parse(_heightController.text)
                  //                               .toPrecision(2);
                  //                 });
                  //               },
                  //             ),
                  //             TextBox(
                  //               header: 'Width',
                  //               controller: _widthController,
                  //               onChanged: (_) {
                  //                 setState(() {
                  //                   _idCard.labels[editableIndex].width =
                  //                       _widthController.text.isEmpty
                  //                           ? 0.0
                  //                           : double.parse(_widthController.text)
                  //                               .toPrecision(2);
                  //                 });
                  //               },
                  //             ),
                  //             Row(
                  //               children: [
                  //                 const Text(
                  //                   "Selected Color",
                  //                 ),
                  //                 GestureDetector(
                  //                   onTap: () {
                  //                     showDialog(
                  //                       context: context,
                  //                       builder: (context) => ContentDialog(
                  //                         actions: [
                  //                           Button(
                  //                               child: const Text("OK"),
                  //                               onPressed: () {
                  //                                 Navigator.of(context).pop();
                  //                               }),
                  //                         ],
                  //                         title: const Text('Select Color'),
                  //                         content: mat.Card(
                  //                           child: ColorPicker(
                  //                             portraitOnly: true,
                  //                             onColorChanged: (Color color) {
                  //                               setState(() {
                  //                                 _pickedColor = color
                  //                                     .toString()
                  //                                     .split('(0x')[1]
                  //                                     .split(')')[0];
                  //                                 _idCard.labels[editableIndex]
                  //                                         .color =
                  //                                     color
                  //                                         .toString()
                  //                                         .split('(0x')[1]
                  //                                         .split(')')[0];
                  //                               });
                  //                             },
                  //                             pickerColor: Color(
                  //                               int.parse(
                  //                                 _idCard.labels[editableIndex].color,
                  //                                 radix: 16,
                  //                               ),
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                     );
                  //                   },
                  //                   child: SizedBox(
                  //                     width: 50,
                  //                     height: 50,
                  //                     child: Container(
                  //                       color: Color(
                  //                         int.parse(
                  //                           _idCard.labels[editableIndex].color,
                  //                           radix: 16,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //             mat.Card(
                  //               child: mat.DropdownButton(
                  //                 items: GoogleFonts.asMap()
                  //                     .map((key, value) {
                  //                       return MapEntry(
                  //                         key,
                  //                         mat.DropdownMenuItem<String>(
                  //                           value: key,
                  //                           child: Text(key),
                  //                         ),
                  //                       );
                  //                     })
                  //                     .values
                  //                     .toList(),
                  //                 value: _fontName,
                  //                 onChanged: (fontName) {
                  //                   setState(() {
                  //                     _fontName = fontName.toString();
                  //                     _idCard.labels[editableIndex].fontName =
                  //                         _fontName;
                  //                     logger.d('Helooooooo $_fontName');
                  //                     logger.d('Helooooooo2 $_fontName');
                  //                   });
                  //                 },
                  //               ),
                  //             ),
                  //             Row(
                  //               children: [
                  //                 SizedBox(
                  //                   height: 25.0,
                  //                   child: Button(
                  //                     child: Container(
                  //                       height: 24,
                  //                       width: 24,
                  //                       color: FluentTheme.of(context).accentColor,
                  //                       child: const Icon(FluentIcons.align_left),
                  //                     ),
                  //                     onPressed: () {
                  //                       setState(() {
                  //                         _idCard.labels[editableIndex].textAlign =
                  //                             "left";
                  //                       });
                  //                     },
                  //                   ),
                  //                 ),
                  //                 SizedBox(
                  //                   height: 25.0,
                  //                   child: Button(
                  //                     child: Container(
                  //                       height: 24,
                  //                       width: 24,
                  //                       color: FluentTheme.of(context).accentColor,
                  //                       child: const Icon(FluentIcons.align_center),
                  //                     ),
                  //                     onPressed: () {
                  //                       setState(() {
                  //                         _idCard.labels[editableIndex].textAlign =
                  //                             "center";
                  //                       });
                  //                     },
                  //                   ),
                  //                 ),
                  //                 SizedBox(
                  //                   height: 25.0,
                  //                   child: Button(
                  //                     child: Container(
                  //                       height: 24,
                  //                       width: 24,
                  //                       color: FluentTheme.of(context).accentColor,
                  //                       child: const Icon(FluentIcons.align_right),
                  //                     ),
                  //                     onPressed: () {
                  //                       setState(() {
                  //                         _idCard.labels[editableIndex].textAlign =
                  //                             "right";
                  //                       });
                  //                     },
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ],
                  //         ),
                  // )
                ],
              ),
            ),
          );
  }
}
