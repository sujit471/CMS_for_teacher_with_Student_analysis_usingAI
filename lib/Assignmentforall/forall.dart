import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeworkUpload extends StatefulWidget {
  @override
  _HomeworkUploadState createState() => _HomeworkUploadState();
}

class _HomeworkUploadState extends State<HomeworkUpload> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedSubject = 'EPP'; // Default subject
  DateTime _selectedDate = DateTime.now();

  Future<void> _uploadHomework(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseFirestore.instance.collection('homework').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'Due Date': _selectedDate,
          'subject': _selectedSubject,
        });

        _titleController.clear();
        _descriptionController.clear();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Homework uploaded successfully'),
          duration: Duration(seconds: 2),
        ));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to upload homework. Please try again later.'),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Homework'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border:  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border:  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null && pickedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Text(
                    _selectedDate == null
                        ? 'Select Due Date'
                        : 'Due Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  ),
                ),
                SizedBox(height: 20.0),
                DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value!;
                    });
                  },
                  items:const [
                    DropdownMenuItem<String>(
                      value: 'Telecommunication',
                      child: Text('Telecommunication'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Information System',
                      child: Text('Information System'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Big Data',
                      child: Text('Big Data'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Multimedia',
                      child: Text('Multimedia'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'EPP',
                      child: Text('EPP'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Computer Science',
                      child: Text('Computer Science'),
                    ),
                  ],
                  decoration: InputDecoration(labelText: 'Subject'),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () => _uploadHomework(context),
                  child: Text('Upload Homework'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
