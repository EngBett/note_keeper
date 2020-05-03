import 'dart:async';
import 'package:flutter/material.dart';
import 'package:note_keeper/models/note.dart';
import 'package:note_keeper/utils/database_helper.dart';
import 'package:note_keeper/screens/note_detail.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget{



  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NoteListState();
  }

}

class NoteListState extends State<NoteList>{

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {

    if(noteList == null){
      noteList = List<Note>();
      updateListView();
    }

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),

      ),//AppBar

      body: getNotesListView(),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          debugPrint('FAButton pressed');
          navigateToDetail(Note('','',2),"Add Note");
        },

        tooltip: 'Add Note',

        child: Icon(Icons.add),

      ),//floating action button

    );//Scaffold
  }

  ListView getNotesListView(){
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position){
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(

            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList[position].priority),
              child: getPriorityIcon(this.noteList[position].priority),
            ),//leading Icon

            title: Text(this.noteList[position].title, style: titleStyle),

            subtitle: Text(this.noteList[position].date),

            trailing: GestureDetector(
              child: Icon(Icons.delete, color: Colors.grey,),
              onTap: (){
                _delete(context,this.noteList[position]);
              },
            ),//GestureDetector


            onTap:(){
              debugPrint("ListTile Tapped");
              navigateToDetail(this.noteList[position] ,"Edit Note");
            }

          ),//ListTile
        );//card
      },
    );//listView builder
  }

  //Return priority color
  Color getPriorityColor(int priority){
    switch(priority){
      case 1:
        return Colors.red;
        break;

      default:
        return Colors.yellow;
        break;
    }
  }

  //Return the priority icon
  Icon getPriorityIcon(int priority){
    switch(priority){
      case 1:
        return Icon(Icons.play_arrow);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
        break;
    }
  }

  //Delete
  void _delete(BuildContext context, Note note) async{
    int result = await databaseHelper.deleteNote(note.id);
    if(result != 0){
      _showSnackBar(context, 'Note deleted successfully');

      //update the list
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String s) {
     final snackBar = SnackBar(content:Text(s));
     Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note,String title) async{
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context){
      return NoteDetail(note, title);
    }));//Navigator

    if(result == true){
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database){

      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList){
        setState((){
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });

    });
  }



}

