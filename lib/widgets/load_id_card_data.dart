// ignore_for_file: prefer_const_constructors


import 'package:fluent_ui/fluent_ui.dart';

import '../models/id_card_model.dart';
import '../pages/add_id_card.dart';

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
  final TextEditingController _idCardWidth = TextEditingController();
  final TextEditingController _idCardHeight = TextEditingController();

  // Future<void> uploadExcel() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     allowMultiple: false,
  //     allowedExtensions: ['xls', 'xlsx'],
  //   );

  //   var file = result?.files.first;

  //   var bytes = File(file!.path.toString()).readAsBytesSync();

  //   setState(() {
  //     _excelPath.text = file!.path.toString();
  //   });

  //   var excel = Excel.decodeBytes(bytes);

  //   for (var table in excel.tables.keys) {
  //     logger.d(table); //sheet Name
  //     logger.d(excel.tables[table]?.maxCols);
  //     logger.d(excel.tables[table]?.maxRows);
  //     for (var cell in excel.tables[table]!.rows[0]) {
  //       logger.d("${cell?.value}");
  //       labels.add(
  //         Label(
  //           title: cell!.value.toString(),
  //         ),
  //       );
  //     }

  //     break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text("Generate ID Card"),
      actions: [
        Button(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).push(FluentPageRoute(
                  builder: (context) => AddIdCardPage(
                        schoolId: widget.schoolId,
                        labels: widget.labels,
                        isDual: isDual,
                        idCardWidth:
                            double.parse(_idCardWidth.text) * 3.7795275591,
                        idCardHeight:
                            double.parse(_idCardHeight.text) * 3.7795275591,
                        excelPath: _excelPath.text,
                      )));
            }),
        Button(child: Text("CANCEL"), onPressed: () => Navigator.pop(context)),
      ],
      content: SizedBox(
        width: 500,
        height: 250,
        child: Column(
          children: [
            // Row(
            //   children: [
            //     Expanded(
            //       child: TextBox(
            //         controller: _excelPath,
            //         header: "Excel Path",
            //         readOnly: true,
            //       ),
            //     ),
            //     Button(
            //       child: Text("Upload Excel"),
            //       onPressed: () async {
            //         await uploadExcel();
            //       },
            //     ),
            //   ],
            // ),
            Row(
              children: [
                Expanded(
                  child: TextBox(
                    controller: _idCardWidth,
                    header: "ID Card Width",
                  ),
                ),
                Expanded(
                  child: TextBox(
                    controller: _idCardHeight,
                    header: "ID Card Height",
                  ),
                ),
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
      ),
    );
  }
}
