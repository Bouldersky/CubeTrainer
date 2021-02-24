import 'package:cubetrainer/model/inMemorySolveHistoryImpl.dart';
import 'package:cubetrainer/model/scrambler.dart';
import 'package:cubetrainer/model/settings.dart';
import 'package:cubetrainer/model/solveHistory.dart';
import 'package:cubetrainer/model/timerState.dart';
import 'package:cubetrainer/screens/timerScreen.dart';
import 'package:cubetrainer/widgets/authWidget.dart';
import 'package:cubetrainer/widgets/settingsWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _signInVisible = false;
  Widget buildScreen(BuildContext context, AsyncSnapshot authStateSnapshot) {
    print("auth state snapshot: ${authStateSnapshot.data}");
    if (authStateSnapshot.data == null && _signInVisible == false) {
      print("showing alert dialog");
      _signInVisible = true;
      SchedulerBinding.instance.addPostFrameCallback((_) => showDialog(
            context: context,
            builder: (_) => AuthWidget(),
            barrierDismissible: false,
          ).whenComplete(() => _signInVisible = false));
    } else if (authStateSnapshot.data != null && _signInVisible) {
      _signInVisible = false;
      Navigator.maybePop(context);
    }

    return TimerScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: buildScreen),
        drawer: Drawer(
          child: SettingsWidget(),
        ),
      ),
      providers: [
        ChangeNotifierProvider(create: (context) => SolveState()),
        ChangeNotifierProvider(create: (context) => Scrambler()),
        Provider(create: (_) => Settings()),
        ChangeNotifierProvider<SolveHistoryInterface>(
            create: (_) => InMemorySolveHistoryImpl()),
      ],
    );
  }
}