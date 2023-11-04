import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class RegisterClassGuide extends StatelessWidget {
  const RegisterClassGuide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '강의등록 가이드',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: const Center(
        child: GuideSection(),
      ),
    );
  }
}

class GuideSection extends StatefulWidget {
  const GuideSection({Key? key}) : super(key: key);

  @override
  State<GuideSection> createState() => _GuideSectionState();
}

class _GuideSectionState extends State<GuideSection> {
  int _index = 0;


  @override
  Widget build(BuildContext context) {
    return Stepper(
      controlsBuilder: (BuildContext context, ControlsDetails controls) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              onPressed: controls.onStepCancel,
              child: const Text('이전'),
            ),
            TextButton(
              onPressed: controls.onStepContinue,
              child: const Text('다음'),
            ),
          ],
        );
      },
      currentStep: _index,
      onStepCancel: () {
        if (_index > 0) {
          setState(() {
            _index -= 1;
          });
        }
      },
      onStepContinue: () {
        if (_index <= 1) {
          setState(() {
            _index += 1;
          });
        }
      },
      onStepTapped: (int index) {
        setState(() {
          _index = index;
        });
      },
      steps: <Step>[
        Step(
          title: const Text('강의 엑셀 파일 생성하기'),
          content: Container(
            alignment: Alignment.centerLeft,
            child: ListView(
              shrinkWrap: true,
              children: [
                Image.asset(
                  'assets/guide1.png',
                  width: double.infinity,
                ),
                const SizedBox(height: 12.0),
                Text(
                  '1. 드라이브에서 출석을 관리하고자 하는 강의의 엑셀 파일을 생성해 주세요( 파일 내용은 메일로 받은 sample 엑셀 파일 양식을 꼭 따라주세요!)\n(※ [새로 만들기] - [Google 스프레드시트] 클릭)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        Step(
          title: const Text('이메일 주소 편집자로 공유하기'),
          content: ListView(
            shrinkWrap: true,
            children: [
              Image.asset(
                'assets/guide2.png',
                width: double.infinity,
              ),
              const SizedBox(height: 12.0),
              Text(
                '2. 생성한 엑셀 파일에서 메일로 받은 편집자 이메일을 공유해 주세요\n(※ [공유] 클릭 - [사용자 및 그룹 추가] 칸에 편집자 이메일 주소 입력 - [전송] 클릭)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12.0),
            ],
          ),
        ),
        Step(
          title: const Text('강의 등록하기'),
          content: ListView(
            shrinkWrap: true,
            children: [
              Image.asset(
                'assets/guide3.png',
                width: double.infinity,
              ),
              const SizedBox(height: 12.0),
              Text(
                '3. 엑셀 파일의 이름을 아래의 [강의 이름] 칸에 입력하신 후 [등록] 버튼을 눌러주세요\n(※ 엑셀 파일의 이름은 강의 이름과 동일해야 합니다)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
