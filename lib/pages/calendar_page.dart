import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../custom_app_bar.dart';
import '../services/firestore_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late List<Map<String, dynamic>> _exams;

  @override
  void initState() {
    super.initState();
    _exams = [];
    _loadExams();
  }

  Future<void> _loadExams() async {
    try {
      List<Map<String, dynamic>> exams = await _firestoreService.getExams();
      setState(() {
        _exams = exams;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error loading exams: $error');
      }
    }
  }

  Future<void> _refreshExams() async {
    await _loadExams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          onRefresh: _refreshExams,
        ),
        body: SfCalendar(
          view: CalendarView.month,
          dataSource: MeetingDataSource(_getDataSource(_exams)),
          monthViewSettings: const MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
          firstDayOfWeek: 1,
          showDatePickerButton: true,
        ));
  }
}

List<Map<String, dynamic>> _getDataSource(List<Map<String, dynamic>> exams) {
  final List<Map<String, dynamic>> scheduledExams = exams;
  return scheduledExams;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Map<String, dynamic>> source) {
    appointments = source;
  }

  @override
  String getSubject(int index) {
    return appointments![index]['title'];
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index]['date'].toDate();
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index]['date'].toDate();
  }
}
