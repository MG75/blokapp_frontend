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
import '/pages/settings.dart';

void deletePost(int id) async {
  final povezava = globals.povezava;
  try {
    print(id);
    final String apiUrl = 'http://$povezava:3000/posts/delete';
    final Map<String, dynamic> payload = {
      'pid': id,
    };
    final String jsonData = jsonEncode(payload);
    print(jsonData);
    final response = await http.post(Uri.parse(apiUrl),
        body: jsonData, headers: {'Content-Type': 'application/json'});
  } catch (e) {
    print('nope $e');
  }
}

void VoteOn(int identi, int pid) async {
  final povezava = globals.povezava;
  final user = globals.UserID;
  try {
    final String apiUrl = 'http://$povezava:3000/votes/makevote';
    final Map<String, dynamic> payload = {
      'value': identi,
      'pid': pid,
      'uid': user,
    };
    final String jsonData = jsonEncode(payload);
    print(jsonData);
    final response = await http.post(Uri.parse(apiUrl),
        body: jsonData, headers: {'Content-Type': 'application/json'});
  } catch (e) {
    print('nope $e');
  }
}

void updatePost(int pid, String title, String description) async {
  final povezava = globals.povezava;
  try {
    final String apiUrl = 'http://$povezava:3000/posts/edit';
    final Map<String, dynamic> payload = {
      'title': title,
      'pid': pid,
      'description': description,
    };
    final String jsonData = jsonEncode(payload);
    print(jsonData);
    final response = await http.post(Uri.parse(apiUrl),
        body: jsonData, headers: {'Content-Type': 'application/json'});
  } catch (e) {
    print('nope $e');
  }
}

class Post extends StatefulWidget {
  Post({required this.selectedPost});

  final Map<String, dynamic> selectedPost;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  int score = 0;
  bool scoreRecorded = false;
  int? value;
  int? vid;
  String postuser = '';

  Future<void> VoteData(int pid, int uid) async {
    int? cid = globals.UserID;
    print('cid. $cid');
    print('pid: $pid');
    final povezava = globals.povezava;
    
    try {
      final respie = await http .get(Uri.parse('http://$povezava:3000/votes/getusername/$uid'));
      if (respie.statusCode == 200) {
        setState(() {
          var respiBody = json.decode(respie.body);
          postuser = respiBody['name_surname'];
        });
      } else {
        print('Error retrieving options from API');
      }
      final response = await http
          .get(Uri.parse('http://$povezava:3000/votes/get/$cid/$pid'));
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          var responseBody = json.decode(response.body);
          value = responseBody['value'];
          vid = responseBody['id'];
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
    VoteData(widget.selectedPost['id'], widget.selectedPost['user_id']);
    score = widget.selectedPost['score'];
    _titleController.text = widget.selectedPost['title'];
    _descriptionController.text = widget.selectedPost['description'];
  }

  final _formKey = GlobalKey<FormState>();
  bool _formValid = false;

  @override
  Widget build(BuildContext context) {
    print(score);
    if (widget.selectedPost['user_id'] != globals.UserID) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.selectedPost['title'],
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
          padding: EdgeInsets.all(6.0),
          child: Column(
            children: [
              Text(
                widget.selectedPost['title'],
                style: TextStyle(fontSize: 25),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(
                        () {
                          if (value == -1) {
                            score += 1;
                            value = 0;
                            VoteOn(value!, widget.selectedPost['id']);
                          } else if (value == 0) {
                            score += 1;
                            value = 1;
                            VoteOn(value!, widget.selectedPost['id']);
                          }
                        },
                      );
                    },
                    icon: Icon(Icons.arrow_upward),
                  ),
                  Text(
                    score.toString(),
                    style: TextStyle(fontSize: 20),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(
                        () {
                          if (value == 1) {
                            score -= 1;
                            value = 0;
                            VoteOn(value!, widget.selectedPost['id']);
                          } else if (value == 0) {
                            score -= 1;
                            value = -1;
                            VoteOn(value!, widget.selectedPost['id']);
                          }
                        },
                      );
                    },
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
              ),
              Text(
                widget.selectedPost['description'],
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Objavil: $postuser',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.selectedPost['title'],
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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Title cannot be empty';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Description cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton(
              onPressed: () {
                deletePost(widget.selectedPost['id']);
                Navigator.of(context).pop(true);
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.delete),
              heroTag: null,
            ),
            FloatingActionButton(
              onPressed: _formValid
                  ? () {
                      updatePost(
                        widget.selectedPost['id'],
                        _titleController.text,
                        _descriptionController.text,
                      );
                      Navigator.of(context).pop(true);
                    }
                  : null,
              child: const Icon(Icons.edit),
              heroTag: null,
            ),
          ],
        ),
      );
    }
  }
}
