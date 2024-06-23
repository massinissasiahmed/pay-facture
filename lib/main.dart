import 'package:email_google_auth_flutter_appwrite/controllers/auth.dart';
import 'package:email_google_auth_flutter_appwrite/views/home.dart';
import 'package:email_google_auth_flutter_appwrite/views/login.dart';
import 'package:email_google_auth_flutter_appwrite/views/signup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Email & Google Auth Appwrite',
      theme: ThemeData(
      


        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoSansTextTheme(),
      ),
      routes: {
        "/": (context) => const CheckSession(),
        "/home": (context) => const Homepage(),
        "/signup": (context) => const SignUpPage(),
        "/login": (context) => const LoginPage(),
      },
    );
  }
}

// Check Session Page
class CheckSession extends StatefulWidget {
  const CheckSession({super.key});

  @override
  State<CheckSession> createState() => _CheckSessionState();
}

class _CheckSessionState extends State<CheckSession> {
  @override
  void initState() {
    checkSession('').then((value) {
      if (value) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Navigator.restorablePushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
