import 'dart:async';
import 'package:flutter/material.dart';
import 'package:note_keeper/models/note.dart';
import 'package:note_keeper/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final Note note;
  final String appBarTitle;

  NoteDetail(this.note,this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  Note note;
  String appBarTitle;

  DatabaseHelper databaseHelper = DatabaseHelper();

  var _formKey = GlobalKey<FormState>();

  static var _priorities = ['High', 'Low'];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    // TODO: implement build
    return WillPopScope(
      onWillPop: (){
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(this.appBarTitle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            },
          ), //IconButton
        ), //AppBar
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                //first element
                ListTile(
                  title: DropdownButton(
                      items: _priorities.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      }).toList(),
                      style: textStyle,
                      value: getPriorityAsString(note.priority),
                      onChanged: (valueSelectedByUser) {
                        setState(() {
                          debugPrint('User selected $valueSelectedByUser');
                          updatePriorityAsInt(valueSelectedByUser);
                        });
                      }), //DropdownButton
                ), //ListTile

                //secondElement
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextFormField(
                    controller: titleController,
                    validator: (String value){
                      if(value.isEmpty){
                        return 'Please enter the title';
                      }
                    },
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint("something changed in the title field");
                      updateTitle();
                    },

                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ), //Inputdecoration
                  ), //TextField
                ), //Padding

                //ThirdElement
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextFormField(
                    controller: descriptionController,
                    validator: (String value){
                      if(value.isEmpty){
                        return 'Please enter the description';
                      }
                    },
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint("something changed in the title field");
                      updateDescription();
                    },

                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ), //Inputdecoration
                  ), //TextField
                ), //Padding

                //Fourth Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ), //Text
                          onPressed: () {
                            setState(() {
                              debugPrint("Save button clicked");
                              if(_formKey.currentState.validate()){
                                _save();
                              }
                            });
                          },
                        ), //RaisedButton
                      ), //Expanded

                      Container(
                        width: 5.0,
                      ),

                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ), //Text
                          onPressed: () {
                            setState(() {
                              debugPrint("Delete button clicked");
                              _delete();
                            });
                          },
                        ), //RaisedButton
                      ), //Expanded
                    ],
                  ), //Row
                ), //padding
              ],
            ), //ListView
          ), //padding
        ),//Form
      ) //Scaffold
    ); // WillPopScope
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updatePriorityAsInt(String value){
    switch(value){
      case 'High':
        note.priority = 1;
        break;
      default:
        note.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int value){
    String priority;
    switch(value){
      case 1:
        priority = _priorities[0];
        break;
      default:
        priority = _priorities[1];
    }

    return priority;
  }

  void updateTitle(){
    note.title = titleController.text;
  }

  void updateDescription(){
    note.description = descriptionController.text;
  }

  void _delete() async{

    //delete new note
    if(note.id == null){
      _showAlertDialog('Status', 'No note was deleted');
      return;
    }

    //user is trying to delete old note
    int result = await databaseHelper.deleteNote(note.id);

    if(result != 0){
      _showAlertDialog('Status', 'Note deleted successfully');
    }else{
      _showAlertDialog('Status', 'Problem deleting Note');
    }

  }

  void _save() async{

    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if(note.id != null){
      result = await databaseHelper.updateNote(note);
    }else{
      result = await databaseHelper.insertNote(note);
    }

    if(result != 0){
      _showAlertDialog('Status', 'Note saved successfully');
    }else{
      _showAlertDialog('Status', 'Problem saving Note');
    }

  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );//AlertDialog

    showDialog(
      context:context,
      builder:(_) => alertDialog
    );

  }

}
