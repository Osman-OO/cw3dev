import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatefulWidget {
  const TaskManagerApp({super.key});

  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: TaskListScreen(onThemeToggle: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}

class Task {
  String id;
  String name;
  bool isCompleted;
  String priority;

  Task({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.priority = 'Medium',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted,
      'priority': priority,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      isCompleted: json['isCompleted'] ?? false,
      priority: json['priority'] ?? 'Medium',
    );
  }
}

class TaskListScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const TaskListScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  final TextEditingController taskController = TextEditingController();
  String selectedPriority = 'Medium';
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      setState(() {
        tasks = decoded.map((item) => Task.fromJson(item)).toList();
        sortTasksByPriority();
      });
    }
  }

  Future<void> saveTasks() async {
    final String tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  void sortTasksByPriority() {
    const priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
    tasks.sort((a, b) {
      int priorityCompare = (priorityOrder[a.priority] ?? 1).compareTo(
        priorityOrder[b.priority] ?? 1,
      );
      if (priorityCompare != 0) return priorityCompare;
      return tasks.indexOf(a).compareTo(tasks.indexOf(b));
    });
  }

  void addTask() {
    if (taskController.text.isEmpty) return;

    setState(() {
      tasks.add(
        Task(
          id: DateTime.now().toString(),
          name: taskController.text,
          priority: selectedPriority,
        ),
      );
      sortTasksByPriority();
    });
    saveTasks();
    taskController.clear();
    selectedPriority = 'Medium';
  }

  void toggleTaskCompletion(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  void updateTaskPriority(int index, String newPriority) {
    setState(() {
      tasks[index].priority = newPriority;
      sortTasksByPriority();
    });
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: taskController,
                        decoration: InputDecoration(
                          hintText: 'Enter task name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => addTask(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: selectedPriority,
                      items: ['Low', 'Medium', 'High']
                          .map(
                            (priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(priority),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPriority = value ?? 'Medium';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: addTask,
                    child: const Text('Add Task'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      'No tasks yet. Add one to get started!',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskTile(
                        task: task,
                        onToggle: () => toggleTaskCompletion(index),
                        onDelete: () => deleteTask(index),
                        onPriorityChange: (newPriority) =>
                            updateTaskPriority(index, newPriority),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }
}

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Function(String) onPriorityChange;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onPriorityChange,
  });

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          task.name,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: getPriorityColor(task.priority).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<String>(
                value: task.priority,
                underline: const SizedBox(),
                items: ['Low', 'Medium', 'High']
                    .map(
                      (priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(
                          priority,
                          style: TextStyle(
                            color: getPriorityColor(priority),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    onPriorityChange(value);
                  }
                },
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
