import 'package:blokapp/pages/register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/main.dart';
import 'register.dart';
import 'dart:convert';

void login(String uisername, String password) async {
  final String apiUrl = 'http://your-express-server-url.com/api/data';
  final Map<String, dynamic> payload = {
    'key1': 'value1',
    'key2': 'value2',
  };

  final String jsonData = jsonEncode(payload);
  try {
    final response = await http.post(Uri.parse(apiUrl),
        body: jsonData, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      print('Data sent successfully');
    } else {
      print('Failed to send data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending data: $e');
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Login form goes here
            ElevatedButton(
              onPressed: () {
                login("", "");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
              child: Text('Login'),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => RegisterPage()));
                },
                child: Text('register'))
          ],
        ),
      ),
    );
  }
}
