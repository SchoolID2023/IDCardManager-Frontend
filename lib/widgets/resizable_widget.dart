import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keymap/keymap.dart';

import '../models/id_card_model.dart';
import '../services/logger.dart';

class ResizebleWidget extends StatefulWidget {
  ResizebleWidget({required this.label, required this.myScale});

  // final Widget child;
  final Label label;
  final double myScale;

  // final double height, width, top, left;

  @override
  _ResizebleWidgetState createState() => _ResizebleWidgetState();
}

const ballDiameter = 15.0;

class _ResizebleWidgetState extends State<ResizebleWidget> {
  // double height = 400;
  // double _label.width = 200;

  // double top = 0;
  // double _label.x= 0;
  late Label _label;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    logger.d("Scale->${widget.myScale}");
    Label temp = widget.label;
    _label = Label(
      title: temp.title,
      color: temp.color,
      x: temp.x * widget.myScale,
      y: temp.y * widget.myScale,
      width: temp.width * widget.myScale,
      height: temp.height * widget.myScale,
      fontSize: (temp.fontSize * widget.myScale).toInt(),
      fontName: temp.fontName,
      textAlign: temp.textAlign,
      isPhoto: temp.isPhoto,
      isBold: temp.isBold,
      isItalic: temp.isItalic,
      isUnderline: temp.isUnderline,
    );
    // height = widget.label.height;
    // width = widget.label.width;
    // top = widget.label.y;
    // left = widget.label.x;
  }

  void onChange() {
    widget.label.x = _label.x / widget.myScale;
    widget.label.y = _label.y / widget.myScale;
    widget.label.width = _label.width / widget.myScale;
    widget.label.height = _label.height / widget.myScale;
    widget.label.fontSize = _label.fontSize ~/ widget.myScale;
  }

  void onDrag(double dx, double dy) {
    var newHeight = _label.height + dy;
    var newWidth = _label.width + dx;

    setState(() {
      _label.height = newHeight > 20.0 ? newHeight : 20.0;
      _label.width = newWidth > 0 ? newWidth : 0;
      onChange();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardWidget(
      columnCount: 2,
      bindings: [
        KeyAction(
          LogicalKeyboardKey.arrowUp,
          'up the label ${widget.label.title}',
          () {
            setState(() {
              _label.y -= 1;
              onChange();
            });
          },
        ),
        KeyAction(
          LogicalKeyboardKey.arrowDown,
          'increment the counter',
          () {
            setState(() {
              _label.y += 1;
              onChange();
            });
          },
        ),
        KeyAction(
          LogicalKeyboardKey.arrowLeft,
          'increment the counter',
          () {
            setState(() {
              _label.x -= 1;
              onChange();
            });
          },
        ),
        KeyAction(
          LogicalKeyboardKey.arrowRight,
          'increment the counter',
          () {
            setState(() {
              _label.x += 1;
              onChange();
            });
          },
        ),
      ],
      child: Stack(
        children: <Widget>[
          Positioned(
            top: _label.y,
            left: _label.x,
            child: Container(
              height: _label.height ?? 1,
              width: _label.width ?? 1,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
                color: Colors.lightBlue[100],
                image: _label.isPhoto
                    ? const DecorationImage(
                        image: const NetworkImage(
                          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Text(
                _label.title,
                textAlign: _label.textAlign == "left"
                    ? TextAlign.left
                    : _label.textAlign == "right"
                        ? TextAlign.right
                        : TextAlign.center,
                // style: TextStyle(
                //   fontSize: _label.fontSize.toDouble(),
                //   color: Color(int.parse(_label.color, radix: 16)),

                // ),
                style: GoogleFonts.asMap()[_label.fontName]!(
                  color: Color(
                    int.parse(
                      _label.color,
                      radix: 16,
                    ),
                  ),
                  fontSize: _label.fontSize.toDouble(),
                  fontWeight:
                      _label.isBold ? FontWeight.bold : FontWeight.normal,
                  // fontWeight: FontWeight.bold,
                  fontStyle:
                      _label.isItalic ? FontStyle.italic : FontStyle.normal,
                  decoration: _label.isUnderline
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ),
          ),
          Positioned(           
            top: _label.y - ballDiameter / 2,
            left: _label.x - ballDiameter / 2,
            child: ManipulatingCenterBox(
              onDrag: (dx, dy) {
                setState(() {
                  _label.y = _label.y + dy;
                  _label.x = _label.x + dx;
                  onChange();
                });
              },
              scale: widget.myScale,
              height: _label.height,
              width: _label.width,
            ),
          ),
          // top left
          Positioned(
            top: _label.y - ballDiameter / 2,
            left: _label.x - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var mid = (dx + dy) / 2;
                var newHeight = _label.height - 2 * mid;
                var newWidth = _label.width - 2 * mid;

                setState(() {
                  _label.height = newHeight > 20.0 ? newHeight : 20.0;
                  _label.width = newWidth > 0 ? newWidth : 0;
                  _label.y = _label.y + mid;
                  _label.x = _label.x + mid;
                  onChange();
                });
              },
              scale: widget.myScale,
            ),
          ),
          // _label.ymiddle
          Positioned(
            top: _label.y - ballDiameter / 2,
            left: _label.x + _label.width / 2 - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newHeight = _label.height - dy;

                setState(() {
                  _label.height = newHeight > 20.0 ? newHeight : 20.0;
                  _label.y = _label.y + dy;
                  onChange();
                });
              },
              scale: widget.myScale,
            ),
          ),
          // _label.yright
          Positioned(
            top: _label.y - ballDiameter / 2,
            left: _label.x + _label.width - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var mid = (dx + (dy * -1)) / 2;

                var newHeight = _label.height + 2 * mid;
                var newWidth = _label.width + 2 * mid;

                setState(() {
                  _label.height = newHeight > 20.0 ? newHeight : 20.0;
                  _label.width = newWidth > 0 ? newWidth : 0;
                  _label.y = _label.y - mid;
                  _label.x = _label.x - mid;
                  onChange();
                });
              },
              scale: widget.myScale,
            ),
          ),
          // center right
          Positioned(
            top: _label.y + _label.height / 2 - ballDiameter / 2,
            left: _label.x + _label.width - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newWidth = _label.width + dx;

                setState(() {
                  _label.width = newWidth > 0 ? newWidth : 0;
                  onChange();
                });
              },
              scale: widget.myScale,
            ),
          ),
          // bottom right
          Positioned(
            top: _label.y + _label.height - ballDiameter / 2,
            left: _label.x + _label.width - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var mid = (dx + dy) / 2;

                var newHeight = _label.height + 2 * mid;
                var newWidth = _label.width + 2 * mid;

                setState(() {
                  _label.height = newHeight > 20.0 ? newHeight : 20.0;
                  _label.width = newWidth > 0 ? newWidth : 0;
                  _label.y = _label.y - mid;
                  _label.x = _label.x - mid;
                  onChange();
                });
              },
              scale: widget.myScale,
            ),
          ),
          // bottom center
          Positioned(
            top: _label.y + _label.height - ballDiameter / 2,
            left: _label.x + _label.width / 2 - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newHeight = _label.height + dy;

                setState(() {
                  _label.height = newHeight > 20.0 ? newHeight : 20.0;
                  onChange();
                });
              },
              scale: widget.myScale,
            ),
          ),
          // bottom left
          Positioned(
            top: _label.y + _label.height - ballDiameter / 2,
            left: _label.x - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var mid = (((dx) * -1) + (dy)) / 2;

                var newHeight = _label.height + 2 * mid;
                var newWidth = _label.width + 2 * mid;

                setState(() {
                  _label.height = newHeight > 20.0 ? newHeight : 20.0;
                  _label.width = newWidth > 0 ? newWidth : 0;
                  _label.y = _label.y - mid;
                  _label.x = _label.x - mid;
                  onChange();
                });
              },
              scale: widget.myScale,
            ),
          ),
          //left center
          Positioned(
            top: _label.y + _label.height / 2 - ballDiameter / 2,
            left: _label.x - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newWidth = _label.width - dx;

                setState(() {
                  _label.width = newWidth > 0 ? newWidth : 0;
                  _label.x = _label.x + dx;
                  onChange();
                });
              },
              scale: widget.myScale,
            ),
          ),
          // center center
        ],
      ),
    );
  }
}

class ManipulatingBall extends StatefulWidget {
  const ManipulatingBall({Key? key, required this.onDrag, required this.scale});

  final Function onDrag;
  final double scale;

  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  double initX = 0.0;
  double initY = 0.0;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Container(
        width: ballDiameter,
        height: ballDiameter,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ManipulatingCenterBox extends StatefulWidget {
  const ManipulatingCenterBox(
      {Key? key,
      required this.onDrag,
      required this.scale,
      required this.height,
      required this.width});

  final Function onDrag;
  final double scale;
  final double height;
  final double width;

  @override
  _ManipulatingCenterBoxState createState() => _ManipulatingCenterBoxState();
}

class _ManipulatingCenterBoxState extends State<ManipulatingCenterBox> {
  double initX = 0.0;
  double initY = 0.0;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
            // color: Colors.blue.withOpacity(0.0),

            ),
      ),
    );
  }
}
