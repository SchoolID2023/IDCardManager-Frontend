class IdCardModel {
  List<Label> labels;
  bool isPhoto;
  int? photoWidth;
  int? photoHeight;

  IdCardModel({
    required this.labels,
    required this.isPhoto,
    this.photoWidth,
    this.photoHeight,
  });
}

class Label {
  String title;
  String color;
  int fontSize;

  Label({required this.title, required this.color, required this.fontSize});
}
