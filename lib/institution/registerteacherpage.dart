import 'package:flutter/material.dart';
import 'package:welfare_attendance_project/institution/qrscanner/qrscanner.dart';
import 'package:welfare_attendance_project/provider/app_state.dart';
import 'calender.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class RegisterTeacherPage extends StatefulWidget {
  RegisterTeacherPage({Key? key}) : super(key: key);

  @override
  State<RegisterTeacherPage> createState() => _RegisterTeacherPageState();
}

class _RegisterTeacherPageState extends State<RegisterTeacherPage> {
  Map<String, dynamic> _maplist = {};

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  var _calenderController = TextEditingController();

  final _phonenumberController = TextEditingController();

  String dropdownValue = '';

  //for qrcode
  String qrcode = '';
  bool isCheckMyself = false; // true -> save my qrcode
  bool isCheckOther = false; // true ->save other qrcode

  bool isFetchManagerData = false;

  bool transactionSuccessful = false;

  void get_qrcode(String? code) {
    setState(() {
      isCheckOther = true;
      this.qrcode = code!;
    });
  }

  void select_canlender(String calendar) {
    setState(() {
      this._calenderController = TextEditingController(text: calendar);
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    if (!isFetchManagerData) {
      _maplist = appState.maplist!;
      dropdownValue = _maplist.keys.length == 0 ? '' : _maplist.keys.first;
      isFetchManagerData = true;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '강사등록',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12.0),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 100.0,
                            // height: 50.0,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (_maplist.keys.length == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                '새로운 강사에게 할당 가능한 강의가 없습니다')));
                                    return;
                                  }
                                  if (qrcode == '') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                '등록할 강사의 QR 코드를 인증해 주세요')));
                                    return;
                                  }

                                  if (_formKey.currentState!.validate()) {
                                    late var check;
                                    await FirebaseFirestore.instance
                                        .collection('teachers')
                                        .where('teacheruid', isEqualTo: qrcode)
                                        .get()
                                        .then((value) {
                                      check = value.docs.length;
                                    });
                                    // print('null : ${nullcheck}');
                                    if (check > 0) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text('이미 등록된 강사입니다')));
                                      return;
                                    }
                                    late final sheetid;
                                    _maplist.forEach((key, value) {
                                      if (key == dropdownValue)
                                        sheetid = value[1];
                                    });
                                    try {
                                      await FirebaseFirestore.instance
                                          .runTransaction((transaction) async {
                                        DocumentReference managerRef =
                                            FirebaseFirestore.instance
                                                .collection('manager')
                                                .doc(FirebaseAuth
                                                    .instance.currentUser!.uid);

                                        DocumentReference teacherRef =
                                            managerRef
                                                .collection('teacher')
                                                .doc(qrcode);

                                        DocumentReference teachersRef =
                                            FirebaseFirestore.instance
                                                .collection('teachers')
                                                .doc(qrcode);

                                        // 트랜잭션 내에서 모든 Firestore 작업 수행
                                        transaction.update(managerRef, {
                                          dropdownValue: [true, sheetid],
                                        });
                                        transaction.set(teacherRef, {
                                          'teacheruid': qrcode,
                                          'name': _nameController.text.trim(),
                                          'birthday':
                                              _calenderController.text.trim(),
                                          'phonenumber': _phonenumberController
                                              .text
                                              .trim(),
                                          dropdownValue: sheetid,
                                        });

                                        transaction.set(teachersRef, {
                                          'teacheruid': qrcode,
                                          dropdownValue: sheetid,
                                        });
                                      });
                                      {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text('등록이 완료되었습니다.')),
                                        );
                                        Navigator.of(context).pop();
                                      }
                                    } catch (e) {
                                      // 트랜잭션이 실패하면 여기로 점프하게 됨
                                      print('Transaction failed: $e');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '예기치못한 오류로 등록이 실패했습니다. 다시 시도 해주세요.'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text('등록')),
                          ),
                          // SizedBox(
                          //   width: 20,
                          // ),
                          SizedBox(
                            width: 100.0,
                            // height: 50.0,
                            child: FilledButton(
                              child: const Text('초기화'),
                              onPressed: () {
                                _nameController.clear();
                                _phonenumberController.clear();
                                _calenderController.clear();
                                setState(() {
                                  isCheckOther = false;
                                  isCheckMyself = false;
                                  qrcode = '';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이름을 입력해주세요';
                          }
                          return null;
                        },
                        controller: _nameController,
                        decoration: const InputDecoration(
                          // filled: true,
                          labelText: '이름',
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '생년월일을 선택해주세요';
                                }
                                return null;
                              },
                              controller: _calenderController,
                              decoration: const InputDecoration(
                                // filled: true,
                                labelText: '생년월일',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Calender(
                            selectedcalender: select_canlender,
                          )
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '전화번호를 입력해주세요';
                          }
                          RegExp numberRegex = RegExp(r'^[0-9]+$');
                          if (!numberRegex.hasMatch(value!)) {
                            return '숫자만 입력해주세요';
                          }
                          return null;
                        },
                        controller: _phonenumberController,
                        decoration: const InputDecoration(
                          // filled: true,
                          labelText: '전화번호',
                        ),
                      ),

                      const SizedBox(height: 24.0),
                      _maplist.keys.length > 0
                          ? InputDecorator(
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.fromLTRB(
                                    12.0, 4.0, 12.0, 4.0),
                                labelText: '강의목록',
                                labelStyle: const TextStyle(fontSize: 18.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: dropdownValue,
                                  onChanged: (String? value) {
                                    setState(
                                      () {
                                        dropdownValue = value!;
                                      },
                                    );
                                  },
                                  items: _maplist.keys
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          : const Text('모든 강의가 할당됐거나 등록된 강의가 없습니다'),
                      const SizedBox(height: 12.0),
                      (isCheckMyself)
                          ? const SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                qrcode == ''
                                    ? const Expanded(
                                        child: Text('강사의 QR 코드를 인증해 주세요'))
                                    : const Expanded(child: Text('강사 인증되었습니다')),
                                const SizedBox(width: 12.0),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 3.2,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => QRScanner(
                                                  getQrcode: get_qrcode,
                                                )),
                                      );
                                    },
                                    child: const Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.qr_code_2),
                                          SizedBox(width: 4.0),
                                          Expanded(child: Text('인증')),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      (isCheckOther)
                          ? const SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                qrcode == ''
                                    ? const Expanded(
                                        child: Text(
                                            '본인을 강사로 등록하고 싶다면 이 버튼을 눌려주세요'))
                                    : const Expanded(child: Text('본인 인증되었습니다')),
                                const SizedBox(width: 12.0),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 3.2,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        qrcode = FirebaseAuth
                                            .instance.currentUser!.uid;
                                        isCheckMyself = true;
                                      });
                                    },
                                    child: const Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.person),
                                          SizedBox(width: 4.0),
                                          Expanded(child: Text('인증')),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
