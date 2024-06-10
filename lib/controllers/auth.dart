import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final GlobalKey<FormState> formKey = GlobalKey<FormState>();
final storage = FlutterSecureStorage();

Client client = Client()
    .setEndpoint('https://cloud.appwrite.io/v1')
    .setProject('659a49f76dc92833dd6d')
    .setSelfSigned(
        status: true); // For self signed certificates, only use for development

Account account = Account(client);

// // Create a new user using email
// Future<String> createUser(String name, String email, String password) async {
//   try {
//     await account.create(
//         userId: ID.unique(), email: email, password: password, name: name);
//     return "success";
//   } on AppwriteException catch (e) {
//     return e.message.toString();
//   }
// }

// // Login and create new session
// Future<String> loginUser(String email, String password) async {
//   try {
//     await account.createEmailSession(email: email, password: password);
//     return "success";
//   } on AppwriteException catch (e) {
//     return e.message.toString();
//   }
// }

// check if user session is active or not
Future<bool> checkSessions() async {
  try {
    await account.getSession(sessionId: "current");
    return true;
  } catch (e) {
    return false;
  }
}


Future<void> saveToken(String token) async {
  await storage.write(key: 'token', value: token);
}

Future<String?> getToken() async {
  return await storage.read(key: 'token');
}


// // logout the user delete the session
// Future logoutUser() async {
//   await account.deleteSession(sessionId: "current");
// }

// // get details of the user logged in
// Future<User?> getUser() async {
//   try {
//     final user = await account.get();
//     return user;
//   } catch (e) {
//     return null;
//   }
// }

// // send verification mail to the user
// Future<bool> sendVerificationMail() async {
//   try {
//     await account.createVerification(
//         url:
//             "https://reset-password-and-verify-email-appwrite.onrender.com/verify");
//     return true;
//   } catch (e) {
//     return false;
//   }
// }

// // send recovery mail to the user
// Future<bool> sendRecoveryMail(String email) async {
//   try {
//     await account.createRecovery(
//         email: email,
//         url:
//             "https://reset-password-and-verify-email-appwrite.onrender.com/recovery");
//     return true;
//   } catch (e) {
//     print(e);
//     return false;
//   }
// }

// // continue with google
// Future<bool> continueWithGoogle() async {
//   try {
//     final response = await account
//         .createOAuth2Session(provider: "google", scopes: ["profile", "email"]);
//     print(response);
//     return true;
//   } catch (e) {
//     print("error : ${e.toString()}");
//     return false;
//   }
// }

// Base URL of your Express server
const String baseUrl = 'http://localhost:3000';

// Register a new user
Future<String> createUser(String name, String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return "success";
    } else {
      return "Failed to register user: ${response.body}";
    }
  } catch (e) {
    return e.toString();
  }
}

// Login and create new session
Future<String> loginUser(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // Save the token for future requests
      String token = data['token'];
      // You can use shared_preferences to store the token locally
      // for now, let's return the token
      // Store the token using flutter_secure_storage
      await storage.write(key: 'token', value: token);
      return "success";
    } else {
      return "Failed to login: ${response.body}";
    }
  } catch (e) {
    return e.toString();
  }
}

// Check if user session is active or not
// Future<bool> checkSession(String token) async {
//   try {
//     final response = await http.get(
//       Uri.parse('$baseUrl/session'),
//       headers: <String, String>{
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       return true;
//     } else {
//       return false;
//     }
//   } catch (e) {
//     return false;
//   }
// }

// Logout the user
Future<String> logoutUser(String token) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return "success";
    } else {
      return "Failed to logout: ${response.body}";
    }
  } catch (e) {
    return e.toString();
  }
}

// Get details of the user logged in
Future<Map<String, dynamic>?> getUser(String token) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Failed to fetch user data: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error: $e");
    return null;
  }
}

// Send verification mail to the user
Future<bool> sendVerificationMail(String token) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/verify'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Failed to send verification mail: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error: $e");
    return false;
  }
}

// Send recovery mail to the user
Future<bool> sendRecoveryMail(String email) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/recover'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Failed to send recovery mail: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error: $e");
    return false;
  }
}

// Continue with Google
Future<bool> continueWithGoogle() async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/oauth/google'),
    );

    if (response.statusCode == 200) {
      print("Google OAuth not implemented");
      return true;
    } else {
      print("Failed to continue with Google: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error: $e");
    return false;
  }
}
