import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:excel/excel.dart';

import '../models/id_card_model.dart';
import '../pages/add_id_card.dart';

class LoadIdCardData extends StatefulWidget {
  @override
  State<LoadIdCardData> createState() => _LoadIdCardDataState();
}

class _LoadIdCardDataState extends State<LoadIdCardData> {
  List<Label> labels = [];
  TextEditingController _excelPath = TextEditingController();
  bool isDual = false;
  TextEditingController _idCardWidth = TextEditingController();
  TextEditingController _idCardHeight = TextEditingController();

  Future<void> uploadExcel() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ['xls', 'xlsx'],
    );

    var file = result?.files.first;

    var bytes = File(file!.path.toString()).readAsBytesSync();

    setState(() {
      _excelPath.text = file!.path.toString();
    });

    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      print(table); //sheet Name
      print(excel.tables[table]?.maxCols);
      print(excel.tables[table]?.maxRows);
      for (var cell in excel.tables[table]!.rows[0]) {
        print("${cell?.value}");
        labels.add(
          Label(
            title: cell!.value.toString(),
          ),
        );
      }
    }
  }

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
                        labels: labels,
                        isDual: isDual,
                        idCardWidth: double.parse(_idCardWidth.text),
                        idCardHeight: double.parse(_idCardHeight.text),
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
            Row(
              children: [
                Expanded(
                  child: TextBox(
                    controller: _excelPath,
                    header: "Excel Path",
                    readOnly: true,
                  ),
                ),
                Button(
                  child: Text("Upload Excel"),
                  onPressed: () async {
                    await uploadExcel();
                  },
                ),
              ],
            ),
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
