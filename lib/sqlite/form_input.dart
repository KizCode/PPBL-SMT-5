import 'package:flutter/material.dart';
import 'package:ppbl/sqlite/connection.dart';
import 'package:ppbl/sqlite/read_data.dart';

class FormInput extends StatelessWidget{
  final String label;
  final TextEditingController controller;
  DatabaseHandler databaseHandler = DatabaseHandler();

  FormInput({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SQLite Form Input"),
      ),
      body:
      Column( children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: label,
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () async {
                databaseHandler.insertMahasiswa(controller.text)
                    .then((message){
                  final snackBar = SnackBar(content: Text('Data berhasil disimpan'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }).catchError((error){
                  final snackBar = SnackBar(content: Text('Terjadi kesalahan: $error'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                });
              },
              child: const Text("Simpan"),
            )
        ),
        Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: ()  {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReadData()),
                );
              },
              child: const Text("Lihat Data"),
            )
        ),

      ],),
    );

  }
}