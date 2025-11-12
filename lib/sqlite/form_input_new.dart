import 'package:flutter/material.dart';
import 'connection.dart';
import 'models/saham.dart';
import 'read_saham.dart';

class FormInputSaham extends StatefulWidget {
  const FormInputSaham({super.key});

  @override
  State<FormInputSaham> createState() => _FormInputSahamState();
}

class _FormInputSahamState extends State<FormInputSaham> {
  final DatabaseHandler databaseHandler = DatabaseHandler();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tickerController = TextEditingController();
  final TextEditingController _openController = TextEditingController();
  final TextEditingController _highController = TextEditingController();
  final TextEditingController _lastController = TextEditingController();
  final TextEditingController _changeController = TextEditingController();

  @override
  void dispose() {
    _tickerController.dispose();
    _openController.dispose();
    _highController.dispose();
    _lastController.dispose();
    _changeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ticker = _tickerController.text.trim();
    final open = int.tryParse(_openController.text.trim()) ?? 0;
    final high = int.tryParse(_highController.text.trim()) ?? 0;
    final last = int.tryParse(_lastController.text.trim()) ?? 0;
    final change = double.tryParse(_changeController.text.trim()) ?? 0.0;

    final s = Saham(
      ticker: ticker,
      open: open,
      high: high,
      last: last,
      change: change,
    );

    try {
      await databaseHandler.insertSaham(s);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saham berhasil disimpan')),
      );
      _tickerController.clear();
      _openController.clear();
      _highController.clear();
      _lastController.clear();
      _changeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Form Input Saham")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tickerController,
                decoration: const InputDecoration(
                  labelText: 'Ticker (kode saham)',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Ticker wajib diisi'
                            : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _openController,
                decoration: const InputDecoration(
                  labelText: 'Open (harga pembukaan)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Open wajib diisi'
                            : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _highController,
                decoration: const InputDecoration(
                  labelText: 'High (harga tertinggi)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'High wajib diisi'
                            : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lastController,
                decoration: const InputDecoration(
                  labelText: 'Last (harga terbaru)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Last wajib diisi'
                            : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _changeController,
                decoration: const InputDecoration(
                  labelText: 'Change (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Change wajib diisi'
                            : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Simpan Saham'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReadSaham(),
                        ),
                      );
                    },
                    child: const Text('Lihat Daftar Saham'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
