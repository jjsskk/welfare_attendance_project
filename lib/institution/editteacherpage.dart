import 'package:flutter/material.dart';
import 'package:welfare_attendance_project/provider/app_state.dart';
import 'calender.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditTeacherPage extends StatefulWidget {
  EditTeacherPage(
      {Key? key,
      required this.name,
      required this.classname,
      required this.birthday,
      required this.phonenum,
      required this.sheetid,
      required this.teacheruid})
      : super(key: key);

  final name;
  final classname;
  final birthday;
  final phonenum;
  final sheetid;
  final teacheruid;

  @override
  State<EditTeacherPage> createState() => _EditTeacherPageState();
}

class _EditTeacherPageState extends State<EditTeacherPage> {
  Map<String, dynamic> _maplist = Map();

  final _formKey = GlobalKey<FormState>();

  var _nameController = null;

  var _calenderController = null;

  var _phonenumberController = null;

  void setTextController() {
    if (_nameController == null)
      _nameController = TextEditingController(text: widget.name);
    if (_calenderController == null)
      _calenderController = TextEditingController(text: widget.birthday);
    if (_phonenumberController == null)
      _phonenumberController = TextEditingController(text: widget.phonenum);
  }

  String dropdownValue = '';
  bool isFetchManagerData = false;

  void select_canlender(String calendar) {
    setState(() {
      this._calenderController = TextEditingController(text: calendar);
    });
  }

  @override
  Widget build(BuildContext context) {
    setTextController();
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
          '강사수정',
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
                                            content:
                                                Text('강사에게 할당 가능한 강의가 없습니다')));
                                    return;
                                  }
                                  if (_formKey.currentState!.validate()) {
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
                                                .doc(widget.teacheruid);

                                        DocumentReference teachersRef =
                                            FirebaseFirestore.instance
                                                .collection('teachers')
                                                .doc(widget.teacheruid);

                                        // 트랜잭션 내에서 모든 Firestore 작업 수행
                                        transaction.update(managerRef, {
                                          widget.classname: [
                                            false,
                                            widget.sheetid
                                          ],
                                          dropdownValue: [true, sheetid],
                                        });

                                        transaction.set(teacherRef, {
                                          'teacheruid': widget.teacheruid,
                                          'name': _nameController.text.trim(),
                                          'birthday':
                                              _calenderController.text.trim(),
                                          'phonenumber': _phonenumberController
                                              .text
                                              .trim(),
                                          dropdownValue: sheetid,
                                        });

                                        transaction.set(teachersRef, {
                                          'teacheruid': widget.teacheruid,
                                          dropdownValue: sheetid,
                                        });
                                      });
                                      {
                                        // 트랜잭션이 성공적으로 완료됨
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text('수정이 완료되었습니다.')),
                                        );

                                        // 이후에 필요한 작업 수행 (예: Navigator.pop)
                                        Navigator.of(context).pop();
                                      }
                                    } catch (e) {
                                      // 트랜잭션이 실패하면 여기로 점프하게 됨
                                      print('Transaction failed: $e');

                                      // 실패한 경우에 대한 작업 수행 (예: 에러 메시지 출력 등)
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '수정중 오류가 발생했습니다. 다시 시도 해주세요.'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text('수정')),
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
                      const SizedBox(height: 12.0),
                      Text('기존 강의: ' + widget.classname),
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
