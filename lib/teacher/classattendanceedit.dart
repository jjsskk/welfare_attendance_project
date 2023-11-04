import 'package:flutter/material.dart';
import 'package:welfare_attendance_project/provider/app_state.dart';
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
  late List<List<dynamic>> _attendanceData;
  bool isFetchAttendace = false;

  bool loading = true;
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

  void fetchAttendaceData() {
    // _attendanceData = List.from(appState.attendancedata); //shallow copy -> current list update apply to provider list
    _attendanceData = [];
    //deep copy
    for (var data in appState.attendancedata) {
      _attendanceData.add(List.from(data)); // copy row list
    }
  }

  Future<void> initalWorkSheet() async {
    final gsheets = SheetConfiguration.sheet;
    spreadsheet ??= await gsheets.spreadsheet(widget.spreadsheetId);
    {
      // final service = GSheetService('path/to/credentials.json');
      if (workSheet == null) {
        print('spreadsheet :$spreadsheet');
        workSheet = await spreadsheet!.worksheetByIndex(0)!;
        workSheet ??= await spreadsheet!.addWorksheet(_workSheetTitle);
        setState(() {
          loading = false;
        });
      }
      setState(() {
        loading = false;
      });
    }
  }

  Future<bool> insertRows({
    required List<List<dynamic>>? data,
  }) async {
    if (workSheet == null) {
      print('Worksheet is null.');
      return Future.value(false);
    }

    final result = await workSheet!.values.insertRows(
      1,
      data!,
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<ApplicationState>();
    final ThemeData theme = Theme.of(context);
    if (!isFetchAttendace) {
      fetchAttendaceData();
      print('fetch');
      isFetchAttendace = true;
    }
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
            onPressed: () async {
              var result = await insertRows(data: _attendanceData);
              {
                print('$_workSheetTitle insertRow completed $result');

                if (result) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('엑셀 파일에 저장되었습니다.')));
                  appState.downCsvCheck = false;

                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('예기치 못한 오류로 저장되지 못했습니다. 다시 시도 해주세요.')));
                }
              }
            },
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
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
    if (!(_attendanceData.first[0].trim() == '이름' &&
        _attendanceData.first[1].trim() == '전화번호')) {
      list.add(Text('이메일로 보낸 sample 엑셀 파일 양식과 맞춰서 출석엑셀파일을 작성해주세요.'));
      return list;
    }

    for (var data in _attendanceData) {
      if (data[0] == '이름') {
        int index = 0;
        for (var exceldate in data) {
          if (exceldate == widget.date) {
            outindex = index;
          }
          index++;
        }
      } else {
        if (data[outindex] != 'o') data[outindex] = 'x';
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
                      Text('${data[1]}'),// call num
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
