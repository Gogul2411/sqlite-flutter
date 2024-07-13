import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/authentication/model/users.dart';

class DatabaseHelper {
  final databaseName = "auth.db";

  String userTable = '''
    CREATE TABLE users (
      usrId INTEGER PRIMARY KEY AUTOINCREMENT,
      fullName TEXT,
      email TEXT,
      usrName TEXT UNIQUE,
      usrPassword TEXT
    )
  ''';

  String locationsTable = '''
    CREATE TABLE locations (
      id TEXT PRIMARY KEY,
      userId INTEGER,
      latitude REAL,
      longitude REAL,
      timestamp INTEGER
    )
  ''';

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(userTable);
      await db.execute(locationsTable);
    });
  }

  // Function methods

  Future<bool> authenticate(Users usr) async {
    final Database db = await initDB();
    var result = await db.rawQuery(
        "SELECT * FROM users WHERE usrName = '${usr.usrName}' AND usrPassword = '${usr.password}' ");
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<int> createUser(Users usr) async {
    final Database db = await initDB();
    return db.insert("users", usr.toMap());
  }

  Future<Users?> getUser(String usrName) async {
    final Database db = await initDB();
    var res =
        await db.query("users", where: "usrName = ?", whereArgs: [usrName]);
    return res.isNotEmpty ? Users.fromMap(res.first) : null;
  }

  storeLocationInDatabase(
      int userId, double latitude, double longitude, int timestamp) async {
    final Database db = await initDB();
    await db.insert(
      "locations",
      {
        'userId': userId,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,
        'id': timestamp.toString(), // Use timestamp as the marker ID
      },
    );
  }

  Future<List<Map<String, dynamic>>> getUserLocations(int userId) async {
    final Database db = await initDB();
    return db.query("locations", where: "userId = ?", whereArgs: [userId]);
  }
}
