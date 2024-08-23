import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'alarm_screen.dart';
import 'timer.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clock App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ClockScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ClockScreen extends StatefulWidget {
  @override
  _ClockScreenState createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  String _dateString = '';
  DateTime _currentTime = DateTime.now();
  int _selectedYear = DateTime.now().year;
  int _selectedIndex = 0;
  List<String> _selectedCountries = ['New York', 'London', 'Tokyo']; // Default countries

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now();
      _dateString = _formatDate(_currentTime);
    });
  }

  String _formatDate(DateTime date) {
    final List<String> weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    String weekday = weekdays[date.weekday - 1];
    String month = months[date.month - 1];
    String day = date.day.toString();
    return '$weekday, $month $day';
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _currentTime)
      setState(() {
        _currentTime = picked;
        _dateString = _formatDate(_currentTime);
      });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AlarmScreen()),
        );
      } 
      if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StopwatchScreen()),
        );
      }
    });
  }

  void _addCountry() async {
    final List<String> availableCountries = ['New York', 'London', 'Tokyo', 'Paris', 'Sydney'];
    final List<String> newCountries = List.from(availableCountries);
    newCountries.removeWhere((country) => _selectedCountries.contains(country));

    String? selectedCountry = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a country'),
          content: SingleChildScrollView(
            child: ListBody(
              children: newCountries.map((country) {
                return ListTile(
                  title: Text(country),
                  onTap: () {
                    Navigator.of(context).pop(country);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selectedCountry != null) {
      setState(() {
        if (_selectedCountries.length >= 3) {
          _selectedCountries.removeAt(0); // Remove the oldest country if we have 3
        }
        _selectedCountries.add(selectedCountry);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.lightBlueAccent,
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Clock App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    children: [
                      DropdownButton<int>(
                        value: _selectedYear,
                        items: List.generate(101, (index) {
                          int year = DateTime.now().year - 50 + index;
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(
                              year.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }),
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedYear = newValue!;
                            _currentTime = DateTime(_selectedYear, _currentTime.month, _currentTime.day);
                            _dateString = _formatDate(_currentTime);
                          });
                        },
                        dropdownColor: Colors.lightBlueAccent,
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.calendar_today, color: Colors.white),
                        onPressed: () => _selectDate(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: CustomPaint(
                  size: Size(200, 200),
                  painter: ClockPainter(_currentTime),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16), // Padding around the date text
            alignment: Alignment.center,
            child: Text(
              _dateString,
              style: TextStyle(
                fontSize: 44,
                color: Colors.black, // Set the date text color to black
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: _selectedCountries.map((country) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.all(8),
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        country,
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        _getCountryTime(country),
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
            onPressed: _addCountry,
            child: Text('Add Country'),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Alarm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  String _getCountryTime(String country) {
    // This is a placeholder implementation. You would need to replace it with real time zones and logic.
    DateTime now = DateTime.now();
    Map<String, int> offsets = {
      'New York': -4, // UTC-4
      'London': 1, // UTC+1
      'Tokyo': 9, // UTC+9
      'Paris': 2, // UTC+2
      'Sydney': 10, // UTC+10
    };
    int offset = offsets[country] ?? 0;
    DateTime countryTime = now.add(Duration(hours: offset));
    return '${countryTime.hour.toString().padLeft(2, '0')}:${countryTime.minute.toString().padLeft(2, '0')}';
  }
}

class ClockPainter extends CustomPainter {
  final DateTime time;

  ClockPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = min(centerX, centerY);

    // Draw the black clock face
    final backgroundPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), radius, backgroundPaint);

    // Draw the clock border
    final borderPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(Offset(centerX, centerY), radius, borderPaint);

    final hourHandLength = radius * 0.5;
    final minuteHandLength = radius * 0.7;
    final secondHandLength = radius * 0.9;

    final hourHandPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8.0;

    final minuteHandPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0;

    final secondHandPaint = Paint()
      ..color = Colors.lightBlue
      ..strokeWidth = 4.0;

    final hourAngle = (time.hour % 12 + time.minute / 60) * 30 * pi / 180;
    final minuteAngle = (time.minute + time.second / 60) * 6 * pi / 180;
    final secondAngle = time.second * 6 * pi / 180;

    final hourHandX = centerX + hourHandLength * cos(hourAngle - pi / 2);
    final hourHandY = centerY + hourHandLength * sin(hourAngle - pi / 2);
    canvas.drawLine(Offset(centerX, centerY), Offset(hourHandX, hourHandY), hourHandPaint);

    final minuteHandX = centerX + minuteHandLength * cos(minuteAngle - pi / 2);
    final minuteHandY = centerY + minuteHandLength * sin(minuteAngle - pi / 2);
    canvas.drawLine(Offset(centerX, centerY), Offset(minuteHandX, minuteHandY), minuteHandPaint);

    final secondHandX = centerX + secondHandLength * cos(secondAngle - pi / 2);
    final secondHandY = centerY + secondHandLength * sin(secondAngle - pi / 2);
    canvas.drawLine(Offset(centerX, centerY), Offset(secondHandX, secondHandY), secondHandPaint);

    final centerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), 8.0, centerDotPaint);

    _drawNumbers(canvas, centerX, centerY, radius);
  }

  void _drawNumbers(Canvas canvas, double centerX, double centerY, double radius) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 1; i <= 12; i++) {
      final angle = i * 30 * pi / 180;
      final numberX = centerX + radius * 0.8 * cos(angle - pi / 2);
      final numberY = centerY + radius * 0.8 * sin(angle - pi / 2);

      textPainter.text = TextSpan(
        text: i.toString(),
        style: TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(numberX - textPainter.width / 2, numberY - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
