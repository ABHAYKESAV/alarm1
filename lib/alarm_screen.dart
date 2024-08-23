import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmScreen extends StatefulWidget {
  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  List<Map<String, dynamic>> _alarms = [];
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  void _loadAlarms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedAlarms = prefs.getStringList('alarms');
    if (savedAlarms != null) {
      setState(() {
        _alarms = savedAlarms
            .map((alarm) => {
          'time': alarm.split('|')[0],
          'enabled': alarm.split('|')[1] == 'true'
        })
            .toList();
      });
    }
  }

  void _saveAlarms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedAlarms = _alarms
        .map((alarm) => '${alarm['time']}|${alarm['enabled']}')
        .toList();
    prefs.setStringList('alarms', savedAlarms);
  }

  void _addAlarm() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    ).then((date) {
      if (date != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((time) {
          if (time != null) {
            setState(() {
              _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
              String formattedDate = _formatDateTime(_selectedDateTime!);
              _alarms.add({'time': formattedDate, 'enabled': true});
              _saveAlarms();
            });
          }
        });
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final List<String> weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    String weekday = weekdays[dateTime.weekday - 1];
    String month = months[dateTime.month - 1];
    String day = dateTime.day.toString();
    String hour = dateTime.hour > 12 ? (dateTime.hour - 12).toString() : dateTime.hour.toString();
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$weekday, $month $day, $hour:$minute $period';
  }

  void _toggleAlarm(int index) {
    setState(() {
      _alarms[index]['enabled'] = !_alarms[index]['enabled'];
      _saveAlarms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Alarm'),
      ),
      body: ListView.builder(
        itemCount: _alarms.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(_alarms[index]['time']),
              trailing: Switch(
                value: _alarms[index]['enabled'],
                onChanged: (bool value) {
                  _toggleAlarm(index);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: Icon(Icons.add),
      ),
    );
  }
}
