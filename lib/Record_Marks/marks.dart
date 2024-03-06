import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentMarksPage extends StatefulWidget {
  @override
  _StudentMarksPageState createState() => _StudentMarksPageState();
}

class _StudentMarksPageState extends State<StudentMarksPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController rollNumberController = TextEditingController();
  Map<String, int> marks = {};
  String? userId;
  Map<String, String> users = {};
  final List<String> subjects = [
    'Engineering professional practice',
    'Big Data',
    'Multimedia',
    'Telecommunication',
    'Information System',
    'Energy Environment & Society'
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      users = Map.fromEntries(querySnapshot.docs.map((doc) => MapEntry(doc.id, doc['rollNumber'])));
    });
  }

  void _recordMarks() {
    if (userId != null) {
      Map<String, dynamic> marksData = {
        'total_marks': marks.values.reduce((value, element) => value + element),
        'subjects': marks,
      };
      FirebaseFirestore.instance.collection('Marks').doc(userId).set(
        marksData,
        SetOptions(merge: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Marks'),
      ),
      body: SingleChildScrollView (
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
              SizedBox(height: 24.0),
              const Text(
                'Enter Marks',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              for (var subject in subjects) _buildSubjectInput(subject),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  _recordMarks();
                },
                child: const Text('Record Marks'),
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
            child: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                int marksValue = int.tryParse(value.trim()) ?? 0;
                marks[subjectName] = marksValue;
              },
              decoration: const InputDecoration(
               // labelText: 'Marks',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
