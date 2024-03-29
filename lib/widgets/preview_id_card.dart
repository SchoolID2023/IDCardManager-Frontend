import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/id_card_model.dart';
import '../models/student_model.dart';
import '../services/logger.dart';

class PreviewIdCard extends StatelessWidget {
  PreviewIdCard(
      {Key? key,
      required this.idCard,
      required this.isEdit,
      required this.dummyStudent})
      : super(key: key);

  final IdCardModel idCard;
  bool isEdit;
  final Student dummyStudent;

  List<Widget> labelList = [];
  List<Widget> labelBackList = [];

  String getValue(Student student, bool isPhoto, String field) {
    field = field.toLowerCase();

    String value = "";

    logger.d("<---Field --> $field $isPhoto <---${student.name}--->");
    if (isPhoto) {
      // field = field.substring(0, field.length - 6);

      value = student.photo
          .firstWhere(
            (element) => element.field == field,
            orElse: () => Photo(field: field, value: "NullValue"),
          )
          .value;

      value = 'http' + value.substring(5);
    } else {
      if (field == "name") {
        value = student.name;
      } else if (field == "contact") {
        value = student.contact;
      } else if (field == "class") {
        value = student.studentClass;
      } else if (field == "section") {
        value = student.section;
      } else {
        value = student.data
            .firstWhere((element) => element.field == field,
                orElse: () => Datum(
                      field: field,
                      value: "test $field",
                    ))
            .value
            .toString();
      }
    }

    logger.d("Value--> $value");
    return value;
  }

  @override
  Widget build(BuildContext context) {
    // logger.d("ID Card Foreground----->>>>>: ${idCard.foregroundImagePath}");
    // logger.d("ID Card Foreground----->>>>>: ${idCard.foregroundImagePath}");

    logger.d("ID Card Preview");
    logger.d("Id card Height -> ${idCard.height}");
    logger.d("Id card Width -> ${idCard.width}");
    labelList.add(
      SizedBox(
        height: idCard.height.toDouble(),
        width: idCard.width.toDouble(),
        child: isEdit
            ? Image.network(
                idCard.foregroundImagePath,
                fit: BoxFit.cover,
              )
            : Image.file(
                File(
                  idCard.foregroundImagePath,
                ),
                fit: BoxFit.fill,
              ),
      ),
    );

    if (idCard.isDual) {
      labelBackList.add(
        SizedBox(
          height: idCard.height.toDouble(),
          width: idCard.width.toDouble(),
          child: isEdit
              ? Image.network(
                  idCard.backgroundImagePath,
                  fit: BoxFit.fill,
                )
              : Image.file(
                  File(
                    idCard.backgroundImagePath,
                  ),
                  fit: BoxFit.fill,
                ),
        ),
      );
    }

    for (int i = 0; i < idCard.labels.length; i++) {
      if (idCard.labels[i].isPrinted && idCard.labels[i].isFront) {
        labelList.add(
          Positioned(
            top: idCard.labels[i].y.toDouble(),
            left: idCard.labels[i].x.toDouble(),
            child: Container(
              height: idCard.labels[i].height.toDouble(),
              width: idCard.labels[i].width.toDouble(),
              decoration: BoxDecoration(
                image: idCard.labels[i].isPhoto
                    ? DecorationImage(
                        image: NetworkImage(
                          dummyStudent.photo
                              .firstWhere(
                                  (element) =>
                                      idCard.labels[i].title
                                          .toLowerCase()
                                          .contains(
                                              element.field.toLowerCase()) ||
                                      element.field.toLowerCase().contains(
                                          idCard.labels[i].title.toLowerCase()),
                                  orElse: () => Photo(
                                      field: idCard.labels[i].title,
                                      value:
                                          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png"))
                              .value,
                        ),
                        fit: BoxFit.fill,
                      )
                    : null,
              ),
              child: idCard.labels[i].isPhoto
                  ? Container()
                  : Text(
                      textAlign: idCard.labels[i].textAlign == "left"
                          ? TextAlign.left
                          : idCard.labels[i].textAlign == "right"
                              ? TextAlign.right
                              : TextAlign.center,

                      // dummyStudent.data
                      //     .firstWhere(
                      //         (element) =>
                      //             element.field.toLowerCase() ==
                      //             idCard.labels[i].title.toLowerCase(),
                      //         orElse: () => Datum(
                      //               field: idCard.labels[i].title,
                      //               value: "test ${idCard.labels[i].title}",
                      //             ))
                      //     .value
                      //     .toString(),
                      getValue(dummyStudent, false, idCard.labels[i].title),

                      //
                      style: GoogleFonts.asMap()[idCard.labels[i].fontName]!(
                        color: Color(
                          int.parse(
                            idCard.labels[i].color,
                            radix: 16,
                          ),
                        ),
                        fontSize: idCard.labels[i].fontSize.toDouble(),
                        fontWeight: idCard.labels[i].isBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontStyle: idCard.labels[i].isItalic
                            ? FontStyle.italic
                            : FontStyle.normal,
                        decoration: idCard.labels[i].isUnderline
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
            ),
          ),
        );
      } else if (idCard.labels[i].isPrinted) {
        labelBackList.add(
          Positioned(
            top: idCard.labels[i].y.toDouble(),
            left: idCard.labels[i].x.toDouble(),
            child: Container(
              height: idCard.labels[i].height.toDouble(),
              width: idCard.labels[i].width.toDouble(),
              decoration: BoxDecoration(
                image: idCard.labels[i].isPhoto
                    ? const DecorationImage(
                        image: NetworkImage(
                          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
                        ),
                        fit: BoxFit.fill,
                      )
                    : null,
              ),
              child: idCard.labels[i].isPhoto
                  ? Container()
                  : Text(
                      idCard.labels[i].title,
                      style: TextStyle(
                        fontSize: idCard.labels[i].fontSize.toDouble(),
                        color: Color(
                          int.parse(
                            idCard.labels[i].color,
                            radix: 16,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        );
      }
    }

    Widget frontWidget = Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: SizedBox(
        height: idCard.height.toDouble(),
        width: idCard.width.toDouble(),
        child: Stack(children: labelList),
      ),
    );

    Widget backWidget = idCard.isDual
        ? Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
            ),
            child: SizedBox(
              height: idCard.height.toDouble(),
              width: idCard.width.toDouble(),
              child: Stack(children: labelBackList),
            ),
          )
        : Container();
    return ScaffoldPage(
      bottomBar: Button(
        child: const Text("Close"),
        onPressed: () => Navigator.pop(context),
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              frontWidget,
              backWidget,
            ],
          ),
        ),
      ),
    );
  }
}
