import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:welfare_attendance_project/provider/app_state.dart';
import 'package:welfare_attendance_project/institution/registerclasspage.dart';
import 'package:welfare_attendance_project/institution/registerteacherpage.dart';

import 'package:provider/provider.dart';
import '../profilepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detailpage.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TutorialCoachMark tutorialCoachMark;
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();
  GlobalKey keyButton3 = GlobalKey();

  DateTime? currentBackPressTime;

  @override
  void initState() {
    createTutorial();
    Future.delayed(Duration.zero, showTutorial);
    super.initState();
  }

  bool loading = true;
  late var appState;
  final Stream<QuerySnapshot> _teacherstream = FirebaseFirestore.instance
      .collection('manager')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('teacher')
      .snapshots();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      classlist_listener = null;

  store_userinfo() async {
    try {
      late var check;
      await FirebaseFirestore.instance
          .collection('manager')
          .where('복지사', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        check = value.docs.length;
      });
      // print('null : ${check}');
      if (check == 0) {
        await FirebaseFirestore.instance
            .collection('manager')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set(<String, dynamic>{
          '복지사': FirebaseAuth.instance.currentUser!.uid
        });
        {
          classlist_listener = appState.classlist_listener();
          setState(() {
            loading = false;
          });
          // return;
        }
      } else {
        classlist_listener = appState.classlist_listener();
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      final msg = "'뒤로가기'버튼을 한 번 더 누르면 종료됩니다.";

      Fluttertoast.showToast(
          msg: msg, backgroundColor: Colors.black, textColor: Colors.white);
      return Future.value(false);
    }

    SystemNavigator.pop();
    return Future.value(false);
  }

  @override
  void dispose() {
    if (classlist_listener != null) classlist_listener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<ApplicationState>();
    if (classlist_listener == null) {
      store_userinfo();
      // classlist_listener = appState.classlist_listener();
    }
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '강사목록',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: IconButton(
            key: keyButton1,
            icon: const Icon(
              Icons.person,
              semanticLabel: 'profile',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.info_outline,
                semanticLabel: 'guide',
              ),
              onPressed: () {
                showTutorial();
              },
            )
          ],
        ),
        body: loading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24.0),
                      ElevatedButton(
                          key: keyButton2,
                          onPressed: () async {
                            // late var check;
                            // await FirebaseFirestore.instance
                            //     .collection('manager')
                            //     .where('복지사',
                            //         isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                            //     .get()
                            //     .then((value) {
                            //   check = value.docs.length;
                            // });
                            // // print('null : ${nullcheck}');
                            // if (check == 0)
                            //   await FirebaseFirestore.instance
                            //       .collection('manager')
                            //       .doc(FirebaseAuth.instance.currentUser!.uid)
                            //       .set(<String, dynamic>{
                            //     '복지사': FirebaseAuth.instance.currentUser!.uid
                            //   });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterClassPage()),
                            );
                          },
                          child: const Text('강의등록')),
                      const SizedBox(width: 24.0),
                      ElevatedButton(
                          key: keyButton3,
                          onPressed: () async {
                            // late var check;
                            // await FirebaseFirestore.instance
                            //     .collection('manager')
                            //     .where('복지사',
                            //         isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                            //     .get()
                            //     .then((value) {
                            //   check = value.docs.length;
                            // });
                            // // print('null : ${nullcheck}');
                            // if (check == 0)
                            //   await FirebaseFirestore.instance
                            //       .collection('manager')
                            //       .doc(FirebaseAuth.instance.currentUser!.uid)
                            //       .set(<String, dynamic>{
                            //     '복지사': FirebaseAuth.instance.currentUser!.uid
                            //   });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterTeacherPage()),
                            );
                          },
                          child: const Text('강사등록')),
                      const SizedBox(width: 24.0),
                    ],
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _teacherstream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.data!.size == 0) {
                        return Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.network(
                                  'https://assets8.lottiefiles.com/packages/lf20_dmw3t0vg.json',
                                  width: 240.0,
                                ),
                                const SizedBox(height: 12.0),
                                const Text('등록된 강사가 없습니다'),
                              ],
                            ),
                          ),
                        );
                      }
                      // print('here');
                      return Expanded(
                        child: GridView.count(
                          crossAxisCount: 1,
                          padding: const EdgeInsets.all(16.0),
                          childAspectRatio: 5.0 / 2.0,
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                                Map<String, dynamic> data =
                                    document.data()! as Map<String, dynamic>;
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 0),
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        AspectRatio(
                                          aspectRatio: 1 / 1,
                                          child: Lottie.network(
                                            'https://assets2.lottiefiles.com/packages/lf20_h9rxcjpi.json',
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
                                              Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          8.0, 12.0, 8.0, 0.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        data['name'],
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge,
                                                        maxLines: 1,
                                                      ),
                                                      Text(
                                                        data['phonenumber']
                                                            .replaceAllMapped(
                                                                RegExp(
                                                                    r'(\d{3})(\d{3,4})(\d{4})'),
                                                                (m) =>
                                                                    '${m[1]}-${m[2]}-${m[3]}'),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium,
                                                      ),
                                                      Text(
                                                        data['birthday'],
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    TextButton(
                                                      child: const Text('상세보기'),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      DetailPage(
                                                                        teacheruid:
                                                                            data['teacheruid'],
                                                                      )),
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(width: 8),
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
                              })
                              .toList()
                              .cast(),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.red,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        print("finish");
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        print("skip");
      },
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "keyButton1",
        keyTarget: keyButton1,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  const SizedBox(height: 12.0),
                  Text(
                    "프로필",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "복지사님의 프로필을 확인할 수 있습니다.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "keyButton2",
        keyTarget: keyButton2,
        color: Colors.green,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  const SizedBox(height: 48.0),
                  Text(
                    "강의등록",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "복지시설에서 운영 중인 강의를 등록할 수 있습니다. 강사님을 등록하기 위해서는 반드시 먼저 강의를 등록해야 합니다.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "keyButton3",
        keyTarget: keyButton3,
        color: Colors.blue,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  const SizedBox(height: 48.0),
                  Text(
                    "강사등록",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "복지시설에서 강의 중인 강사님을 등록할 수 있습니다. 강사님을 등록하기 위해서는 반드시 먼저 강의를 등록해야 합니다.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }
}
