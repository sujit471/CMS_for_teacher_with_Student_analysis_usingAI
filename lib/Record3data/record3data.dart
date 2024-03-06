import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Student3Data extends StatefulWidget {
  @override
  _Student3DataState createState() => _Student3DataState();
}

class _Student3DataState extends State<Student3Data> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController rollNumberController = TextEditingController();
  Map<String, double> marks = {};
  String? userId;
  Map<String, String> users = {};
  final List<String> subjects = [
    'Assignment Score',
    'Assessment Score',
    'Attendance Score',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      users = Map.fromEntries(
          querySnapshot.docs.map((doc) => MapEntry(doc.id, doc['rollNumber'])));
    });
  }

  void _recordMarks() {
    if (userId != null && marks.isNotEmpty) {
      print("Recording marks for user: $userId");
      print("Marks: $marks");

      Map<String, dynamic> marksData = {
        'assignment_score': marks['Assignment Score'] ?? 0.0,
        'assessment_score': marks['Assessment Score'] ?? 0.0,
        'attendance_score': marks['Attendance Score'] ?? 0.0,
      };

      print("Marks Data: $marksData");

      FirebaseFirestore.instance.collection('predictordata').doc(userId).set(
        marksData,
        SetOptions(merge: true),
      ).then((value) {
        print("Marks recorded successfully!");
        _showSnackbar('Data recorded successfully!');
      }).catchError((error) {
        print("Error recording marks: $error");
        _showSnackbar('Error recording data: $error');
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictor Data'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: userId,
                onChanged: (String? value) {
                  setState(() {
                    userId = value!;
                  });
                },
                items: users.entries.map<DropdownMenuItem<String>>((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Select Student',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Enter Data (0-1)',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              for (var subject in subjects) _buildSubjectInput(subject),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  _recordMarks();
                },
                child: const Text('Record Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectInput(String subjectName) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              subjectName,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            flex: 2,
            child: TextFormField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                double marksValue = double.tryParse(value.trim()) ?? 0.0;
                if (marksValue > 1.0) {
                  marksValue = 1.0;
                } else if (marksValue < 0.0) {
                  marksValue = 0.0;
                }
                marks[subjectName] = marksValue;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
