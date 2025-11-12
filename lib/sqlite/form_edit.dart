import 'package:flutter/material.dart';
import 'package:ppbl/sqlite/connection.dart';
import 'package:ppbl/sqlite/mahasiswa.dart';
import 'package:ppbl/sqlite/read_data.dart';

class FormEdit extends StatefulWidget{
  final Mahasiswa mahasiswa;

  const FormEdit({super.key, required this.mahasiswa});

  @override
  State<FormEdit> createState() => _EditDataState(mahasiswa);
}

class _EditDataState extends State<FormEdit>{
  final Mahasiswa mahasiswa;

  _EditDataState(this.mahasiswa);

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  @override
  void initState(){
    super.initState();
    nameController.text = mahasiswa.name;
    ageController.text = mahasiswa.age.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SQLite Form Edit"),
      ),
      body:
           Column(
               children:[
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: TextField(
                     controller: nameController,
                     decoration: InputDecoration(
                       border: OutlineInputBorder(),
                       labelText: "Nama",
                     ),
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: TextField(
                     controller: ageController,
                     decoration: InputDecoration(
                       border: OutlineInputBorder(),
                       labelText: "Umur",
                     ),
                   ),
                 ),
                 Padding(
                     padding: const EdgeInsets.all(10.0),
                     child: ElevatedButton(
                       onPressed: () async {
                         final db = await openMyDatabase();
                         await db.update(
                           'mahasiswa',
                           {
                             'name': nameController.text,
                             'age': ageController.text,
                           },
                           where: '_id = ?',
                           whereArgs: [mahasiswa.id],
                         ).then((message){
                           final snackBar = SnackBar(content: Text('Data berhasil diubah'));
                           ScaffoldMessenger.of(context).showSnackBar(snackBar);

                         }).catchError((error){
                           final snackBar = SnackBar(content: Text('Terjadi kesalahan: $error'));
                           ScaffoldMessenger.of(context).showSnackBar(snackBar);
                         });
                         },
                       child: const Text("Update"),
                     )
                 ),
               ]
           ),
    );
  }
}