import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:welfare_attendance_project/provider/app_state.dart';
import 'package:welfare_attendance_project/googlecloud_config/configuration.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'registerclassguide.dart';
import 'package:path_provider/path_provider.dart';

class RegisterClassPage extends StatefulWidget {
  RegisterClassPage({Key? key}) : super(key: key);

  @override
  State<RegisterClassPage> createState() => _RegisterClassPageState();
}

class _RegisterClassPageState extends State<RegisterClassPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  Stream<DocumentSnapshot<Map<String, dynamic>>> _excelnameStream =
      FirebaseFirestore.instance
          .collection('manager')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();

  bool showspiner = false;
  List classlist = <String>[];

  //to send editor email to user through email
  final subject = '액셀 전용 출석 체크 서비스';

  final body = '아래의 편집자 이메일을 가이드 라인에 따라 등록해주세요.\n\n';

  final userEmail = FirebaseAuth.instance.currentUser!.email;

  final cloudEmail =
      'attendancesheet@welfare-attendance-388218.iam.gserviceaccount.com';

  Future<String> find_sheetid() async {
    // Load the client secrets JSON file obtained from GCP
    final credentials = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(SheetConfiguration.credentials),
      [drive.DriveApi.driveReadonlyScope],
    );
    // Create an instance of the Drive API
    final driveApi = drive.DriveApi(credentials);

    // Define the spreadsheet file name
    final fileName = _nameController.text.trim();

    try {
      // Search for the spreadsheet file by name
      final files = await driveApi.files.list(q: "name='$fileName'");

      if (files.files != null && files.files!.isNotEmpty) {
        final _spreadsheetId = files.files!.first.id!;
        // final dirveid = files.files!.first.resourceKey;
        // downloadcsv();
        print('Spreadsheet ID: $_spreadsheetId');
        // print('drive ID: $dirveid');
        return _spreadsheetId;
      } else {
        print('No spreadsheet found with the specified file name');
        return "";
      }
    } catch (e) {
      print('Error: $e');
      return "";
    }
  }

  Future<String> loadSampleFile() async {

    ByteData data = await rootBundle.load('csv/sample.xlsx');
    Uint8List bytes = data.buffer.asUint8List();
    Directory directory = await getApplicationDocumentsDirectory();
    String csvFolderPath = directory.path;

    // Excel 파일 경로 설정
    String excelFilePath = '$csvFolderPath/sample.xlsx';

    // Excel 파일 저장
    File excelFile = File(excelFilePath);
    await excelFile.writeAsBytes(bytes);

    // Excel 파일이 저장된 경로 출력
    print('Excel 파일 경로: $excelFilePath');
    return excelFilePath;
  }


  Future<void> sendEmail() async {
    String path = await loadSampleFile();
    final Email email = Email(
      body: body + cloudEmail,
      subject: subject,
      recipients: [userEmail!],
      attachmentPaths: [path],
      isHTML: false,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = '메일을 보내셨다면 앱에 로그인된 계정 메일함을 확인해주세요!';
    } catch (error) {
      print(error);
      platformResponse = 'Gmail 앱을 사용 할 수 없습니다. Gmail 앱을 설정하고 로그인 해주세요!';
      print(platformResponse);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(platformResponse),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    classlist = appState.classlist;
    loadSampleFile();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '강의등록',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              semanticLabel: 'guide',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegisterClassGuide()),
              );
            },
          )
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showspiner,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            padding: const EdgeInsets.all(24.0),
            children: [
              // Text(
              //     '꼭 순서대로 따라해주세요!\n1.먼저 구글드라이브에서 출석을 관리하고 싶은 강의의 엑셀파일을 만든다\n 2.만든 엑셀 파일에아래의 이메일주소를 편집자로 공유한다\nattendancesheet@welfare-attendance-388218.iam.gserviceaccount.com  \n 3.엑셀파일과 같은 이름을 아래에 입력한다'),
              const Text(
                '반드시 아래의 순서대로 진행해 주세요!\n(※ 사진을 이용한 상세 가이드가 필요하신 경우 1번을 진행 하신 후 우측상단의 아이콘을 눌러주세요)',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
              Text(
                '1. 먼저 아래의 버튼을 클릭해 현재 로그인된 계정에 편집자 이메일 주소와 sample 엑셀 파일을 보내주세요.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Gmail 앱 사용을 권장합니다.(Gmail 앱에 로그인이 됐는지 확인해주세요!)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  ElevatedButton(
                    onPressed: () {
                      // Clipboard.setData(ClipboardData(text: cloudEmail)); // 클릭시 클립보드에 이메일 복사
                      sendEmail();
                    },
                    child: const Text('보내기'),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                '2. 드라이브에서 출석을 관리하고자 하는 강의의 엑셀 파일을 생성해 주세요( 파일 내용은 메일로 받은 sample 엑셀 파일 양식을 꼭 따라주세요!)\n(※ [새로 만들기] - [Google 스프레드시트] 클릭)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12.0),
              Text(
                '3. 생성한 엑셀 파일에서 메일로 받은 편집자 이메일을 공유해 주세요\n(※ [공유] 클릭 - [사용자 및 그룹 추가] 칸에 편집자 이메일 주소 입력 - [전송] 클릭)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12.0),
              Text(
                '4. 엑셀 파일의 이름을 아래의 [강의 이름] 칸에 입력하신 후 [등록] 버튼을 눌러주세요\n(※ 엑셀 파일의 이름은 강의 이름과 동일해야 합니다)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '강의 이름을 입력해주세요';
                          }
                          return null;
                        },
                        controller: _nameController,
                        decoration: const InputDecoration(
                          filled: true,
                          labelText: '강의 이름',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            showspiner = true;
                          });
                          final sheetid = await find_sheetid();
                          setState(() {
                            showspiner = false;
                          });
                          if (sheetid == "")
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('생성한 엑셀 파일 이름을 정확하게 입력해 주세요')));
                          else {
                            await FirebaseFirestore.instance
                                .collection('manager')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update(<String, dynamic>{
                              _nameController.text.trim(): [false, sheetid],
                            });
                            // await FirebaseFirestore.instance
                            //     .collection('manager')
                            //     .doc(FirebaseAuth.instance.currentUser!.uid)
                            //     .collection('teacher')
                            // .doc(FirebaseAuth.instance.currentUser!.uid)
                            // .update(<String,dynamic>{
                            //   _nameController.text.trim() : false
                            // });
                          }
                        }
                      },
                      child: const Text('등록'))
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                '강의 리스트',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: classlist.length,
                itemBuilder: (context, index) {
                  var value = classlist[index];

                  return ListTile(
                    leading: Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('manager')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update(
                                <String, dynamic>{value: FieldValue.delete()});

                        // print(
                      },
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
