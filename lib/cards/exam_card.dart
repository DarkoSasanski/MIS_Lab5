import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExamCard extends StatelessWidget {
  final Map<String, dynamic> exam;

  const ExamCard({super.key, required this.exam});

  String formatDate(Timestamp date) {
    DateTime dateTime = date.toDate();
    return '${dateTime.day}.${dateTime.month}.${dateTime.year} at ${dateTime.hour}:${dateTime.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${exam['title']}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Exam Date: ${formatDate(exam['date'])}',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
