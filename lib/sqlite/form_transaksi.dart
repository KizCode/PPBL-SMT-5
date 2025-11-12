import 'package:flutter/material.dart';
import 'connection.dart';
import 'models/saham.dart';

class FormTransaksi extends StatefulWidget {
  final Saham? initial;
  const FormTransaksi({super.key, this.initial});

  @override
  State<FormTransaksi> createState() => _FormTransaksiState();
}

class _FormTransaksiState extends State<FormTransaksi> {
  final DatabaseHandler db = DatabaseHandler();
  List<Saham> sahamList = [];
  Saham? selected;
  int jenis = 0; // 0=beli, 1=jual
  final TextEditingController _jumlahController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await db.fetchSaham();
    setState(() {
      sahamList = list;
      if (list.isNotEmpty) {
        if (widget.initial != null) {
          selected = list.firstWhere(
            (e) => e.tickerid == widget.initial!.tickerid,
            orElse: () => list.first,
          );
        } else {
          selected = list.first;
        }
      } else {
        selected = null;
      }
    });
  }

  Future<void> _submit() async {
    if (selected == null) return;
    final jumlah = int.tryParse(_jumlahController.text.trim()) ?? 0;
    try {
      await db.performTransaksi(
        tickerid: selected!.tickerid!,
        jumlahTransaksi: jumlah,
        jenis: jenis,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transaksi berhasil')));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            DropdownButton<Saham>(
              value: selected,
              isExpanded: true,
              items:
                  sahamList
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text('${s.ticker} (stok: ${s.jumlah})'),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => selected = v),
            ),
            const SizedBox(height: 10),
            DropdownButton<int>(
              value: jenis,
              items: const [
                DropdownMenuItem(value: 0, child: Text('Beli')),
                DropdownMenuItem(value: 1, child: Text('Jual')),
              ],
              onChanged: (v) => setState(() => jenis = v ?? 0),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Jumlah lot',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Proses Transaksi'),
            ),
          ],
        ),
      ),
    );
  }
}
