import 'package:flutter/material.dart';
import 'dart:async';
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
  String _status = 'stopped', _steps = '?';
  String _toggleButtonText = 'Start';

  List<Widget> renderPedometerElements() {
    List<Widget> pedometerElements;
    if (_toggleButtonText == 'Stop') {
      pedometerElements = [
        Text(
          'Steps taken:',
          style: TextStyle(fontSize: 30),
        ),
        Text(
          _steps,
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

  void _togglePedometer() {
    setState(() {
      _toggleButtonText = _toggleButtonText == 'Start' ? 'Stop' : 'Start';
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    // print(event);
    print('STEP COUNT EVENT: ${event.steps.toString()}');
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    // print(event);
    print('STATUS CHANGED EVENT: ${event.status}');
    setState(() {
      _status = event.status;
      // print(_status);
      // print(_toggleButtonText);
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              onPressed: _togglePedometer,
              child: Text(_toggleButtonText),
            ),
            ...renderPedometerElements(),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
