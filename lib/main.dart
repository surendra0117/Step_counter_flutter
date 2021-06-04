import 'package:flutter/material.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S4S',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'S4S'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Stream<StepCount> _stepCountStream;
  Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = 'stopped';
  String _toggleButtonText = 'Start';
  int _stepCnt = 0;
  String permissionStatus = 'PERMISSION DENIED';

  List<Widget> renderPedometerElements() {
    List<Widget> pedometerElements;
    if (_toggleButtonText == 'Stop') {
      pedometerElements = [
        Text(
          'Steps taken:',
          style: TextStyle(fontSize: 30),
        ),
        Text(
          _stepCnt.toString(),
          style: TextStyle(fontSize: 60),
        ),
        Divider(
          height: 100,
          thickness: 0,
          color: Colors.white,
        ),
        Text(
          'Pedestrian status:',
          style: TextStyle(fontSize: 30),
        ),
        Icon(
          _status == 'walking'
              ? Icons.directions_walk
              : _status == 'stopped'
                  ? Icons.accessibility_new
                  : Icons.error,
          size: 100,
        ),
        Center(
          child: Text(
            _status,
            style: _status == 'walking' || _status == 'stopped'
                ? TextStyle(fontSize: 30)
                : TextStyle(fontSize: 20, color: Colors.red),
          ),
        ),
      ];
    } else {
      pedometerElements = [];
    }
    return pedometerElements;
  }

  void _togglePedometer() async {
    setState(() {
      if (_toggleButtonText == 'Start') {
        _toggleButtonText = 'Stop';
        _stepCnt = 0;
      } else {
        _toggleButtonText = 'Start';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getPermissions();
    initPlatformState();
  }

  void getPermissions() async {
    print('CHECKING FOR PERMISSIONS...');
    if (await Permission.speech.isPermanentlyDenied) {
      openAppSettings();
    }
    var status = await Permission.activityRecognition.status;
    if (status.isDenied) {
      setState(() {
        permissionStatus = 'PERMISSION DENIED';
      });
    }

    if (await Permission.activityRecognition.request().isGranted) {
      setState(() {
        permissionStatus = 'GRANTED';
      });
    }

    // // You can can also directly ask the permission about its status.
    // if (await Permission.activityRecognition.isRestricted) {
    //   print('PERMISSION RESTRICTED!!!');
    // }
  }

  void onStepCount(StepCount event) async {
    // print(event);
    print('STEP COUNT EVENT: ${event.steps.toString()}');
    setState(() {
      _stepCnt += 1;
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) async {
    // print(event);
    print('STATUS CHANGED EVENT: ${event.status}');
    setState(() {
      _status = event.status;
      // print(_status);
      // print(_toggleButtonText);
    });
  }

  void onPedestrianStatusError(error) async {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) async {
    print('onStepCountError: $error');
    setState(() {
      _stepCnt = -1;
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  List<Widget> renderScreen() {
    List<Widget> columnChildrens = [];
    if (permissionStatus == 'GRANTED') {
      columnChildrens = <Widget>[
        FloatingActionButton(
          onPressed: _togglePedometer,
          child: Text(_toggleButtonText),
        ),
        ...renderPedometerElements(),
      ];
    } else {
      columnChildrens = <Widget>[
        Center(
          child: Text(
            'SENSOR PERMISSION DENIED',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      ];
    }
    return columnChildrens;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: renderScreen(),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
