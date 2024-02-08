import 'package:flutter/material.dart';
import 'package:lab3/services/firestore_service.dart';
import 'package:lab3/services/notifications_service.dart';

import '../model/location.dart';

class NewExamForm extends StatefulWidget {
  final FirestoreService firestoreService;
  final NotificationsService notificationsService;
  final void Function()? onExamAdded;

  const NewExamForm(
      {super.key,
      required this.firestoreService,
      this.onExamAdded,
      required this.notificationsService});

  @override
  _NewExamFormState createState() => _NewExamFormState();
}

class _NewExamFormState extends State<NewExamForm> {
  late TextEditingController _titleController;
  late DateTime _selectedDateTime;
  late Location _location;
  String defaultValue = 'FINKI';
  String _message = '';
  Color _messageColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _selectedDateTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _message.isNotEmpty
            ? Container(
                padding: const EdgeInsets.all(8.0),
                color: _messageColor,
                child: Text(
                  _message,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : Container(),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Exam Title'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButton(
            value: defaultValue,
            items: <String>['FINKI', 'TMF', 'FEIT']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
            onChanged: (String? novo) {
              setState(() {
                defaultValue = novo!;
              });
            }),
        const SizedBox(height: 16),
        Text(
            'Selected Date: ${_selectedDateTime.day}.${_selectedDateTime.month}.${_selectedDateTime.year} at ${_selectedDateTime.hour}:${_selectedDateTime.minute}'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _selectDateTime(context),
          child: const Text('Select Exam Date'),
        ),
        ElevatedButton(
          onPressed: () => _addExam(),
          child: const Text('Add Exam'),
        ),
      ],
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _addExam() {
    if (_titleController.text.isNotEmpty) {
      if (defaultValue == 'FINKI') {
        _location = Location(latitude: 42.0043165, longitude: 21.4096452);
      } else if (defaultValue == 'FEIT') {
        _location = Location(latitude: 42.004400, longitude: 21.408918);
      } else {
        _location = Location(latitude: 42.004906, longitude: 21.409890);
      }
      widget.firestoreService
          .addExam(_titleController.text, _selectedDateTime, _location);
      widget.onExamAdded?.call();
      widget.notificationsService
          .scheduleExamNotification(_selectedDateTime, _titleController.text);
      _titleController.clear();
      _selectedDateTime = DateTime.now();
    } else {
      _setMessage('Please enter a title', Colors.red, false);
    }
  }

  void _setMessage(String message, Color color, bool clear) {
    setState(() {
      _message = message;
      _messageColor = color;
    });

    if (clear) {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _message = '';
          _messageColor = Colors.green;
        });
      });
    }
  }
}
