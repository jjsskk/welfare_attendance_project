import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:welfare_attendance_project/startpage.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'color_schemes.g.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: (context, child) {
        return const MyApp();
      }));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        fontFamily: GoogleFonts.nanumGothic().fontFamily,
        textTheme: TextTheme(
          titleLarge: const TextStyle(
            color: Colors.white,
            fontSize: 30.0,
          ),
          titleMedium: TextStyle(
            fontFamily: GoogleFonts.eastSeaDokdo().fontFamily,
            fontSize: 36.0,
          ),
        ),
      ),
      home: const StartPage(),
    );
  }
}
