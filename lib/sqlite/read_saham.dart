import 'package:flutter/material.dart';
import 'connection.dart';
import 'models/saham.dart';

class ReadSaham extends StatefulWidget {
  const ReadSaham({super.key});

  @override
  State<ReadSaham> createState() => _ReadSahamState();
}

class _ReadSahamState extends State<ReadSaham> {
  List<Saham> sahamList = [];
  final DatabaseHandler databaseHandler = DatabaseHandler();

  Future<void> _reload() async {
    final list = await databaseHandler.fetchSaham();
    setState(() {
      sahamList = list;
    });
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Saham')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView.builder(
          itemCount: sahamList.length,
          itemBuilder: (context, index) {
            final s = sahamList[index];
            final changeColor = (s.change < 0) ? Colors.red : Colors.green;
            return ListTile(
              title: Text(s.ticker),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Open: ${s.open}  High: ${s.high}  Last: ${s.last}'),
                  const SizedBox(height: 4),
                  Text('${s.change}%', style: TextStyle(color: changeColor)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
