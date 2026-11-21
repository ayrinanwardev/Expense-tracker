import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/expense.dart';

class ExpenseDatabase {
  ExpenseDatabase._();
  static final ExpenseDatabase instance = ExpenseDatabase._();

  static const _databaseName = 'expense_tracker.db';
  static const _tableName = 'expenses';
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      p.join(dbPath, _databaseName),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL CHECK(amount > 0)
          )
        ''');
      },
    );
    return _database!;
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return db.insert(_tableName, expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final rows = await db.query(_tableName, orderBy: 'id DESC');
    return rows.map(Expense.fromMap).toList();
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM $_tableName',
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
