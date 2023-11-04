import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:welfare_attendance_project/profilepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:welfare_attendance_project/teacher/classdate.dart';
import '../provider/app_state.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TutorialCoachMark tutorialCoachMark;
  GlobalKey keyButton1 = GlobalKey();

  @override
  void initState() {
    createTutorial();
    Future.delayed(Duration.zero, showTutorial);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    appState.attendancedata = null;
  }

  late var appState;
  late var sheetid;
  late var classname;
  DateTime? currentBackPressTime;

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

  final Stream<DocumentSnapshot<Map<String, dynamic>>> _classstream =
      FirebaseFirestore.instance
          .collection('teachers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();

  @override
  Widget build(BuildContext context) {
    appState = context.watch<ApplicationState>();
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '강의목록',
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
        body: Column(
          children: [
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _classstream,
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.data!.exists) {
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
                          const Text('등록된 강의가 없습니다'),
                        ],
                      ),
                    ),
                  );
                }

                Map<String, dynamic> data =
                    snapshot.data!.data()! as Map<String, dynamic>;

                data.remove('teacheruid');
                data.forEach((key, value) {
                  sheetid = value;
                  classname = key;
                });
                var classlist = data.keys.toList();
                return Expanded(
                  child: GridView.count(
                    crossAxisCount: 1,
                    padding: const EdgeInsets.all(16.0),
                    childAspectRatio: 5.0 / 2.0,
                    children: classlist
                        .map((element) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ClassDate(
                                          classname: classname,
                                          sheetid: sheetid,
                                        )),
                              );
                            },
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  AspectRatio(
                                    aspectRatio: 1 / 1,
                                    child: Lottie.network(
                                      'https://assets3.lottiefiles.com/packages/lf20_yjrdpceb.json',
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
                                          padding: const EdgeInsets.fromLTRB(
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
                      "강사님의 프로필을 확인할 수 있습니다.",
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

// List<Widget> cardtolist(ThemeData theme) {
//   late Card card;
//   List<Widget> list = [];
//   List<bool> _selectedIcon = [];
//   for (var data in sheet.data) {
//     if (data[0] != '이름') {
//       if (data[2] == 'o')
//         _selectedIcon = [true, false];
//       else
//         _selectedIcon = [false, true];
//       list.add(Card(
//         child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${data[0]}',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4.0),
//                     Text('${data[1]}'),
//                   ],
//                 ),
//                 // SizedBox(width: 20,),
//                 ToggleButtons(
//                   direction: Axis.horizontal,
//                   onPressed: (int index) {
//                     setState(() {
//                       // The button that is tapped is set to true, and the others to false.
//                       for (int i = 0; i < _selectedIcon.length; i++) {
//                         // if(data[2] == 'o')
//                         //  index = index!;
//                         _selectedIcon[i] = i == index;
//                       }
//                       _grid_or_list = index;
//                     });
//                   },
//                   borderRadius: const BorderRadius.all(Radius.circular(8)),
//                   selectedBorderColor: theme.colorScheme.primary,
//                   selectedColor: theme.colorScheme.primary,
//                   fillColor: Colors.blue[200],
//                   color: Colors.grey,
//                   isSelected: _selectedIcon,
//                   children: icons,
//                 ),
//                 // Text('${data[2]}')
//               ],
//             )),
//       ));
//     }
//   }
//   return list;
// }
}
