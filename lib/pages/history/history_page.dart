import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:konser_tiket/ipAddress.dart';
import 'package:konser_tiket/pages/history/history_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {
  late var data = [];

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
    final req =
        await http.get(Uri.parse(ipAddress + "api/history"), headers: header);
    final res = jsonDecode(req.body);
    if (req.statusCode == 202) {
      print(res);
      setState(() {
        data = res["data"];
      });
      print(data);
    } else {
      throw Exception("Gagal mendapatkan data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/logo-tiket2.png',
              height: 80,
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart),
              color: Color(0xFF0027B4),
              onPressed: () {},
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Order',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final order = data[index];

                  return Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HistoryDetailPage(id: order['id']),
                            )),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order['created_at']!,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text('${order['total']!}',
                                  style: TextStyle(fontSize: 14)),
                              SizedBox(height: 4),
                              Text(
                                  'Status: ${order['status'] == 0 ? "Diproses" : order['status'] == 1 ? "Diterima" : "Ditolak"}',
                                  style: TextStyle(fontSize: 12)),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
