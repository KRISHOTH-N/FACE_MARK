import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fingerprint Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FingerprintRegistrationScreen(),
    );
  }
}

class FingerprintRegistrationScreen extends StatelessWidget {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<void> _registerFingerprint() async {
    try {
      // Check if biometrics are available
      bool canCheckBiometrics = await _auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        // Biometrics not available on this device
        return;
      }

      // Authenticate with biometrics
      bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Register your fingerprint',
        biometricOnly: true,
      );

      if (didAuthenticate) {
        // Biometric authentication successful
        // You can also show success message to the user
        _sendFingerprintForRegistration();
      } else {
        // Biometric authentication failed
        // You can show an error message to the user
      }
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  Future<void> _sendFingerprintForRegistration() async {
    try {
      // Generate fingerprint data
      // This is just a placeholder, replace it with actual fingerprint data
      String fingerprintData = "fingerprint_data_here";

      // Hash the fingerprint data for security
      String hashedFingerprint = _hashFingerprint(fingerprintData);
      var url = Uri.parse('http://192.168.45.31:5000/register');


      // Send hashed fingerprint data to backend for registration
      final response = await http.post(
       url ,
        body: jsonEncode({'userId': 'user_id_here', 'fingerprint': hashedFingerprint}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Registration successful
        // You can show a success message to the user
      } else {
        // Registration failed
        // You can show an error message to the user
      }
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  String _hashFingerprint(String fingerprintData) {
    // Hash the fingerprint data using a secure hashing algorithm like SHA-256
    return 'hashed_fingerprint_data'; // Replace this with actual hashing logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fingerprint Registration'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _registerFingerprint,
          child: Text('Register Fingerprint'),
        ),
      ),
    );
  }
}
