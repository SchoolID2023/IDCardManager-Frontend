class IdCardModel {
  List<Label> labels;
  bool isPhoto;
  String backgroundImagePath;
  String? photoPath;
  int? photoWidth;
  int? photoHeight;
  int? photoX;
  int? photoY;

  IdCardModel({
    required this.labels,
    required this.isPhoto,
    required this.backgroundImagePath,
    this.photoPath,
    this.photoWidth,
    this.photoHeight,
    this.photoX,
    this.photoY,
  });
}

class Label {
  String title;
  int color;
  int fontSize;
  int x, y;
  Label({required this.title, required this.color, required this.fontSize, required this.x, required this.y});
}
