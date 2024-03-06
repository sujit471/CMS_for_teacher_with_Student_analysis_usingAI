import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final CollectionReference studentsCollection =
  FirebaseFirestore.instance.collection('users');
  final CollectionReference attendanceCollection =
  FirebaseFirestore.instance.collection('student_attendance');
  List<Map<String, dynamic>> userData = [];
  Map<String, bool> attendance = {};

  void markAttendance(String studentId) {
    setState(() {
      if (attendance.containsKey(studentId)) {
        attendance[studentId] = !attendance[studentId]!;
      } else {
        attendance[studentId] = true; // or false, depending on your default state
      }
    });
  }

  Future<void> submitAttendance() async {
    try {
      Map<String, dynamic> attendanceData = {
        'attendance_date': DateTime.now().toString(),
      };

      QuerySnapshot usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();
      List<QueryDocumentSnapshot> users = usersSnapshot.docs;

      for (QueryDocumentSnapshot user in users) {
        String userId = user.id;
        attendanceData['attendance_status'] = attendance[userId] ?? false;

        DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

        await userDocRef.set(attendanceData, SetOptions(merge: true));
      }

      // Update attendance count based on roll number in "student_attendance" collection
      for (QueryDocumentSnapshot user in users) {
        String rollNumber = user['rollnumber'].toString();
        String userId = user.id;

        bool isPresent = attendance[userId] != null ? attendance[userId]! : false;

        // Use the unique roll number to store attendance in "student_attendance" collection
        DocumentReference attendanceDocRef =
        attendanceCollection.doc(rollNumber);

        await attendanceDocRef.set({
          'attendance_count': FieldValue.increment(isPresent ? 1 : 0),
        }, SetOptions(merge: true));
      }

      setState(() {
        attendance = {};
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance submitted successfully'),
        ),
      );
    } catch (e) {
      print('Error submitting attendance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error submitting attendance'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Attendance'),
        actions: [
          IconButton(
            onPressed: submitAttendance,
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: studentsCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<QueryDocumentSnapshot> students = snapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              String studentId = students[index].id;
              String studentName = students[index]['name'].toString();
              String rollNumber = students[index]['rollnumber'].toString();

              return ListTile(
                title: Text('$rollNumber: $studentName'),
                trailing: Checkbox(
                  value: attendance.containsKey(studentId)
                      ? attendance[studentId]
                      : false,
                  onChanged: (value) => markAttendance(studentId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
