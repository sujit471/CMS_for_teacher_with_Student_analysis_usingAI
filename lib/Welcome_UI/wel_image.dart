import 'dart:convert';
//import 'package:college_management_app/Homework/homework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_management_app_teachers/Attendance/attendance_student.dart';
import 'package:college_management_app_teachers/Attendance/attendanceteacher.dart';
import 'package:college_management_app_teachers/Assignmentforall//forall.dart';
import 'package:college_management_app_teachers/News/news.dart';
import 'package:college_management_app_teachers/progress%20chart/chart.dart';
import 'package:college_management_app_teachers/thingsincollege/collegethings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../Academic_Calendar/academic_calendar.dart';
import '../Attendance/attendance.dart';
import '../Chart/chart.dart';
import '../Record3data/record3data.dart';
import'../Record_Marks/marks.dart';
import '../Notification/notification.dart';
import '../Record_Marks/recordtofirebase.dart';
import 'Icons.dart';
import 'selectcard.dart';
import 'package:path/path.dart';


class YourApp extends StatefulWidget {
  const YourApp({Key? key}) : super(key: key);

  @override
  State<YourApp> createState() => _YourAppState();
}

class _YourAppState extends State<YourApp> {
  late Future<String> profileImageUrl;
  late Future<String> username;

  @override
  void initState() {
    super.initState();
    profileImageUrl = fetchProfileImage();
    username = fetchUsername();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            toolbarHeight: 60,
            toolbarOpacity: 0.7,
            backgroundColor: Colors.grey,
           leading: const Icon(Icons.menu),
            title: FutureBuilder<String>(
              future: username,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Welcome User'); // Show 'Welcome User' while loading
                } else if (snapshot.hasError) {
                  return const Text('Error'); // Handle error case
                } else {
                  String username = snapshot.data!;
                  return Text('Welcome, $username Sir!',style:TextStyle(color:Colors.white,)); // Show 'Welcome, {username}' when data is available
                }
              },
            ),
            actions: [
              FutureBuilder(
                future: profileImageUrl,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(); // Return an empty container while loading
                  } else if (snapshot.hasError) {
                    return Container(); // Handle error case
                  } else {
                    String imageUrl = snapshot.data.toString();
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        // backgroundImage: NetworkImage(imageUrl),
                        backgroundImage: AssetImage('svgimage/img.png'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 30.0,
              mainAxisSpacing: 2.0,
              children: List.generate(choices.length, (index) {
                return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>choices[index].destinationPage),);
                    },
                    child: SelectCard(
                      choice: choices[index],
                    ));
              })),
        ));
  }

  Future<String> fetchProfileImage() async {
    var response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/photos/1'));

    if (response.statusCode == 200) {
      var photoData = json.decode(response.body);
      return photoData['url'];
    } else {
      throw Exception('Failed to load profile image');
    }
  }
}
Future<String> fetchUsername() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection('Teachers').doc(user.uid).get();
    return doc['name'];
  } else {
    throw Exception('User not logged in');
  }
}

List<HelloSvg> choices = <HelloSvg>[
  HelloSvg(
    name: 'Attendances',
    svgAssetPath: 'svgimage/calendar.svg',
    color: Colors.green,
    // icon: Icon(Icons.calendar_month),

    height: 35,
    width: 35,
    //destinationPage:AttendanceScreenss(user: FirebaseAuth.instance.currentUser!,),
    destinationPage:TeacherAttendancePage(user:FirebaseAuth.instance.currentUser!,),
// icon: Icon(Icons.headphones),
  ),

  HelloSvg(
    name: 'Homework',
    svgAssetPath: 'svgimage/homework.svg',
    color: Colors.orange,

    height: 30,
    width: 30, destinationPage:HomeworkUpload(),

    // icon: Icon(Icons.copy),
  ),
  HelloSvg(
    name: 'Atendance(s)',
    svgAssetPath: 'svgimage/attendance_student.svg',
    color: Colors.purple,


    height: 50,
    width: 30, destinationPage: AttendanceScreen(),
    //icon: Icon(Icons.account_circle),
  ),
  HelloSvg(
    name: 'test',
    svgAssetPath: 'svgimage/exam1.svg',
    color: Colors.orange,

    height: 20,
    width: 20, destinationPage: StudentMarksPage(),
    // icon: Icon(Icons.book_outlined),
  ),
  HelloSvg(
    name: 'Activity',
    svgAssetPath: 'svgimage/doubleuser.svg',
    color: Colors.purple,

    height: 30,
    width: 30, destinationPage:Activities(),
    // icon: Icon(Icons.headphones),
  ),
  HelloSvg(
    name: 'Charts',
    svgAssetPath: 'svgimage/time.svg',
    color: Colors.greenAccent,

    height: 30,
    width: 30, destinationPage: StudentMarksChart(),
    // icon: Icon(Icons.abc_rounded),
  ),
  HelloSvg(
    name: 'Time Table',
    svgAssetPath: 'svgimage/timetable.svg',
    color: Colors.green,

    height: 30,
    width: 30, destinationPage: Imageviewer (),
    //icon: Icon(Icons.timelapse),
  ),
  HelloSvg(
    name: 'Notices',
    svgAssetPath: 'svgimage/messages.svg',
    color: Colors.purple,

    height: 30,
    width: 30, destinationPage: NewsScreen(),
    //icon: Icon(Icons.message),
  ),
  HelloSvg(
    name: 'Record Data',
    svgAssetPath: 'svgimage/more.svg',
    color: Colors.blue,

    height: 30,
    width: 30, destinationPage: Student3Data (),
    //icon: Icon(Icons.more),
  ),
];
