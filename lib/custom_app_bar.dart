import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:lab3/pages/calendar_page.dart';
import 'package:lab3/pages/exam_page.dart';
import 'package:lab3/pages/map_page.dart';
import 'package:lab3/pages/new_exam_form.dart';
import 'package:lab3/services/firestore_service.dart';
import 'package:lab3/services/notifications_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final FirestoreService firestoreService = FirestoreService();
  final NotificationsService notificationsService = NotificationsService();
  final VoidCallback? onRefresh;

  CustomAppBar({super.key, this.onRefresh});

  void _showAddExamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Exam'),
          content: NewExamForm(
            firestoreService: firestoreService,
            notificationsService: notificationsService,
            onExamAdded: () {
              Navigator.of(context).pop();
              onRefresh
                  ?.call(); // Call the refresh function after adding an exam
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Exam Scheduler'),
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<ProfileScreen>(
                builder: (context) => ProfileScreen(
                  appBar: AppBar(
                    title: const Text('User Profile'),
                  ),
                  actions: [
                    SignedOutAction((context) {
                      Navigator.of(context).pop();
                    }),
                  ],
                  children: [
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.asset('assets/flutterfire_300x.png'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.assignment),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExamPage(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showAddExamDialog(context),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CalendarPage(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.map_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MapPage(),
              ),
            );
          },
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
