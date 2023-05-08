import 'package:blokapp/pages/register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/main.dart';
import '/storage.dart';
import 'register.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'settings.dart';
import '/globals.dart' as globals;

void login(BuildContext context, String mail, String password) async {
  String povezava = globals.povezava;
  try {
    final String apiUrl = 'http://$povezava:3000/users/login';
    final Map<String, dynamic> payload = {
      'email': mail,
      'password': password,
    };

    final String jsonData = jsonEncode(payload);
    try {
      final response = await http.post(Uri.parse(apiUrl),
          body: jsonData, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String token = responseData['token'];

        if (token != null) {
          final Map<String, dynamic> LoginToken = JwtDecoder.decode(token);
          await storage.write(key: 'LoginToken', value: token);
          print(LoginToken);
          globals.isLoggedIn = true;
          globals.UserID = LoginToken['id'];
          globals.username = LoginToken['username'];
          globals.blok = LoginToken['blok'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Wrong email or password'),
            ),
          );
        }
      } else {
        print('Failed to send data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending data: $e');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No internet connection'),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  final _formKey = GlobalKey<FormState>();
  bool _formValid = false;
  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'login',
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
              icon: Icon(Icons.settings) 
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              onChanged: () {
                setState(() {
                  _formValid = _formKey.currentState!.validate();
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      // Check if the input string is a valid email format using regex
                      // Regular expression to match most common email formats
                      // Note: this is not a perfect email validation regex, but should be sufficient for most use cases
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: _formValid
                        ? () {
                            login(context, _emailController.text,
                                _passwordController.text);
                          }
                        : null,
                    child: Text('Login'),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()));
                      },
                      child: Text('register'))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
