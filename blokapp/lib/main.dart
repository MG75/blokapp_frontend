import 'dart:async';
import 'package:blokapp/pages/mainpage.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'storage.dart';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'pages/login.dart';
import 'pages/mainpage.dart';
import 'pages/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final KeyToken = await storage.read(key: 'LoginToken');
  String povezava = globals.povezava;
  print(KeyToken);
  print('object');

  if (KeyToken != null) {
    print(KeyToken);
    String token = KeyToken;

    try {
      final response = await http.get(
        Uri.parse(
            'http://$povezava:3000/users/validate-LoginToken'), // Replace with your server endpoint
        headers: {'authorization': 'Bearer $KeyToken'},
      );

      if (response.statusCode == 200) {
        print('valid');
        globals.isLoggedIn = true;
        // LoginToken is valid, navigate to authenticated screen
        final Map<String, dynamic> LoginToken = JwtDecoder.decode(token);
        globals.UserID = LoginToken['id'];
        globals.username = LoginToken['username'];
        globals.blok = LoginToken['blok'];
        runApp(
          MaterialApp(
            title: 'Blokapp',
            home: HomaPage(),
          ),
        );
        return;
      }
    } catch (e) {
      print('no connection $e');
    }
  }
  // LoginToken is not valid or doesn't exist, navigate to login screen
  runApp(
    MaterialApp(
      title: 'Blokapp',
      home: LoginPage(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Blokapp',
                textAlign: TextAlign.left,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => settings()),
                );
              },
              icon: Icon(Icons.settings),
            ),
          ],
        ),
      ),
      body: Center(child: Text('globals.username')),
    );
  }
}
