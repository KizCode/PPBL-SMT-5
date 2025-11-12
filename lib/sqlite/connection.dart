import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'mahasiswa.dart';
import 'models/saham.dart';
import 'models/transaksi.dart';

Future<Database> openMyDatabase() async {
  final databaseName = "myDatabase.db";
  // bump version to 4 to add jumlah to saham and transaksi table
  final databaseVersion = 4;

  final table = 'mahasiswa';

  final columnId = '_id';
  final columnName = 'name';
  final columnAge = 'age';

  final tableDosen = 'dosen';

  final dosenId = '_id';
  final dosenName = 'name';
  final dosenNim = 'nim';

  // saham table
  final tableSaham = 'saham';
  final colTickerId = 'tickerid';
  final colTicker = 'ticker';
  final colOpen = 'open';
  final colHigh = 'high';
  final colLast = 'last';
  final colChange = 'change';
  final colJumlah = 'jumlah';

  // transaksi table
  final tableTransaksi = 'transaksi';
  final colTransaksiId = 'transaksiid';
  final colTransaksiTickerId = 'tickerid';
  final colJumlahTransaksi = 'jumlah_transaksi';
  final colJenisTransaksi = 'jenis_transaksi';

  final dbPath = await getDatabasesPath();
  final path = join(dbPath, databaseName);
  final database = await openDatabase(
    path,
    version: databaseVersion,
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // Perform the migration from version 1 to version 2: add dosen
        await db.execute('''
          CREATE TABLE $tableDosen (
            $dosenId INTEGER PRIMARY KEY,
            $dosenName TEXT NOT NULL,
            $dosenNim INTEGER NOT NULL
          )
          ''');
      }
      // Add saham table in version 3
      if (oldVersion < 3) {
        await db.execute('''
          CREATE TABLE $tableSaham (
            $colTickerId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colTicker TEXT NOT NULL,
            $colOpen INTEGER,
            $colHigh INTEGER,
            $colLast INTEGER,
            $colChange REAL
          )
          ''');
      }
      // Add jumlah column to saham and transaksi table in version 4
      if (oldVersion < 4) {
        await db.execute(
          'ALTER TABLE $tableSaham ADD COLUMN $colJumlah INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute('''
          CREATE TABLE $tableTransaksi (
            $colTransaksiId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colTransaksiTickerId INTEGER NOT NULL,
            $colJumlahTransaksi INTEGER NOT NULL,
            $colJenisTransaksi INTEGER NOT NULL,
            FOREIGN KEY ($colTransaksiTickerId) REFERENCES $tableSaham ($colTickerId)
          )
          ''');
      }
    },
    onCreate: (db, version) async {
      // Create tables here
      await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnAge INTEGER NOT NULL
          )
          ''');

      await db.execute('''
          CREATE TABLE $tableDosen (
            $dosenId INTEGER PRIMARY KEY,
            $dosenName TEXT NOT NULL,
            $dosenNim INTEGER NOT NULL
          )
          ''');

      // Create saham table
      await db.execute('''
          CREATE TABLE $tableSaham (
            $colTickerId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colTicker TEXT NOT NULL,
            $colOpen INTEGER,
            $colHigh INTEGER,
            $colLast INTEGER,
            $colChange REAL,
            $colJumlah INTEGER NOT NULL DEFAULT 0
          )
          ''');

      // Create transaksi table with foreign key
      await db.execute('''
          CREATE TABLE $tableTransaksi (
            $colTransaksiId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colTransaksiTickerId INTEGER NOT NULL,
            $colJumlahTransaksi INTEGER NOT NULL,
            $colJenisTransaksi INTEGER NOT NULL,
            FOREIGN KEY ($colTransaksiTickerId) REFERENCES $tableSaham ($colTickerId)
          )
          ''');
    },
  );
  return database;
}

class DatabaseHandler {
  Future<Database> initializeDB() async => openMyDatabase();

  // Mahasiswa methods
  Future<List<Mahasiswa>> fetchMahasiswa() async {
    final db = await openMyDatabase();
    final maps = await db.query('mahasiswa');
    return List.generate(maps.length, (i) {
      return Mahasiswa(
        id: maps[i]['_id'] as int,
        name: maps[i]['name'] as String,
        age: maps[i]['age'] as int,
      );
    });
  }

  Future<void> insertMahasiswa(String name) async {
    final db = await openMyDatabase();
    await db.transaction((txn) async {
      await txn.insert('mahasiswa', {'name': name, 'age': 25});
    });
  }

  Future<void> hapusMahasiswa(int id) async {
    final db = await openMyDatabase();
    await db.transaction((txn) async {
      await txn.delete('mahasiswa', where: '_id = ?', whereArgs: [id]);
    });
  }

  // --- Saham related methods ---
  Future<List<Saham>> fetchSaham() async {
    final db = await openMyDatabase();
    final List<Map<String, dynamic>> maps = await db.query('saham');
    return List.generate(maps.length, (i) => Saham.fromMap(maps[i]));
  }

  Future<int> insertSaham(Saham s) async {
    final db = await openMyDatabase();
    return await db.transaction(
      (txn) async => await txn.insert('saham', s.toMap()),
    );
  }

  Future<void> insertSahamList(List<Saham> list) async {
    final db = await openMyDatabase();
    await db.transaction((txn) async {
      for (var s in list) await txn.insert('saham', s.toMap());
    });
  }

  /// Seed sample saham data if table is empty
  Future<void> seedSahamData() async {
    final db = await openMyDatabase();
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM saham'),
    );
    if (count == 0) {
      final samples = [
        Saham(
          ticker: 'TLKM',
          open: 3380,
          high: 3500,
          last: 3490,
          change: 2.05,
          jumlah: 100,
        ),
        Saham(
          ticker: 'AMMN',
          open: 6750,
          high: 6750,
          last: 6500,
          change: -3.7,
          jumlah: 50,
        ),
        Saham(
          ticker: 'BREN',
          open: 4500,
          high: 4610,
          last: 4580,
          change: 1.78,
          jumlah: 75,
        ),
        Saham(
          ticker: 'CUAN',
          open: 5200,
          high: 5525,
          last: 5400,
          change: 3.85,
          jumlah: 120,
        ),
      ];
      await insertSahamList(samples);
    }
  }

  // --- Transaksi related methods ---
  Future<List<Transaksi>> fetchTransaksi() async {
    final db = await openMyDatabase();
    final List<Map<String, dynamic>> maps = await db.query('transaksi');
    return List.generate(maps.length, (i) => Transaksi.fromMap(maps[i]));
  }

  Future<int> insertTransaksi(Transaksi t) async {
    final db = await openMyDatabase();
    return await db.transaction(
      (txn) async => await txn.insert('transaksi', t.toMap()),
    );
  }

  Future<void> hapusTransaksi(int transaksiid) async {
    final db = await openMyDatabase();
    await db.transaction((txn) async {
      await txn.delete(
        'transaksi',
        where: 'transaksiid = ?',
        whereArgs: [transaksiid],
      );
    });
  }

  Future<void> updateTransaksi(Transaksi t) async {
    final db = await openMyDatabase();
    await db.transaction((txn) async {
      await txn.update(
        'transaksi',
        t.toMap(),
        where: 'transaksiid = ?',
        whereArgs: [t.transaksiid],
      );
    });
  }

  // --- Saham update/delete using transactions ---
  Future<void> updateSaham(Saham s) async {
    final db = await openMyDatabase();
    await db.transaction((txn) async {
      await txn.update(
        'saham',
        s.toMap(),
        where: 'tickerid = ?',
        whereArgs: [s.tickerid],
      );
    });
  }

  Future<void> hapusSaham(int tickerid) async {
    final db = await openMyDatabase();
    await db.transaction((txn) async {
      await txn.delete('saham', where: 'tickerid = ?', whereArgs: [tickerid]);
    });
  }

  /// Perform a transaksi and update saham jumlah atomically.
  /// Conventions:
  /// jenis: 0 = beli  -> increases stok (jumlah += jumlahTransaksi)
  ///        1 = jual  -> decreases stok (jumlah -= jumlahTransaksi)
  Future<int> performTransaksi({
    required int tickerid,
    required int jumlahTransaksi,
    required int jenis,
  }) async {
    final db = await openMyDatabase();
    return await db.transaction((txn) async {
      // read current saham
      final rows = await txn.query(
        'saham',
        where: 'tickerid = ?',
        whereArgs: [tickerid],
      );
      if (rows.isEmpty) throw Exception('Saham tidak ditemukan');
      final current = rows.first;
      final currentJumlah = (current['jumlah'] as int?) ?? 0;

      int newJumlah;
      if (jenis == 0) {
        // beli -> increase stok
        newJumlah = currentJumlah + jumlahTransaksi;
      } else if (jenis == 1) {
        // jual -> decrease stok
        newJumlah = currentJumlah - jumlahTransaksi;
        if (newJumlah < 0) throw Exception('Stok tidak cukup');
      } else {
        throw Exception('Jenis transaksi tidak valid');
      }

      // insert transaksi record
      final transaksiMap = {
        'tickerid': tickerid,
        'jumlah_transaksi': jumlahTransaksi,
        'jenis_transaksi': jenis,
      };
      final id = await txn.insert('transaksi', transaksiMap);

      // update saham jumlah
      await txn.update(
        'saham',
        {'jumlah': newJumlah},
        where: 'tickerid = ?',
        whereArgs: [tickerid],
      );

      return id;
    });
  }
}
