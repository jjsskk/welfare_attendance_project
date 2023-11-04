import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:welfare_attendance_project/googlecloud_config/configuration.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';

class ApplicationState extends ChangeNotifier {
  late var _whatuser; //복시사용 로그인 = true

  List<String> _classlist = [];
  Map<String, dynamic>? _maplist =
      {}; // contain bool to check if other teacher take corresponding class and excelid

  Map<String, dynamic>? get maplist => _maplist;

  List<String> get classlist => _classlist;

  get whatuser => _whatuser;

  set whatuser(value) {
    _whatuser = value;
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      classlist_listener() {
    var listen = FirebaseFirestore.instance
        .collection('manager')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      // _number_like = (snapshot.data() as Map<String, dynamic>).keys.toList().length;
      _classlist = snapshot.data()!.keys.toList();
      _classlist.remove('복지사');
      _maplist = snapshot.data();
      _maplist!.remove('복지사'); //remove 복지사 field on upper row
      List<String> keylist = [];
      if (_maplist != null) {
        _maplist?.forEach((key, value) {
          if (value.first == true) //other teacher already took this class
            keylist.add(key);
          // _maplist?.remove(key);
        });
        for (var key in keylist) _maplist?.remove(key);
      }

      notifyListeners();
    });

    return listen;
  }

  var _attendancedata = null;

  set attendancedata(value) {
    _attendancedata = value;
    notifyListeners();
  }

  var _downCsvCheck = false;

  get downCsvCheck => _downCsvCheck;

  set downCsvCheck(value) {
    _downCsvCheck = value;
    notifyListeners();
  }

  get attendancedata => _attendancedata;
  List<String> _datelist = [];

  List<String> get datelist => _datelist;

  Future<StreamSubscription<List<int>>?> downloadcsv(String _spreadsheetId,
      StreamSubscription<List<int>>? previousListener) async {
    if (previousListener != null) {
      previousListener?.cancel();
    }

    final httpClient = http.Client();
    // Load the client secrets JSON file obtained from GCP
    final credentials = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(SheetConfiguration.credentials),
        [drive.DriveApi.driveScope],
        baseClient: httpClient);
    // Create an instance of the Drive API
    final driveApi = drive.DriveApi(credentials);
    // Export the Sheets file as CSV
    final exportMimeType = 'text/csv';
    final response = await driveApi.files.export(_spreadsheetId, exportMimeType,
        downloadOptions: drive.DownloadOptions.fullMedia);
    // stream(response);
    List<int> dataStore = [];

    StreamSubscription<List<int>> listener = response!.stream.listen((data) {
      dataStore = [];
      print('datastore : $dataStore');
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () async {
      Directory tempDir =
          await getTemporaryDirectory(); //Get temp folder using Path Provider
      String tempPath = tempDir.path; //Get path to that location
      File file = File('$tempPath/test'); //Create a dummy file
      await file.writeAsBytes(
          dataStore); //Write to that file from the datastore you created from the Media stream
      String content = file.readAsStringSync(); // Read String from the file
      _attendancedata = const CsvToListConverter().convert(content);
      print(_attendancedata); //Finally you have your text
      print("Task Done");
      _datelist = [];

      if (_attendancedata != null && _attendancedata.isNotEmpty) {
        int index = 0;
        for (var date in _attendancedata[0]) {
          if (index > 1) {
            _datelist.add(date);
          }
          index++;
        }
      }
      notifyListeners();
    }, onError: (error) {
      print("Some Error");
    });
    return listener;
  }

// void stream(var response) {
//   List<int> dataStore = [];
//   var listener = response.stream.listen((data) {
//     print(dataStore);
//     dataStore.insertAll(dataStore.length, data);
//   }, onDone: () async {
//     Directory tempDir =
//         await getTemporaryDirectory(); //Get temp folder using Path Provider
//     String tempPath = tempDir.path; //Get path to that location
//     File file = File('$tempPath/test'); //Create a dummy file
//     await file.writeAsBytes(
//         dataStore); //Write to that file from the datastore you created from the Media stream
//     String content = file.readAsStringSync(); // Read String from the file
//     _attendancedata = const CsvToListConverter().convert(content);
//     print(_attendancedata); //Finally you have your text
//     print("Task Done");
//     _datelist = [];
//
//     if (_attendancedata != null && _attendancedata.lenghth > 0 ) {
//       for (var date in _attendancedata[0]) {
//         if (date != '이름' && date != '전화번호') {
//           _datelist.add(date);
//         }
//       }
//     }
//     notifyListeners();
//   }, onError: (error) {
//     print("Some Error");
//   });
// }
}
