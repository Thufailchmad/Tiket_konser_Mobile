import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:konser_tiket/ipAddress.dart';
import 'package:konser_tiket/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  late var data = [];
  late int total = 0;

  @override
  void initState() {
    // TODO: implement initState
    getData();
  }

  Future<void> pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
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

      total = data.fold(0, (sum, ticket) {
        num qty = ticket["qty"];
        num price = ticket["ticket"]["price"];
        return sum + (qty * price).toInt();
      });
    } else {
      throw Exception("Gagal mendapatkan data");
    }
  }

  void pembayaran() async {
    final pref = await SharedPreferences.getInstance();
    String? token = pref.getString("token");
    final Map<String, String> header = {
      'User-Agent': 'android',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final req = await http.post(Uri.parse(ipAddress + "api/history"),
        headers: header, body: jsonEncode(data));
    final res = jsonDecode(req.body);
    if (req.statusCode == 201) {
      print(res);
      final req2 = await http.MultipartRequest(
        'POST',
        Uri.parse(ipAddress + "api/history/${res["data"]["historyId"]}"),
      );
      req2.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'User-Agent': 'android',
      });

      req2.files.add(await http.MultipartFile.fromPath('file', _image!.path,
          filename: _image!.path.split('/').last));
      var res2 = await req2.send();
      if (res2.statusCode == 202) {
        final resStr = await res2.stream.bytesToString();
        print("upload : ${resStr}");
      } else {
        throw Exception("Gagal upload file");
      }
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
                child: Text('kembali')),
            Text('${total}'),
            _image != null
                ? Image.file(
                    _image!,
                    height: 300,
                    width: 300,
                  )
                : const Text('g da gambar'),
            ElevatedButton(onPressed: pickImage, child: Text('pilih gambar')),
            ElevatedButton(
                onPressed: pembayaran, child: Text('konfirmasi pembayaran'))
          ],
        ),
      ),
    );
  }
}
