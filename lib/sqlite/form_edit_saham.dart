import 'package:flutter/material.dart';
import 'connection.dart';
import 'models/saham.dart';

class FormEditSaham extends StatefulWidget {
  final Saham saham;
  const FormEditSaham({super.key, required this.saham});

  @override
  State<FormEditSaham> createState() => _FormEditSahamState();
}

class _FormEditSahamState extends State<FormEditSaham> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tickerController;
  late TextEditingController _openController;
  late TextEditingController _highController;
  late TextEditingController _lastController;
  late TextEditingController _changeController;
  late TextEditingController _jumlahController;
  final DatabaseHandler db = DatabaseHandler();

  @override
  void initState() {
    super.initState();
    _tickerController = TextEditingController(text: widget.saham.ticker);
    _openController = TextEditingController(text: widget.saham.open.toString());
    _highController = TextEditingController(text: widget.saham.high.toString());
    _lastController = TextEditingController(text: widget.saham.last.toString());
    _changeController = TextEditingController(
      text: widget.saham.change.toString(),
    );
    _jumlahController = TextEditingController(
      text: widget.saham.jumlah.toString(),
    );
  }

  @override
  void dispose() {
    _tickerController.dispose();
    _openController.dispose();
    _highController.dispose();
    _lastController.dispose();
    _changeController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final updated = Saham(
      tickerid: widget.saham.tickerid,
      ticker: _tickerController.text.trim(),
      open: int.tryParse(_openController.text.trim()) ?? 0,
      high: int.tryParse(_highController.text.trim()) ?? 0,
      last: int.tryParse(_lastController.text.trim()) ?? 0,
      change: double.tryParse(_changeController.text.trim()) ?? 0.0,
      jumlah: int.tryParse(_jumlahController.text.trim()) ?? 0,
    );

    try {
      await db.updateSaham(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saham berhasil diubah')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Saham')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tickerController,
                decoration: const InputDecoration(
                  labelText: 'Ticker',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Ticker wajib diisi'
                            : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _openController,
                decoration: const InputDecoration(
                  labelText: 'Open',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Open wajib diisi'
                            : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _highController,
                decoration: const InputDecoration(
                  labelText: 'High',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'High wajib diisi'
                            : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastController,
                decoration: const InputDecoration(
                  labelText: 'Last',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Last wajib diisi'
                            : null,
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 8),
              TextFormField(
                controller: _jumlahController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (stok)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Jumlah wajib diisi'
                            : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _save, child: const Text('Update')),
            ],
          ),
        ),
      ),
    );
  }
}
