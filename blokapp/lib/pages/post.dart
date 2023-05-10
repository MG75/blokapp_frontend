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

void VoteOn(int identi, int pid) async{
  final povezava = globals.povezava;
  final user = globals.UserID;
  try{
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

  }catch(e){
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
  int score = 0;
  bool scoreRecorded = false;
  int? value;
  int? vid;

  Future<void> VoteData(int pid, int uid) async {

    final povezava = globals.povezava;
    print('http://$povezava:3000/vote/get/$uid/$pid');
    try {
      final response = await http
          .get(Uri.parse('http://$povezava:3000/votes/get/$uid/$pid'));
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          print(response.body);
          var responseBody = json.decode(response.body);
          print(responseBody);
          value = responseBody['value'];
          vid = responseBody['id'];
          print(value);
          print(vid);
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
  }

  @override
  Widget build(BuildContext context) {
    
    print(score);
    if (widget.selectedPost['user_id'] == globals.UserID) {
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
              ],
            )),
        floatingActionButton: FloatingActionButton(
          onPressed: () => setState(
            () {},
          ),
          child: const Icon(Icons.edit),
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
        body: Container(
          padding: EdgeInsets.all(6.0),
          child: Text(
            widget.selectedPost['description'],
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }
  }
}
