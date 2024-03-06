import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceScreenss extends StatefulWidget {
  final User user;

  AttendanceScreenss({Key? key, required this.user}) : super(key: key);

  @override
  _AttendanceScreenssState createState() => _AttendanceScreenssState();
}

class _AttendanceScreenssState extends State<AttendanceScreenss> {
  late Stream<DocumentSnapshot> attendanceDataStream;

  @override
  void initState() {
    super.initState();
    attendanceDataStream = getAttendanceDataStream(widget.user.uid);
  }

  Stream<DocumentSnapshot> getAttendanceDataStream(String uid) {
    return FirebaseFirestore.instance.collection('teacher_attendance').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Data'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: attendanceDataStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Attendance data not found.'));
          } else {
            final data = snapshot.data!.data() as Map<String, dynamic>?;

            if (data == null || !data.containsKey('02')) {
              return Center(child: Text('Attendance data not found.'));
            }

            final februaryData = data['02'] as Map<String, dynamic>?;

            if (februaryData == null || !februaryData.containsKey('23')) {
              return Center(child: Text('Attendance data not found.'));
            }

            final twentyThirdData = februaryData['23'] as Map<String, dynamic>?;

            if (twentyThirdData == null || !twentyThirdData.containsKey('count')) {
              return Center(child: Text('Attendance data not found.'));
            }

            final int userAttendance = twentyThirdData['count'] as int? ?? 0;
            double attendancePercentage = (userAttendance / 30) * 100; // Assuming 30 days in a month

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${widget.user.uid}'),
                      SizedBox(height: 10),
                      Text('Attendance Count: $userAttendance'),
                      SizedBox(height: 10),
                      Text('Attendance Percentage: ${attendancePercentage.toStringAsFixed(2)}%'),
                      // Add more fields or format the data as needed
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
