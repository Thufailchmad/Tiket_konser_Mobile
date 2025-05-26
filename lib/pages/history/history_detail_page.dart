import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:konser_tiket/ipAddress.dart';
import 'package:konser_tiket/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryDetailPage extends StatefulWidget {
  final int id;
  const HistoryDetailPage({super.key, required this.id});

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  late var data = {};

  @override
  void initState() {
    // TODO: implement initState
    getData();
  }

  void getData() async {
    final pref = await SharedPreferences.getInstance();
    String? token = pref.getString("token");
    final Map<String, String> header = {
      'User-Agent': 'android',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final req = await http.get(
        Uri.parse(ipAddress + "api/history/${widget.id}"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(),
                    )),
                child: Text('kembali')),
            Text('total : ${data["total"]}'),
            Image.network(
              ipAddress + data["image"],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Text('Gambar tidak ditemukan'),
              ),
            ),
            Text(
              'Status: ${data['status'] == 0 ? "Diproses" : data['status'] == 1 ? "Diterima" : "Ditolak"}',
            ),
            Expanded(
                child: ListView.builder(
              itemCount: data["history_items"].length,
              itemBuilder: (context, index) {
                var ticket = data['history_items'][index];
                return Card(
                  child: Column(
                    children: [
                      Text('nama: ${ticket['ticket']['name']}'),
                      Text('qty: ${ticket['qty']}'),
                      Text('harga : ${ticket['ticket']['price']}'),
                      Text(
                          'total : ${ticket['ticket']['price'] * ticket['qty']}')
                    ],
                  ),
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
