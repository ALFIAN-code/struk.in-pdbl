import 'package:flutter/material.dart';

class SplitPage extends StatefulWidget {
  const SplitPage({super.key});

  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('apa'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('JOHOR BAHRU RESTORANT'),
              Text('Tagihan dibuat: 27/10/1019 13:00'),
              SizedBox(
                height: 10,
              ),
            ],
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber,
            ),
            title: Text('Total tagihan Raihan'),
            subtitle: Text('IDR 29.000'),
          ),
        ],
      ),
    );
  }
}