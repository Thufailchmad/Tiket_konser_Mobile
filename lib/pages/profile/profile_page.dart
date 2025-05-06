import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              child: Image.asset('assets/logo-tiket2.png', height: 80),
            ),
          ],
        ),
        centerTitle: false, 
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFF0027B4)),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Center( 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/icon.png'),
              ),
              const SizedBox(height: 20),
              Text(
                'Tasya Nur Putri W',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('tasya nur putri 8@gmail.com', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Text('Nama: Tasya Nur Putri W', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Email: tasyanurputri8@gmail.com', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Domisili: Jawa Timur', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Nomor HP: 0812345678911', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}