import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentMarksPagee extends StatefulWidget {
  @override
  _StudentMarksPageeState createState() => _StudentMarksPageeState();
}

class _StudentMarksPageeState extends State<StudentMarksPagee> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController rollNumberController = TextEditingController();
  Map<String, Map<String, int>> marks = {};

  @override
  void initState() {
    super.initState();
    _fetchStudentsData();
  }

  void _fetchStudentsData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    querySnapshot.docs.forEach((doc) {
      marks[doc['rollNumber']] = {};
    });
  }

  void _recordMarks(String subject, int marks) {
    String rollNumber = rollNumberController.text.trim();
    if (rollNumber.isNotEmpty) {
      setState(() {
        this.marks[rollNumber]![subject] = marks;
      });
    }
  }

  int _calculateTotalMarks(String rollNumber) {
    int totalMarks = 0;
    if (marks.containsKey(rollNumber)) {
      marks[rollNumber]!.forEach((subject, marks) {
        totalMarks += marks;
      });
    }
    return totalMarks;
  }

  void _recordTotalMarks(String rollNumber, int totalMarks) {
    FirebaseFirestore.instance.collection('Marks').doc(rollNumber).set({
      'total_marks': totalMarks,
    });
  }

  void _recordAttendance(String rollNumber) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      FirebaseFirestore.instance.collection('attendance').doc(uid).set({
        rollNumber: true, // true for present, false for absent
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Marks and Attendance'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: rollNumberController,
              decoration: InputDecoration(
                labelText: 'Enter Roll Number',
              ),
            ),
            SizedBox(height: 16.0),
            for (var i = 1; i <= 6; i++)
              _buildSubjectInput(i),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String rollNumber = rollNumberController.text.trim();
                if (rollNumber.isNotEmpty) {
                  int totalMarks = _calculateTotalMarks(rollNumber);
                  _recordTotalMarks(rollNumber, totalMarks);
                  _recordAttendance(rollNumber);
                }
              },
              child: Text('Record Marks'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectInput(int subjectIndex) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'Subject $subjectIndex',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          flex: 3,
          child: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              int marks = int.tryParse(value.trim()) ?? 0;
              _recordMarks('Subject $subjectIndex', marks);
            },
          ),
        ),
      ],
    );
  }
}


