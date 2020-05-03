import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:note_keeper/models/note.dart';

class DatabaseHelper{

  static DatabaseHelper _databaseHelper; //Singleton DatabaseHelper
  static Database _database; //singleton Database

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance(); //Named constructor to create instance of Databasehelper


  factory DatabaseHelper(){
    if(_databaseHelper == null){
      _databaseHelper = DatabaseHelper._createInstance(); //This is executed only once, singleton object
    }

    return _databaseHelper;
  }

  Future<Database> get database async{
    if(_database == null){
      _database = await initializeDatabase();
    }

    return _database;
  }

  Future<Database> initializeDatabase() async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);

    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async{
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }


  //fetch operation
  Future<List<Map<String, dynamic>>> getNoteMapList() async{
    Database db = await this.database;
    
    //var result = await db.rawQuery('SELECT * FROM $noteTable ORDER BY $colPriority ASC');
    var result = await db.query(noteTable,orderBy: '$colPriority ASC');

    return result;
  }

  //insert operation
  Future<int> insertNote(Note note) async{
    Database db = await this.database;

    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  //Update operation
  Future<int> updateNote(Note note) async{
    Database db = await this.database;

    var result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);

    return result;
  }

  //delete operation
  Future<int> deleteNote(int id) async{
    Database db = await this.database;

    var result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');

    return result;
  }

  //number of note objects in the database
  Future<int> getCount()async{
    Database db = await this.database;
    
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);

    return result;
  }

  //Get the 'Map List' and convert to 'Note list'
  Future<List<Note>> getNoteList() async{

    var noteMapList = await getNoteMapList(); //Get 'Map List' from database
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();
    for(int i = 0; i < count; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;

  }

}