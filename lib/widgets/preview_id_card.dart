import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/id_card_model.dart';

class PreviewIdCard extends StatelessWidget {
  PreviewIdCard({Key? key, required this.idCard}) : super(key: key);

  final IdCardModel idCard;

  List<Widget> labelList = [];
  List<Widget> labelBackList = [];

  @override
  Widget build(BuildContext context) {
    labelList.add(
      SizedBox(
        child: Image.file(
          File(
            idCard.foregroundImagePath,
          ),
          fit: BoxFit.fill,
        ),
      ),
    );

    if (idCard.isDual) {
      labelBackList.add(
        Image.file(
          File(
            idCard.backgroundImagePath,
          ),
          fit: BoxFit.fill,
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
                           "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
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
                      
                        idCard.labels[i].title,
                      
                      //
                      style: GoogleFonts.asMap()[idCard.labels[i].fontName]!(
                        color: Color(
                          int.parse(
                            idCard.labels[i].color,
                            radix: 16,
                          ),
                        ),
                        fontSize: idCard.labels[i].fontSize.toDouble(),
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
                    ? DecorationImage(
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
      content: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              frontWidget,
              backWidget,
              Button(child: Text("Close"), onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }
}
