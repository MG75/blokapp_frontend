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



class HomaPage extends StatefulWidget {
  const HomaPage({super.key});

  @override
  State<HomaPage> createState() => _HomaPageState();
}

class _HomaPageState extends State<HomaPage> {
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
                'Home',
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
      body: Center(child: Text('globals.username')),
    );
  }
}