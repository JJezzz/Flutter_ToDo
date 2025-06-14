import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/todo_cubit.dart';
import '../models/todo_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addTask(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<TodoCubit>().addTodo(text);
      _controller.clear();
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = Colors.deepPurple;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('ToDo List'),
        centerTitle: true,
        backgroundColor: primary,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Ввід із плаваючою кнопкою та ефектом
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(16),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Enter a new task...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSubmitted: (_) => _addTask(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ScaleTransition(
                    scale: Tween<double>(begin: 1, end: 1.2).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: FloatingActionButton(
                      onPressed: () => _addTask(context),
                      backgroundColor: primary,
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.add, size: 32),
                    ),
                  ),
                ],
              ),
            ),

            // Список задач з плавною появою та swipe-to-delete
            Expanded(
              child: BlocBuilder<TodoCubit, List<Todo>>(
                builder: (context, todos) {
                  if (todos.isEmpty) {
                    return Center(
                      child: Text(
                        'No tasks yet. Add one!',
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[400]),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: todos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final todo = todos[i];
                      return Dismissible(
                        key: ValueKey(todo.createdAt),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => context.read<TodoCubit>().removeTodo(todo),
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
                        ),
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            title: Text(
                              todo.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              todo.createdAt.toLocal().toString().substring(0, 16),
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.check_circle, color: primary, size: 28),
                              onPressed: () => context.read<TodoCubit>().removeTodo(todo),
                              tooltip: 'Complete task',
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
