import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/todo_model.dart';

class TodoCubit extends Cubit<List<Todo>> {
  TodoCubit() : super([]);

  void addTodo(String title) {
    final todo = Todo(title: title);
    emit([...state, todo]);
  }

  void removeTodo(Todo todo) {
    emit(state.where((t) => t != todo).toList());
  }
}
