import 'dart:async';
import 'package:blokapp/pages/newPost.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import '/storage.dart';
import '/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/pages/login.dart';
import '/pages/newPost.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as refresh;
import 'post.dart';
import '/pages/settings.dart';

class HomaPage extends StatefulWidget {
  const HomaPage({super.key});

  @override
  State<HomaPage> createState() => _HomaPageState();
}

class _HomaPageState extends State<HomaPage> {
  List<Map<String, dynamic>> posts = [];
  int? selectedIndex;
  refresh.RefreshController _refreshController =
      refresh.RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    String povezava = globals.povezava;
    int? buildingId = globals.blok;
    print(globals.blok);
    print(buildingId);
    try {
      final response = await http
          .get(Uri.parse('http://$povezava:3000/posts/display/$buildingId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(
          () {
            {
              final List<dynamic> responseBody = json.decode(response.body);
              final List<Map<String, dynamic>> post = responseBody
                  .map((post) => Map<String, dynamic>.from(post))
                  .toList();
              posts = responseBody
                  .map((post) => Map<String, dynamic>.from(post))
                  .toList();
            }
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No internet connection'),
        ),
      );
    }
    _refreshController.refreshCompleted();
  }

  Widget buildListView() {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () {
            setState(
              () {
                selectedIndex = isSelected ? null : index;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Post(
                      selectedPost: post,
                    ),
                  ),
                );
              },
            );
          },
          child: Container(
            height: 48.0,
            color: Colors.white,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  post['title'],
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  post['score'].toString(),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: refresh.SmartRefresher(
        controller: _refreshController,
        onRefresh: fetchData,
        child: buildListView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => newPost(),
          ))
              .then(
            (value) {
              // Refresh the main page when the secondary page closes
              if (value != null && value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomaPage()),
                );
              }
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
