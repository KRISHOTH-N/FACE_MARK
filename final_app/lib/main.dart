import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi and Biometric Authentication Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WiFiConnectionPage(),
        '/biometric': (context) => BiometricAuthenticationPage(),
        '/imageUpload': (context) => ImageUploadScreen(),
      },
    );
  }
}

class WiFiConnectionPage extends StatefulWidget {
  @override
  _WiFiConnectionPageState createState() => _WiFiConnectionPageState();
}

class _WiFiConnectionPageState extends State<WiFiConnectionPage> {
  final NetworkInfo networkInfo = NetworkInfo();

  @override
  void initState() {
    super.initState();
    checkWiFiConnection();
  }

  Future<void> checkWiFiConnection() async {
    try {
      String _wifiIP = await networkInfo.getWifiIP() ?? 'Not available';
      String _wifiGateway = await networkInfo.getWifiGatewayIP() ?? 'Not available';


      if (_wifiIP == '192.168.4.2' || _wifiGateway=='192.168.4.1') {
        Navigator.pushReplacementNamed(context, '/biometric');
      } else {
        // Do not proceed, handle as needed
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('WiFi connection error'),
              content: Text('WiFi connection not allowed.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error fetching WiFi info: $e');
      // Handle error accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WiFi Connection Check'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class BiometricAuthenticationPage extends StatefulWidget {
  @override
  _BiometricAuthenticationPageState createState() =>
      _BiometricAuthenticationPageState();
}

class _BiometricAuthenticationPageState
    extends State<BiometricAuthenticationPage> {
  final LocalAuthentication auth = LocalAuthentication();

  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Biometric Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Biometric Authentication Page'),
            SizedBox(height: 16),
            if (_isAuthenticating)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _authenticateWithBiometrics,
                child: Text('Authenticate with Biometrics'),
              ),
            SizedBox(height: 16),
            Text('Authentication Status: $_authorized'),
          ],
        ),
      ),
    );
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
      );
      setState(() {
        _isAuthenticating = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - $e';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    if (authenticated) {
      Navigator.pushReplacementNamed(context, '/imageUpload');
    }
  }
}

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;

  Future<void> _getImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _uploadImage();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      print('No image selected.');
      return;
    }

    final uri = Uri.parse('http://192.168.45.31:5000/upload');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    } else {
      print('Failed to upload image. Error: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('No image captured.')
                : Image.file(
                    _image!,
                    height: 200,
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImageFromCamera,
              child: Text('Capture Image'),
            ),
          ],
        ),
      ),
    );
  }
}
