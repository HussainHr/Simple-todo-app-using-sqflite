import 'package:sqflite/sqflite.dart ' as sql;
import 'package:flutter/foundation.dart';

class SQLHelper {
  /// this method for creating tables
  static Future<void> creatTables(sql.Database database) async {
    await database.execute('''CREATE TABLE items(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      desc TEXT,
      creatDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      ''');
  }

  /// this db method for open database
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'hr.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await creatTables(database);
      },
    );
  }

  ///this is for insert data method
  static Future<int> creatItem(String title, String? desc) async {
    final db = await SQLHelper.db();

    final data = {'title': title, 'desc': desc};
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  //this mehtod for get item from our database
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: 'id');
  }

  // this method for get single item from our database
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: 'id =?', whereArgs: [id], limit: 1);
  }

  // this method for update item on our database
  static Future<int> updateItem(int id, String title, String? desc) async {
    final db = await SQLHelper.db();

    final data = {
      'title': title,
      'desc': desc,
      'creatDate': DateTime.now().toString()
    };

    final result =
        await db.update('items', data, where: 'id=?', whereArgs: [id]);
    return result;
  }

  // this method for delete item from our database

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('items', where: 'id=?', whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
