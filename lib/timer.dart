import 'package:flutter/material.dart';
import 'dart:async';

class StopwatchScreen extends StatefulWidget {
  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  Timer? _timer;
  int _elapsedMilliseconds = 0;
  bool _isRunning = false;
  List<String> _lapTimes = [];

  void _startStopwatch() {
    if (_timer != null) {
      _timer!.cancel();
    }

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(Duration(milliseconds: 1), (Timer timer) {
      setState(() {
        _elapsedMilliseconds++;
      });
    });
  }

  void _stopStopwatch() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _isRunning = false;
    });
  }

  void _resetStopwatch() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _elapsedMilliseconds = 0;
      _isRunning = false;
      _lapTimes.clear();
    });
  }

  void _recordLapTime() {
    setState(() {
      _lapTimes.add(_formatTime(_elapsedMilliseconds));
    });
  }

  String _formatTime(int milliseconds) {
    final hours = (milliseconds / (1000 * 60 * 60)).floor();
    final minutes = ((milliseconds / (1000 * 60)) % 60).floor();
    final seconds = ((milliseconds / 1000) % 60).floor();
    final millis = milliseconds % 1000;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${millis.toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stopwatch'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_elapsedMilliseconds),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _startStopwatch,
                  child: Text('Start'),
                ),
                ElevatedButton(
                  onPressed: _isRunning ? _stopStopwatch : null,
                  child: Text('Stop'),
                ),
                ElevatedButton(
                  onPressed: _resetStopwatch,
                  child: Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: _isRunning ? _recordLapTime : null,
                  child: Text('Lap'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _lapTimes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Lap ${index + 1}: ${_lapTimes[index]}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
