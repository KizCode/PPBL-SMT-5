import 'package:flutter/material.dart';
import 'connection.dart';
import 'models/saham.dart';
import 'form_edit_saham.dart';
import 'form_transaksi.dart';

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
                  Text('Jumlah: ${s.jumlah}'),
                  const SizedBox(height: 4),
                  Text('${s.change}%', style: TextStyle(color: changeColor)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormEditSaham(saham: s),
                        ),
                      );
                      if (result == true) _reload();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      try {
                        await databaseHandler.hapusSaham(s.tickerid!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data saham berhasil dihapus'),
                          ),
                        );
                        _reload();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal hapus: $e')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    onPressed: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormTransaksi(initial: s),
                        ),
                      );
                      if (res == true) _reload();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
