import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:welfare_attendance_project/provider/app_state.dart';
import 'package:welfare_attendance_project/teacher/classattendance.dart';
import 'package:welfare_attendance_project/teacher/googlesheet.dart';

class ClassDate extends StatefulWidget {
  ClassDate({Key? key, required this.sheetid, required this.classname})
      : super(key: key);

  final sheetid;
  final classname;

  @override
  State<ClassDate> createState() => _ClassDateState();
}

class _ClassDateState extends State<ClassDate> {
  // bool downCsvCheck = false;

  late var appState;
  StreamSubscription<List<int>>? csvListener = null;

  @override
  void dispose() {
    if (csvListener != null) {
      csvListener?.cancel();
      csvListener = null;
    }
    appState.downCsvCheck = false;
    print('disposecsv');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<ApplicationState>();
    print(appState.downCsvCheck);
    //"setState() or markNeedsBuild() called during build 오류 방지 위해 필요
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 여기에서 상태 업데이트 코드 실행
      // 이 부분에서 setState()나 markNeedsBuild() 등을 호출해도 문제 없음
      if (appState.downCsvCheck == false) {
        appState.downloadcsv(widget.sheetid, csvListener).then((listener) {
          csvListener = listener;
        });
        print('fetch11');
        appState.downCsvCheck = true;
      }
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '강의날짜',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: appState.attendancedata == null
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12.0),
                  Text(
                    widget.classname,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  appState.datelist.length != 0
                      ? Expanded(
                          child: GridView.count(
                            crossAxisCount: 1,
                            padding: const EdgeInsets.all(16.0),
                            childAspectRatio: 5.0 / 2.0,
                            children: appState.datelist.map<Widget>((element) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ClassAttendance(
                                              classname: widget.classname,
                                              date: element,
                                              sheetid: widget.sheetid,
                                            )),
                                  );
                                },
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      AspectRatio(
                                        aspectRatio: 1 / 1,
                                        child: Lottie.network(
                                          'https://assets5.lottiefiles.com/packages/lf20_uMjybUoeGN.json',
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8.0, 12.0, 8.0, 0.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    element,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge,
                                                    maxLines: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : Text('출석 명단이 없습니다 작성해주세요'),
                ],
              ),
            ),
    );
  }
}
