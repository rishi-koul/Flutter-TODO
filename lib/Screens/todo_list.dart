import 'dart:async';
import 'package:flutter/material.dart';
import 'package:todo_list/Models/todo.dart';
import 'package:todo_list/Screens/player_search.dart';
import 'package:todo_list/Utils/database_helper.dart';
import 'package:todo_list/Screens/todo_detail.dart';
import 'package:sqflite/sqflite.dart';

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TodoListState();
  }
}

class TodoListState extends State<TodoList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Todo> todoList;
  int count = 0;
  int tempCount = 0;
  TextEditingController controller = new TextEditingController();
  List<Todo> tempTodoList;

  @override
  Widget build(BuildContext context) {
    if (todoList == null) {
      todoList = List<Todo>();
      updateListView();
    }

    onSearchTextChanged(String text) async {
      print("\n\n\n\n");
      print(controller.text);
      print("\n\n\n\n");

      List<Todo> bekar = [];
      int j = 0;
      for (int i = 0; i < todoList.length; i++) {
        print(this.todoList[i].title);
        if (this.todoList[i].title.startsWith(controller.text)) {
          bekar.add(this.todoList[i]);
          j++;
        }
      }
      print(bekar);
      setState(() {
        this.tempTodoList = bekar;
        this.tempCount = j;
      });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Search Bar Sample'),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Card(
                child: new ListTile(
                  leading: new Icon(Icons.search),
                  title: new TextField(
                    controller: controller,
                    decoration: new InputDecoration(
                        hintText: 'Search', border: InputBorder.none),
                    onChanged: onSearchTextChanged,
                  ),
                  trailing: new IconButton(
                    icon: new Icon(Icons.cancel),
                    onPressed: () {
                      controller.clear();
                      // onSearchTextChanged('');
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: getTodoListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Todo('', '', ''), 'Add Todo');
        },
        tooltip: 'Add Todo',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getTodoListView() {
    if (controller.text == '' || controller.text.isEmpty) {
      this.tempTodoList = this.todoList;
      this.tempCount = count;
    }
    return ListView.builder(
      itemCount: tempCount,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber,
              child: Text(getFirstLetter(this.tempTodoList[position].title),
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(this.tempTodoList[position].title,
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(this.tempTodoList[position].description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onTap: () {
                    _delete(context, tempTodoList[position]);
                    this.tempTodoList = this.todoList;
                  },
                ),
              ],
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              navigateToDetail(this.tempTodoList[position], 'Edit Todo');
              this.tempTodoList = this.todoList;
            },
          ),
        );
      },
    );
  }

  getFirstLetter(String title) {
    return title.substring(0, 2);
  }

  void _delete(BuildContext context, Todo todo) async {
    int result = await databaseHelper.deleteTodo(todo.id);
    if (result != 0) {
      _showSnackBar(context, 'Todo Deleted Successfully');
      updateListView();
      this.tempTodoList = this.todoList;
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Todo todo, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TodoDetail(todo, title);
    }));

    if (result == true) {
      updateListView();
      this.tempTodoList = this.todoList;
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Todo>> todoListFuture = databaseHelper.getTodoList();
      todoListFuture.then((todoList) {
        setState(() {
          this.todoList = todoList;
          this.count = todoList.length;

          this.tempTodoList = this.todoList;
        });
      });
    });
  }
}
