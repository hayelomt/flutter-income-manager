import 'package:income_tracker/models/payment.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static late Database database;

  static open() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'payment.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS payments(id INTEGER PRIMARY KEY AUTOINCREMENT, client TEXT, amount REAL, date TEXT, status TEXT)',
        );
      },
      version: 1,
    );
  }

  static insert(Payment payment) async {
    // print(payment.toMap());
    return database.insert(
      'payments',
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Payment>> payments() async {
    final List<Map<String, dynamic>> maps = await database
        .query('payments', where: 'status = ?', whereArgs: ['pending']);

    return List.generate(maps.length, (index) => Payment.fromMap(maps[index]));
  }

  static Future<int> markComplete(int id) async {
    return database.update('payments', {'status': 'payed'},
        where: 'id = ?', whereArgs: [id]);
  }
}
