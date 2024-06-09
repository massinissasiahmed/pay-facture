import 'package:appwrite/models.dart';
import 'package:email_google_auth_flutter_appwrite/controllers/auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late User _currentUser;
  bool isLoading = true;

  @override
  void initState() {
    getUser().then((value) {
      setState(() {
        _currentUser = value!;
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  Text("Welcome ${_currentUser.name} 👋"),
                  const SizedBox(
                    height: 10,
                  ),
                  Text("📧Email : ${_currentUser.email}"),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                      "✅Account Verified : ${_currentUser.emailVerification} "),
                  const SizedBox(
                    height: 10,
                  ),
                  _currentUser.emailVerification == false
                      ? TextButton(
                          onPressed: () {
                            sendVerificationMail().then((value) {
                              if (value) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: const Text(
                                    "Email Sent",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green.shade400,
                                ));
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: const Text(
                                    "Email not sent.",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red.shade400,
                                ));
                              }
                            });
                          },
                          child: const Text("Verify Email"))
                      : const SizedBox(),
                  ElevatedButton(
                      onPressed: () {
                        logoutUser();
                        Navigator.pushReplacementNamed(context, "/login");
                      },
                      child: const Text("Logout"))
                ],
              )));
  }
}
