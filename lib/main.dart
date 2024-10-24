// main.dart
import 'package:apps_moviles_practica/database/app_database.dart';
import 'package:apps_moviles_practica/models/task.dart';
import 'package:apps_moviles_practica/pages/add_task_form.dart';
import 'package:apps_moviles_practica/widgets/card_task.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database =
      await $FloorAppDatabase.databaseBuilder("practica.db").build();
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: HomeScreen(database: database),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  final AppDatabase database;

  const HomeScreen({
    super.key,
    required this.database,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    isLoading.value = true;
    try {
      final loadedTasks = await widget.database.taskDAO.getTasks();
      tasks.value = loadedTasks;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las tareas',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showAddTaskDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskForm(
        onSubmit: _handleAddTask,
      ),
    );
  }

  Future<void> _handleAddTask(Task task) async {
    try {
      await widget.database.taskDAO.insert(task);
      await _loadTasks();
      Get.back();
      Get.snackbar(
        'Éxito',
        'Tarea agregada correctamente',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo agregar la tarea',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _handleDeleteTask(Task task) async {
    try {
      await widget.database.taskDAO.delete(task.id);
      await _loadTasks();
      Get.snackbar(
        'Éxito',
        'Tarea eliminada correctamente',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar la tarea',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _handleUpdateStatus(Task task, TaskStatus newStatus) async {
    try {
      final updatedTask = Task(
        id: task.id,
        proyectCode: task.proyectCode,
        activityCode: task.activityCode,
        status: newStatus,
        observation: task.observation,
        createdAt: task.createdAt,
      );
      await widget.database.taskDAO.update(updatedTask);
      await _loadTasks();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el estado',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: Obx(
        () => isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay tareas',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Agrega una nueva tarea con el botón +',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTasks,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return CardTask(
                          key: ValueKey(task.id),
                          task: task,
                          onDelete: _handleDeleteTask,
                          onStatusChanged: (newStatus) =>
                              _handleUpdateStatus(task, newStatus),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
