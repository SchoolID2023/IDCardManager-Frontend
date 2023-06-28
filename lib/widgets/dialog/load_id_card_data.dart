// ignore_for_file: prefer_const_constructors

import 'package:fluent_ui/fluent_ui.dart';

import '../../models/id_card_model.dart';
import '../../pages/add_id_card.dart';

class LoadIdCardData extends StatefulWidget {
  final String schoolId;
  final List<Label> labels;

  const LoadIdCardData(
      {super.key, required this.schoolId, required this.labels});

  @override
  State<LoadIdCardData> createState() => _LoadIdCardDataState();
}

class _LoadIdCardDataState extends State<LoadIdCardData> {
  final TextEditingController _excelPath = TextEditingController();
  bool isDual = false;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _idCardWidth = TextEditingController();
  final TextEditingController _idCardHeight = TextEditingController();
  // final TextEditingController _dpi = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return ContentDialog(
      // backgroundDismiss: true,
      title: Text("Generate ID Card"),
      actions: [
        Button(
            child: Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(FluentPageRoute(
                  builder: (context) => AddIdCardPage(
                        title: _title.text,
                        schoolId: widget.schoolId,
                        labels: widget.labels,
                        isDual: isDual,
                        // idCardWidth: double.parse(_idCardWidth.text) *
                        //     (0.0393701 * 100.0 / pixelRatio),
                        // idCardHeight: double.parse(_idCardHeight.text) *
                        //     (0.0393701 * 100.0 / pixelRatio),
                        idCardWidth: (double.parse(_idCardWidth.text) / 25.4) *
                            (100 / pixelRatio),
                        idCardHeight:
                            (double.parse(_idCardHeight.text) / 25.4) *
                                (100 / pixelRatio),
                        excelPath: _excelPath.text,
                      )));
            }),
        Button(child: Text("CANCEL"), onPressed: () => Navigator.pop(context)),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextBox(
            controller: _title,
            prefix: Text( "Title"),
            placeholder: 'Enter title',
          ),
          Row(
            children: [
              Expanded(
                child: TextBox(
                  controller: _idCardWidth,
                  prefix: Text( "ID Card Width (in mm)"),
                  placeholder: 'Enter width',
                ),
              ),
              Expanded(
                child: TextBox(
                  controller: _idCardHeight,
                  prefix: Text( "ID Card Height (in mm)"),
                  placeholder: 'Enter height',
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Expanded(
              //   child: TextBox(
              //     controller: _dpi,
              //     header: "DPI",
              //     placeholder: 'Enter DPI',
              //   ),
              // ),
              ToggleSwitch(
                checked: isDual,
                onChanged: (_) {
                  setState(() {
                    isDual = !isDual;
                  });
                },
                content: Text("Is Dual"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
