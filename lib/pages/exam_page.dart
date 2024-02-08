import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../cards/exam_card.dart';
import '../custom_app_bar.dart';
import '../services/firestore_service.dart';

class ExamPage extends StatefulWidget {
  const ExamPage({Key? key}) : super(key: key);

  @override
  _ExamPageState createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
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
      print(_exams);
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
      appBar: CustomAppBar(
        onRefresh: _refreshExams,
      ),
      body: _buildExamsGrid(),
    );
  }

  Widget _buildExamsGrid() {
    if (_exams.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _exams.length,
        itemBuilder: (context, index) {
          return ExamCard(exam: _exams[index]);
        },
      );
    }
  }
}
