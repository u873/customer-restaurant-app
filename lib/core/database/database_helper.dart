import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();

    final path = join(
      dbPath,
      'customer_restaurant.db',
    );

    return openDatabase(
      path,
      version: 4,

      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE cartitems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        menu_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        selected_price REAL NOT NULL,
        order_type TEXT NOT NULL,
        image_url TEXT,
        menu_variation_id INTEGER,
        menu_variation_name TEXT,
        created_at TEXT,
        delivery_price REAL NOT NULL DEFAULT 0,
        take_away_price REAL NOT NULL DEFAULT 0,
        is_deal INTEGER NOT NULL DEFAULT 0,
        selected_choices TEXT,
        deal_items TEXT
      )
    ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {

        if (oldVersion < 3) {
          await db.execute('''
        ALTER TABLE cartitems
        ADD COLUMN delivery_price REAL NOT NULL DEFAULT 0
      ''');

          await db.execute('''
        ALTER TABLE cartitems
        ADD COLUMN take_away_price REAL NOT NULL DEFAULT 0
      ''');
        }

        if (oldVersion < 4) {
          await db.execute('''
        ALTER TABLE cartitems
        ADD COLUMN is_deal INTEGER NOT NULL DEFAULT 0
      ''');
          await db.execute('''
        ALTER TABLE cartitems  ADD COLUMN selected_choices TEXT
      ''');

          await db.execute('''
        ALTER TABLE cartitems ADD COLUMN deal_items TEXT
      ''');
        }
      },
    );
  }
}