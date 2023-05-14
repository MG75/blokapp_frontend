import 'dart:async';
import 'package:blokapp/pages/login.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/storage.dart';
import 'login.dart';

class settings extends StatefulWidget {
  const settings({super.key});

  @override
  State<settings> createState() => _settingsState();
}


final _nameController = TextEditingController();
final _passwordController = TextEditingController();
final _connectionPasswordcontroller = TextEditingController();
String povezava = globals.povezava;



void save() {
  globals.povezava = _connectionPasswordcontroller.text;
  povezava = globals.povezava;
}

void saveuser() async {
  final povezava = globals.povezava;
  final uid = globals.UserID;
  globals.username = _nameController.text;
  try {
    final String apiUrl = 'http://$povezava:3000/users/update';
    final Map<String, dynamic> payload = {
      'name_surname': _nameController.text,
      'uid': uid,
      'password': _passwordController.text,
    };
    final String jsonData = jsonEncode(payload);
    print(jsonData);
    final response = await http.post(Uri.parse(apiUrl),
        body: jsonData, headers: {'Content-Type': 'application/json'});
  } catch (e) {
    print('nope $e');
  }
}

void logout(BuildContext context) {
  globals.isLoggedIn = false;
  storage.delete(key: 'LoginToken');
  globals.username = '';
  globals.UserID = null;
  globals.blok = null;
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}



class _settingsState extends State<settings> {

   @override
  void initState() {
    super.initState();
    _nameController.text = globals.username;
  }
  @override
  Widget build(BuildContext context) {
    print(globals.isLoggedIn);
    if (globals.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Settings',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
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
              SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'password',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      child: Text('Update user info'),
                      onPressed: saveuser,
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      child: Text('Logout'),
                      onPressed: () => logout(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _connectionPasswordcontroller,
                decoration: InputDecoration(
                  labelText: povezava,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter connection';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Save'),
                onPressed: save,
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Settings',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _connectionPasswordcontroller,
                decoration: InputDecoration(
                  labelText: povezava,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter connection';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Save'),
                onPressed: save,
              ),
            ],
          ),
        ),
      );
    }
  }
}
