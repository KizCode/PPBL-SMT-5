import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'mahasiswa.dart';
import 'models/saham.dart';

Future<Database> openMyDatabase() async {
  final databaseName = "myDatabase.db";
  // bump version to 3 to add saham table
  final databaseVersion = 3;

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
            $colChange REAL
          )
          ''');
    },
  );
  return database;
}

class DatabaseHandler {
  Future<Database> initializeDB() async {
    return openMyDatabase();
  }

  Future<List<Mahasiswa>> fetchMahasiswa() async {
    List<Mahasiswa> daftarMahasiswa = [];
    final db = await openMyDatabase();

    daftarMahasiswa = await db.query('mahasiswa').then((maps) {
      return List.generate(maps.length, (i) {
        return Mahasiswa(
          id: maps[i]['_id'] as int,
          name: maps[i]['name'] as String,
          age: maps[i]['age'] as int,
        );
      });
    });

    return daftarMahasiswa;
  }

  Future<void> insertMahasiswa(String name) async {
    final db = await openMyDatabase();
    await db.insert('mahasiswa', {'name': name, 'age': 25});
  }

  Future<void> hapusMahasiswa(int id) async {
    final db = await openMyDatabase();
    await db.delete('mahasiswa', where: '_id = ?', whereArgs: [id]);
  }

  // --- Saham related methods ---
  Future<List<Saham>> fetchSaham() async {
    final db = await openMyDatabase();
    final List<Map<String, dynamic>> maps = await db.query('saham');
    return List.generate(maps.length, (i) {
      return Saham.fromMap(maps[i]);
    });
  }

  Future<int> insertSaham(Saham s) async {
    final db = await openMyDatabase();
    return await db.insert('saham', s.toMap());
  }

  Future<void> insertSahamList(List<Saham> list) async {
    final db = await openMyDatabase();
    await db.transaction((txn) async {
      for (var s in list) {
        await txn.insert('saham', s.toMap());
      }
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
        Saham(ticker: 'TLKM', open: 3380, high: 3500, last: 3490, change: 2.05),
        Saham(ticker: 'AMMN', open: 6750, high: 6750, last: 6500, change: -3.7),
        Saham(ticker: 'BREN', open: 4500, high: 4610, last: 4580, change: 1.78),
        Saham(ticker: 'CUAN', open: 5200, high: 5525, last: 5400, change: 3.85),
      ];
      await insertSahamList(samples);
    }
  }
}
