import 'package:college_management_app_teachers/widgets/calendar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'Notification/notification.dart';
import 'Search/searching.dart';
import 'Userprofile/profile.dart';
import 'login/login.dart';
import 'login/signup.dart';
import 'navigation_menu/navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    //name: 'collegemanagementappACEM',
    options: const FirebaseOptions(
        apiKey: 'AIzaSyDVZBV6gXfOFtvuh21hxi9yVgShl_ZL2Qg',
        appId: '1:854814242691:android:8f36836778c56293b5a8b6',
        messagingSenderId: 'messagingSenderId',
        projectId: 'collegemanagementappacem'),

  );
  runApp(const MyApp());
}
Future<void> createAttendanceCollection() async {
  try {
    await FirebaseFirestore.instance.collection('student_attendance').doc('dummy_doc').set({});
  } catch (e) {
    print('Error creating student_attendance collection: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'College  Management System for teachers',
      initialRoute: '/home',
      routes: {
        '/': (context) => SignUpPage(),
        '/first': (context) => const Calendar(),
        '/second': (context) => const Notifications(),
        '/third': (context) => PredictionScreen(),
        '/fourth': (context) => Profile1(
              user: FirebaseAuth.instance.currentUser!,
            ),
        '/sixth': (context) => NavigationMenu(),
        '/eighth': (context) => LoginPage(),
        '/home':(context)=>SplashScreen(),
      },
      theme: ThemeData(
        backgroundColor: Colors.white,
        primarySwatch: Colors.blue,
// fontFamily: 'Inter',
       // textTheme: GoogleFonts.salsaTextTheme(),
      ),
    );
  }
}
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        AnimatedSplashScreen(
          splash:SizedBox.expand(
            child: Lottie.asset('animations/reading.json',
              repeat: true,
              reverse: true,
              animate: true,
              fit: BoxFit.cover,
            ),
          ),
          nextScreen: LoginPage(),
          // nextScreen: NavigationMenu(),
          splashTransition: SplashTransition.fadeTransition,
          duration: 3000,

        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.2,
          right: MediaQuery.of(context).size.width * 0.3,
          child:  const CircleAvatar(
            radius: 70,
            backgroundImage: AssetImage('svgimage/img.png'),
          ),
        ),
        const SizedBox(height: 10,),
        const Center(
          child: Text('Bridging Ideas, Building Engineers ',style: TextStyle(
            color:Colors.green,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,

          ),


          ),
        ),
        SizedBox(height: 10,),

      ],
    );
  }
}