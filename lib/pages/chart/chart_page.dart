import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:konser_tiket/ipAddress.dart';
import 'package:konser_tiket/main.dart';
import 'package:konser_tiket/pages/payment/payment_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
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
        await http.get(Uri.parse(ipAddress + "api/chart"), headers: header);
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
            ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PaymentPage()),
                    ),
                child: Text('data')),
          ],
        ),
      ),
    );
  }
}
