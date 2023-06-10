import 'package:flutter/material.dart';
import 'package:welfare_attendance_project/app_state.dart';
import 'package:provider/provider.dart';
import 'package:welfare_attendance_project/googlecloud_config/configuration.dart';
import 'package:gsheets/gsheets.dart';
import 'package:welfare_attendance_project/teacher/googlesheet.dart';

class ClassAttendacnceEdit extends StatefulWidget {
  ClassAttendacnceEdit(
      {Key? key,
      required this.classname,
      required this.date,
      required this.spreadsheetId})
      : super(key: key);
  final classname;
  final date;
  final spreadsheetId;

  @override
  State<ClassAttendacnceEdit> createState() => _ClassAttendacnceEditState();
}

class _ClassAttendacnceEditState extends State<ClassAttendacnceEdit> {
  late var appState;

  Spreadsheet? spreadsheet = null;
  Worksheet? workSheet = null;

  // late String _spreadsheetId;
  final String _workSheetTitle = '시트1';

  @override
  void initState() {
    super.initState();
    initalWorkSheet();
    // _loadCSVaws();
  }

  Future<void> initalWorkSheet() async {
    final gsheets = SheetConfiguration.sheet;
    spreadsheet ??= await gsheets.spreadsheet(widget.spreadsheetId);
    // final service = GSheetService('path/to/credentials.json');
    if (workSheet == null) {
      print('spreadsheet :$spreadsheet');
      workSheet = await spreadsheet!.worksheetByIndex(0)!;
      workSheet ??= await spreadsheet!.addWorksheet(_workSheetTitle);
    }
  }

  void insertRows({
    required List<List<dynamic>>? data,
  }) async {
    if (workSheet == null) {
      print('Worksheet is null.');
      return;
    }

    final result = await workSheet!.values.insertRows(
      1,
      data!,
    );
    print('$_workSheetTitle insertRow completed $result');
  }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<ApplicationState>();
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '출석체크',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.save,
              semanticLabel: 'save',
            ),
            onPressed: () {
              insertRows(data: appState.attendancedata);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.classname,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(width: 12.0),
              Text(
                widget.date,
                style: Theme.of(context).textTheme.bodyLarge,
              )
            ],
          ),
          Expanded(
            child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: _cardtolist(theme)),
          ),
        ],
      ),
    );
  }

  List<Widget> _cardtolist(ThemeData theme) {
    List<Widget> list = [];
    int outindex = 2;
    for (var data in appState.attendancedata) {
      if (data[0] == '이름') {
        int index = 0;
        for (var exceldate in data) {
          if (exceldate == widget.date) {
            outindex = index;
          }
          index++;
        }
      } else {
        if (data[outindex] != 'o')
          data[outindex] = 'x';
        list.add(Card(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data[0]}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text('${data[1]}'),
                    ],
                  ),
                  // SizedBox(width: 20,),
                  InkWell(
                    onTap: () {
                      if (data[outindex] == 'o')
                        setState(() {
                          data[outindex] = 'x';
                        });
                      else {
                        setState(() {
                          data[outindex] = 'o';
                        });
                      }
                    },
                    child: data[outindex] == 'o'
                        ? Icon(
                            Icons.check_circle,
                            size: 40,
                          )
                        : Icon(
                            Icons.close_rounded,
                            size: 40,
                          ),
                  )

                  // Text('${data[2]}')
                ],
              )),
        ));
      }
    }
    return list;
  }
}
