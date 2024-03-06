import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SignUpPage extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

void _startConfetti() {
  _confettiController.play();
  Future.delayed(Duration(seconds: 4), () {
    _confettiController.stop();
  });
}

class _SignUpState extends State<SignUpPage> {
  final List<String> facultyOptions = [
    'Electronics Engineering',
    'Computer Engineering',
    'Civil Engineering',
    'Electrical Engineering',
  ];

  bool _obscureText = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController facultyController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedFaculty;

  Future<String?> _pickImage() async {
    final imagePicker = ImagePicker();

    try {
      final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Upload the image and return the download URL
        return await _uploadImageToFirebaseStorage(pickedFile.path, '');
      } else {
        print('No image selected.');
        return null;
      }
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<String?> _uploadImageToFirebaseStorage(String filePath, String imageUrl) async {
    try {
      final firebase_storage.Reference storageReference = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('ygs://collegemanagementappacem.appspot.com')
          .child('images')
          .child('image_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final file = File(filePath);
      final firebase_storage.UploadTask uploadTask = storageReference.putFile(file);

      await uploadTask.whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image uploaded successfully! Welcome to ACEM Family'),
          duration: Duration(seconds: 3),
        ),
      ));

      return storageReference.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return imageUrl; // Return the provided imageUrl in case of an error
    }
  }

  void _register() async {
    try {
      _startConfetti();

      // Showing user creation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User created successfully! Welcome to ACEM Family'),
          duration: Duration(seconds: 3),
        ),
      );

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      String uid = user?.uid ?? '';

      // Use imageUrl in your user registration
      await FirebaseFirestore.instance.collection('Teachers').doc(uid).set({
        'name': nameController.text.trim(),
        'faculty': selectedFaculty,
        'email': emailController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
      });

      // Additional logic or navigation can be added here
    } catch (e) {
      // Handle registration errors
      print('Error registering user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirection: -1.0,
      emissionFrequency: 0.05,
      numberOfParticles: 20,
      maxBlastForce: 50,
      minBlastForce: 20,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      colors: const [Colors.blue, Colors.green, Colors.pink],
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("Sign Up")),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Create Your Account",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("please enter your info"),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey[200],
                  ),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: 'Name',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  child: DropdownButtonFormField<String>(
                    value: selectedFaculty,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFaculty = newValue;
                      });
                    },
                    items: facultyOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.subject),
                      labelText: 'Faculty',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey[200],
                  ),
                  child: TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      labelText: 'Phone Number',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey[200],
                  ),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      labelText: 'Email',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey[200],
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.key),
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _register,
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

ConfettiController _confettiController = ConfettiController();
