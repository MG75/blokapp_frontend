import 'dart:ffi';
import 'package:blokapp/pages/mainpage.dart';
import 'login.dart';
import 'package:blokapp/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/main.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import '/storage.dart';
import 'settings.dart';
import '/globals.dart' as globals;

void register(BuildContext context, String name, String mail, String password,
    int blok) async {
  final String apiUrl = 'http://$povezava:3000/users/register';
  final Map<String, dynamic> payload = {
    'name': name,
    'email': mail,
    'password': password,
    'blok': blok,
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
          MaterialPageRoute(builder: (context) => HomaPage()),
        );
      } else {}
    } else {
      print('Failed to send data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending data: $e');
  }
}

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late int _selectedValue;
  List<Map<String, dynamic>> _options = [];

  Future<void> _getOptions() async {
    String povezava = globals.povezava;
    print(povezava);
    try {
      final response =
          await http.get(Uri.parse('http://$povezava:3000/buildings/options'));
      if (response.statusCode == 200) {
        setState(() {
          final List<dynamic> responseBody = json.decode(response.body);
          final List<Map<String, dynamic>> buildings = responseBody
              .map((building) => Map<String, dynamic>.from(building))
              .toList();
          _options = responseBody
              .map((building) => Map<String, dynamic>.from(building))
              .toList();
        });
      } else {
        print('Error retrieving options from API');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No internet connection'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getOptions();
  }

  @override
  final _formKey = GlobalKey<FormState>();
  bool _formValid = false;
  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Register',
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
                icon: Icon(Icons.settings)),
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
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
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
                  DropdownButtonFormField(
                    value: null,
                    items: _options.map((option) {
                      return DropdownMenuItem(
                        value: option['id'],
                        child: Text(option['adress']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedValue = value as int;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a value';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Blok'),
                  ),
                  ElevatedButton(
                    onPressed: _formValid
                        ? () {
                            register(
                              context,
                              _nameController.text,
                              _emailController.text,
                              _passwordController.text,
                              _selectedValue,
                            );
                          }
                        : null,
                    child: Text('Register'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: Text('login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
