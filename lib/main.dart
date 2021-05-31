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
  String _status = '?', _steps = '?';
  String _toggleButtonText = 'Start';
  List<Widget> _pedometerElements = [];

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _togglePedometer() {
    setState(() {
      _toggleButtonText = _toggleButtonText == 'Start' ? 'Stop' : 'Start';

      // print("_pedometerElements: $_pedometerElements");

      if (_toggleButtonText == 'Stop') {
        _pedometerElements = [
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
        _pedometerElements = [];
      }
    });
  }

  void initializePedometerElements() {
    _pedometerElements = [];
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initializePedometerElements();
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
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
            ...?_pedometerElements,
            // Text(
            //   'Steps taken:',
            //   style: TextStyle(fontSize: 30),
            // ),
            // Text(
            //   _steps,
            //   style: TextStyle(fontSize: 60),
            // ),
            // Divider(
            //   height: 100,
            //   thickness: 0,
            //   color: Colors.white,
            // ),
            // Text(
            //   'Pedestrian status:',
            //   style: TextStyle(fontSize: 30),
            // ),
            // Icon(
            //   _status == 'walking'
            //       ? Icons.directions_walk
            //       : _status == 'stopped'
            //           ? Icons.accessibility_new
            //           : Icons.error,
            //   size: 100,
            // ),
            // Center(
            //   child: Text(
            //     _status,
            //     style: _status == 'walking' || _status == 'stopped'
            //         ? TextStyle(fontSize: 30)
            //         : TextStyle(fontSize: 20, color: Colors.red),
            //   ),
            // ),
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
