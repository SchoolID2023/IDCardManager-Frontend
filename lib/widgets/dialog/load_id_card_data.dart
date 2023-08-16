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
            prefix: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text( "Title"),
            ),
            placeholder: 'Enter title',
          ),
         const SizedBox(height:12),
          Row(
            children: [
              Expanded(
                child: TextBox(
                  controller: _idCardWidth,
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 2.0),
                    child: Text( "Width (in mm)", style:TextStyle(fontSize: 10,)),
                  ),
                  placeholder: 'Enter width',
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextBox(
                  controller: _idCardHeight,
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 2.0),
                    child: Text( "Height (in mm)",  style: TextStyle(
                          fontSize: 10,
                        )),
                  ),
                  placeholder: 'Enter height',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
