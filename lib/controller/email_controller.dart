import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class EmailController {
  static const String _sreviceID = 'service_1pnfunr';
  static const String _templateID = 'template_a3y38ll';
  static const String _publicKeyID = 'znsbjHtiV5t7CtJLo'; //: The public key for your EmailJS account.

  static Future<void> sendEmail(
      {required String email, required String name}) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final res = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http:localhost'
        },
        body: jsonEncode({
          'service_id': _sreviceID,
          'template_id': _templateID,
          'user_id': _publicKeyID,
          'template_params': {'email': email, 'name': name}
        }));
    if (res.statusCode == 200) {
      print('sentttttttt ');
    } else {
      print('Failedddddddd ${res.body}');
    }
  }
}


class ResetEmailController {
  static const String _serviceID = 'service_1pnfunr';
  static const String _templateID = 'template_0s13rha';
  static const String _publicKeyID = 'znsbjHtiV5t7CtJLo';

  static Future<void> sendPasswordResetEmail({
    required String email,
    required String userName,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'origin': 'http://localhost', // Adjust as necessary
      },
      body: jsonEncode({
        'service_id': _serviceID,
        'template_id': _templateID,
        'user_id': _publicKeyID,
        'template_params': {
          'user_name': userName, // Use the user name passed as a parameter
          'user_email': email, // Use the email passed as a parameter
        },
      }),
    );

    if (response.statusCode == 200) {
      print('Password reset email sent successfully.');
    } else {
      print('Failed to send password reset email. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }
}

