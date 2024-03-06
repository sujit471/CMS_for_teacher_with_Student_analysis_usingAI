import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final CollectionReference studentsCollection =
  FirebaseFirestore.instance.collection('users');
  final CollectionReference attendanceCollection =
  FirebaseFirestore.instance.collection('student_attendance');
  Map<String, bool> attendance = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Attendance'),
        actions: [
          IconButton(
            onPressed: () => submitAttendance(),
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: StreamBuilder<QuerySnapshot>(
              stream:
              studentsCollection.orderBy('rollNumber').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                List<DocumentSnapshot> students = snapshot.data!.docs;

                return SingleChildScrollView(
                  child: DataTable(
                    headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    dataTextStyle: TextStyle(
                      fontSize: 16,
                    ),
                    columns: const [
                      DataColumn(label: Text('Roll Number')),
                      DataColumn(
                        label: Text('Name'),
                      ),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: students.map((student) {
                      String studentId = student.id;
                      String studentName = student.get('name') ?? 'Unknown';
                      String rollNumber =
                          student.get('rollNumber').toString() ?? 'Unknown';
                  
                      return DataRow(
                        cells: [
                          DataCell(Text(rollNumber)),
                          DataCell(Text(studentName)),
                          DataCell(
                            Checkbox(
                              value: attendance.containsKey(studentId)
                                  ? attendance[studentId]
                                  : false,
                              onChanged: (value) =>
                                  markAttendance(studentId),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> markAttendance(String studentId) async {
    try {
      DateTime currentDate = DateTime.now();
      // Check if attendance for today already exists for this student
      final attendanceDoc =
      await attendanceCollection.doc(studentId).get();
      if (attendanceDoc.exists) {
        final attendanceData =
        attendanceDoc.data() as Map<String, dynamic>?;

        if (attendanceData != null &&
            attendanceData.containsKey('last_attendance_date')) {
          final lastAttendanceDate =
          attendanceData['last_attendance_date'] as Timestamp;
          final lastAttendanceDateTime = lastAttendanceDate.toDate();
          if (isSameDay(currentDate, lastAttendanceDateTime)) {
            // Attendance for today already marked, don't update
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Attendance already marked for today'),
              ),
            );
            return;
          }
        }
      }

      // Mark attendance for today
      setState(() {
        attendance[studentId] = !(attendance[studentId] ?? false);
      });

      // Update last attendance date in Firestore
      await attendanceCollection.doc(studentId).set({
        'last_attendance_date': Timestamp.fromDate(currentDate),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error marking attendance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking attendance'),
        ),
      );
    }
  }

  Future<void> submitAttendance() async {
    try {
      DateTime currentDate = DateTime.now();
      List<DocumentSnapshot> users = (await studentsCollection.get()).docs;

      for (DocumentSnapshot user in users) {
        String userId = user.id;
        bool isPresent = attendance[userId] ?? false;

        await studentsCollection.doc(userId).set({
          'attendance_date': currentDate,
          'attendance_status': isPresent
        }, SetOptions(merge: true));

        await attendanceCollection.doc(userId).set({
          'attendance_count': FieldValue.increment(isPresent ? 1 : 0),
          'last_attendance_date': Timestamp.fromDate(currentDate),
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

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
