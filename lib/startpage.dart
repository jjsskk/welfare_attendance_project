
import 'package:flutter/material.dart';
import 'package:welfare_attendance_project/institution/institution.dart';
import 'package:welfare_attendance_project/teacher/teacher.dart';
import 'institution/loginpage.dart' as ins;
import 'teacher/loginpage.dart' as tea;
import 'provider/app_state.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fluttertoast/fluttertoast.dart';


class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late VideoPlayerController _videoPlayerController;

  DateTime? currentBackPressTime;
  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.asset("assets/background.mp4")
          ..initialize().then((_) {
            _videoPlayerController.play();
            _videoPlayerController.setLooping(true);
            setState(() {});
          });
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

    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<ApplicationState>();

    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    _videoPlayerController.setVolume(0.0);

    // return Scaffold(
    //   body: Row(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Row(
    //             children: [
    //               ElevatedButton(
    //                   onPressed: () {
    //                     appState.whatuser = false;
    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(builder: (context) => TeacherApp()),
    //                     );
    //                   },
    //                   child: Text('강사용 로그인')),
    //               ElevatedButton(
    //                   onPressed: () {
    //                     appState.whatuser = true;
    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(builder: (context) => InstitutionApp()),
    //                     );
    //                   },
    //                   child: Text('복지사용 로그인'))
    //             ],
    //           )
    //         ],
    //       ),
    //     ],
    //   ),
    // );

    return WillPopScope(
      onWillPop: onWillPop,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              // 배경 영상
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoPlayerController.value.size.width,
                    height: _videoPlayerController.value.size.height,
                    child: VideoPlayer(_videoPlayerController),
                  ),
                ),
              ),

              // 위젯 섹션
              isPortrait ? const StartPagePortrait() : const StartPageLandscape(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }
}

// 위젯 섹션 (세로 화면)
class StartPagePortrait extends StatelessWidget {
  const StartPagePortrait({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 84.0),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 200.0,
                  height: 200.0,
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        '노인복지시설에\n오신 것을\n환영합니다',
                        textStyle: Theme.of(context).textTheme.titleLarge,
                        speed: const Duration(milliseconds: 250),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 100.0,
              height: 50.0,
              child: ElevatedButton(
                child: const Text('강사'),
                onPressed: () {
                  appState.whatuser = false;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TeacherApp()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: 100.0,
              height: 50.0,
              child: ElevatedButton(
                child: const Text('복지사'),
                onPressed: () {
                  appState.whatuser = true;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InstitutionApp()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 84.0),
      ],
    );
  }
}

// 위젯 섹션 (가로 화면)
class StartPageLandscape extends StatelessWidget {
  const StartPageLandscape({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(width: 84.0),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 24.0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 200.0,
                  height: 200.0,
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        '노인복지시설에\n오신 것을\n환영합니다',
                        textStyle: Theme.of(context).textTheme.titleLarge,
                        speed: const Duration(milliseconds: 250),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 100.0,
              height: 50.0,
              child: ElevatedButton(
                child: const Text('강사'),
                onPressed: () {
                  appState.whatuser = false;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TeacherApp()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: 100.0,
              height: 50.0,
              child: ElevatedButton(
                child: const Text('복지사'),
                onPressed: () {
                  appState.whatuser = true;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InstitutionApp()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(width: 84.0),
      ],
    );
  }
}
