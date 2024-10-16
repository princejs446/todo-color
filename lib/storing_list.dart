
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<Map<String, dynamic>> _todoItems = [];
  Color _selectedColor = Colors.blue;
  List<Color> _colorList = [
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.green,
    Colors.yellowAccent,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    loadTodoItems();
  }

  // Load to-do items from shared preferences
  Future<void> loadTodoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? tasks = prefs.getStringList('todoItems');
    List<String>? colors = prefs.getStringList('todoColors');

    if (tasks != null && colors != null) {
      setState(() {
        _todoItems = List.generate(tasks.length, (index) {
          return {
            'task': tasks[index],
            'color': Color(int.parse(colors[index])),
          };
        });
      });
    }
  }

  // Save to-do items in shared preferences
  Future<void> saveTodoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasks = _todoItems.map((item) => item['task'] as String).toList();
    List<String> colors = _todoItems
        .map((item) => (item['color'] as Color).value.toString())
        .toList();
    prefs.setStringList('todoItems', tasks);
    prefs.setStringList('todoColors', colors);
  }

  // Add a new to-do item
  void _addTodoItem(String task) {
    if (task.isNotEmpty) {
      setState(() {
        _todoItems.add({'task': task, 'color': _selectedColor});
      });
      saveTodoItems();
    }
  }

  // Remove a to-do item
  void _removeTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
    saveTodoItems();
  }

  // Prompt to add a new task
  void promptAddTodoItem() {
    String newTask = "";

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 500,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'New Task',
                ),
                autofocus: true,
                onChanged: (val) {
                  newTask = val;
                },
              ),
              SizedBox(height: 20),
              Text('Pick a task color:'),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colorList.length,
                  separatorBuilder: (context, index) => SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = _colorList[index];
                        });
                      },
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: _colorList[index],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                child: Text('Add'),
                onPressed: () {
                  if (newTask.isNotEmpty) {
                    _addTodoItem(newTask);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
      ),
      body: ListView.builder(
        itemCount: _todoItems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: _todoItems[index]['color'],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(_todoItems[index]['task']),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removeTodoItem(index),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: promptAddTodoItem,
        tooltip: 'Add Task',
        child: Icon(Icons.add),
      ),
    );
  }
}