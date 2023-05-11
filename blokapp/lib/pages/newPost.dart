import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import '/storage.dart';
import '/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/pages/login.dart';
import 'package:intl/intl.dart';
import '/pages/settings.dart';

void createPost(
  String title,
  String description,
  String date,
) async {
  final povezava = globals.povezava;
  final uid = globals.UserID;
  final bid = globals.blok;
  try {
    final String apiUrl = 'http://$povezava:3000/posts/new';
    final Map<String, dynamic> payload = {
      'title': title,
      'description': description,
      'uid': uid,
      'bid': bid,
      'date': date,
    };
    final String jsonData = jsonEncode(payload);
    print(jsonData);
    final response = await http.post(Uri.parse(apiUrl),
        body: jsonData, headers: {'Content-Type': 'application/json'});
  } catch (e) {
    print('nope $e');
  }
}

class newPost extends StatefulWidget {
  const newPost({super.key});

  @override
  State<newPost> createState() => _newPostState();
}

class _newPostState extends State<newPost> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

  @override
  final _formKey = GlobalKey<FormState>();
  bool _formValid = false;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'create new post',
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
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Title cannot be empty';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Description cannot be empty';
                      }
                      return null;
                    },
                  ),
                  Text(
                      '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}'),
                  ElevatedButton(
                    onPressed: () async {
                      showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 7)),
                      );
                    },
                    child: Text('Change date'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _formValid
            ? () {
                createPost(
                  _titleController.text,
                  _descriptionController.text,
                  selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(selectedDate)
                      : '',
                );
                Navigator.of(context).pop(true);
              }
            : null,
        child: const Icon(Icons.check),
      ),
    );
  }
}
