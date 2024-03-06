import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherAttendancePage extends StatelessWidget {
  final User user;

  TeacherAttendancePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Attendance Data'),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('teacher_attendance').doc(user.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator(); // Or some loading indicator
            }
            Map<String, dynamic>? userData = snapshot.data?.data();
            if (userData == null) {
              return Text('No data found for current user');
            }
            // Display the user data
            return SingleChildScrollView(
              child: _buildTree(userData),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTree(Map<String, dynamic> data) {
    return _buildNode(data, level: 0);
  }

  Widget _buildNode(Map<String, dynamic> data, {required int level}) {
    Color backgroundColor;
    switch (level % 3) {
      case 0:
        backgroundColor = Colors.blue[100]!;
        break;
      case 1:
        backgroundColor = Colors.green[100]!;
        break;
      case 2:
        backgroundColor = Colors.orange[100]!;
        break;
      default:
        backgroundColor = Colors.blue[100]!;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var entry in data.entries)
          Padding(
            padding: EdgeInsets.only(left: level * 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key}:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      SizedBox(height: 8),
                      if (entry.value is Map<String, dynamic>)
                        _buildNode(entry.value, level: level + 1)
                      else
                        _buildLeaf(entry.value.toString()),
                    ],
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLeaf(String value) {
    return Text(value, style: TextStyle(color: Colors.black87));
  }
}
