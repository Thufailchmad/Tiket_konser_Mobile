import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:konser_tiket/ipAddress.dart';
import 'package:konser_tiket/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Deskripsi extends StatefulWidget {
  final int id;
  const Deskripsi({super.key, required this.id});

  @override
  State<Deskripsi> createState() => _DeskripsiState();
}

class _DeskripsiState extends State<Deskripsi> {
  var data = {};

  @override
  void initState() {
    super.initState();
    getData();
    print(widget.id);
  }

  Future<void> getData() async {
    final pref = await SharedPreferences.getInstance();
    String? token = pref.getString("token");
    final Map<String, String> header = {
      'User-Agent': 'android',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final req = await http.get(Uri.parse(ipAddress + "api/ticket/${widget.id}"),
        headers: header);
    final res = jsonDecode(req.body);
    if (req.statusCode == 202) {
      print(res);
      setState(() {
        data = res["data"];
      });
    } else {
      throw Exception("Gagal mendapatkan data");
    }
  }

  void addChart() async {
    final pref = await SharedPreferences.getInstance();
    String? token = pref.getString("token");
    final Map<String, String> header = {
      'User-Agent': 'android',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = {'ticketId': widget.id, 'qty': 1};
    final req = await http.post(Uri.parse(ipAddress + "api/chart/"),
        headers: header, body: jsonEncode(body));
    final res = jsonDecode(req.body);
    if (req.statusCode == 202) {
      print(res);
      setState(() {
        data = res["data"];
      });
    } else {
      throw Exception("Gagal mendapatkan data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    ),
                child: Text('data')),
            ElevatedButton(onPressed: addChart, child: Text('tambah'))
          ],
        ),
      ),
    );
  }
}
