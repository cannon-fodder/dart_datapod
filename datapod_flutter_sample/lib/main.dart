import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logging/logging.dart';
import 'datapod_init.dart';
import 'todo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Load configuration from assets
  final dbContent = await rootBundle.loadString('assets/databases.yaml');
  final connContent = await rootBundle.loadString('assets/connections.yaml');

  // Initialize Datapod
  final context = await DatapodInitializer.initialize(
    databasesYamlContent: dbContent,
    connectionsYamlContent: connContent,
  );

  // Initialize Schema (for demo purposes)
  await context.sampleDb.schemaManager.initializeSchema();

  runApp(MyApp(context: context));
}

class MyApp extends StatelessWidget {
  final DatapodContext context;

  const MyApp({super.key, required this.context});

  @override
  Widget build(BuildContext buildContext) {
    return MaterialApp(
      title: 'Datapod Flutter Sample',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: TodoListScreen(context: context),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  final DatapodContext context;

  const TodoListScreen({super.key, required this.context});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<List<Todo>> _todosFuture;

  @override
  void initState() {
    super.initState();
    _refreshTodos();
  }

  void _refreshTodos() {
    setState(() {
      _todosFuture = widget.context.todoRepository.findAll();
    });
  }

  Future<void> _addTodo(String title) async {
    final todo = Todo()..title = title;
    await widget.context.todoRepository.save(todo);
    _refreshTodos();
  }

  Future<void> _toggleTodo(Todo todo) async {
    todo.isDone = !todo.isDone;
    await widget.context.todoRepository.save(todo);
    _refreshTodos();
  }

  Future<void> _deleteTodo(Todo todo) async {
    if (todo.id != null) {
      await widget.context.todoRepository.delete(todo.id!);
      _refreshTodos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/datapod_logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('Datapod Todos'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Todo>>(
        future: _todosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final todos = snapshot.data ?? [];
          if (todos.isEmpty) {
            return const Center(child: Text('No todos yet. Add one!'));
          }
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return ListTile(
                leading: Checkbox(
                  value: todo.isDone,
                  onChanged: (_) => _toggleTodo(todo),
                ),
                title: Text(
                  todo.title ?? '',
                  style: TextStyle(
                    decoration: todo.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteTodo(todo),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Todo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter task...'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addTodo(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
