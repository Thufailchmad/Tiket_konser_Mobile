import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:konser_tiket/ipAddress.dart';
import 'package:konser_tiket/pages/auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var bookedTicket;

  @override
  void initState() {
    super.initState();
    fetchBookedTicket();
  }

  Future<void> fetchBookedTicket() async {
    final pref = await SharedPreferences.getInstance();
    String? token = pref.getString("token");

    final Map<String, String> header = {
      'User-Agent': 'android',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse(ipAddress + "api/booked-ticket"),
      headers: header,
    );

    print(response.statusCode);
    if (response.statusCode == 202) {
      final result = jsonDecode(response.body);
      print(result);
      setState(() {
        bookedTicket = result['data'];
      });
    } else {
      print("Gagal mengambil data tiket");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo-tiket2.png', height: 80),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFF0027B4)),
            onPressed: () async {
              final pref = await SharedPreferences.getInstance();
              String? token = pref.getString("token");
              final Map<String, String> header = {
                'User-Agent': 'android',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              };
              final req = await http.delete(
                Uri.parse(ipAddress + "api/logout"),
                headers: header,
              );
              if (req.statusCode == 202) {
                pref.remove("token");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: bookedTicket == null
            ? Center(child: CircularProgressIndicator())
            : bookedTicket.isEmpty
                ? Center(child: Text("Belum ada tiket yang dibooking."))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: bookedTicket.length,
                          itemBuilder: (context, index) => Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      ipAddress +
                                          bookedTicket[index]['ticket']
                                              ['images'],
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${bookedTicket[index]['ticket']['name']}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.confirmation_num,
                                          size: 20, color: Colors.blueAccent),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Kode Tiket: ${bookedTicket[index]['code']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
