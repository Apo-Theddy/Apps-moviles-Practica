import 'package:apps_moviles_practica/database/app_database.dart';
import 'package:apps_moviles_practica/models/task.dart';
import 'package:apps_moviles_practica/pages/add_task_form.dart';
import 'package:apps_moviles_practica/pages/edit_task_form.dart';
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
          seedColor: const Color(0xFF2563EB), // Un azul más moderno
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const SplashScreen(),
    ),
  );
}

// Pantalla de splash para una mejor experiencia de inicio
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final database =
        await $FloorAppDatabase.databaseBuilder("practica.db").build();
    await Future.delayed(const Duration(seconds: 1)); // Mínimo tiempo de splash
    if (mounted) {
      Get.off(
        () => HomeScreen(database: database),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Hero(
          tag: 'app_icon',
          child: Icon(
            Icons.task_alt_rounded,
            size: 80,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = true.obs;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  final ScrollController _scrollController = ScrollController();
  final RxBool _showScrollToTop = false.obs;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollController();
    _loadTasks();
  }

  void _setupAnimations() {
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _fabController.forward();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.offset >= 400) {
        _showScrollToTop.value = true;
      } else {
        _showScrollToTop.value = false;
      }
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _loadTasks() async {
    isLoading.value = true;
    try {
      final loadedTasks = await widget.database.taskDAO.getTasks();
      tasks.value = loadedTasks;
    } catch (e) {
      _showErrorSnackbar('No se pudieron cargar las proyectos');
    } finally {
      isLoading.value = false;
    }
  }

  void _showAddTaskDialog() {
    _fabController.reverse();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskForm(onSubmit: _handleAddTask),
    ).then((_) => _fabController.forward());
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Éxito',
      message,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red.shade800,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.red),
    );
  }

  Future<void> _handleAddTask(Task task) async {
    try {
      await widget.database.taskDAO.insert(task);
      await _loadTasks();
      Get.back();
      _showSuccessSnackbar('proyecto agregada correctamente');
    } catch (e) {
      _showErrorSnackbar('No se pudo agregar la proyecto');
    }
  }

  Future<void> _handleDeleteTask(Task task) async {
    try {
      await widget.database.taskDAO.delete(task.id);
      await _loadTasks();
      _showSuccessSnackbar('proyecto eliminada correctamente');
    } catch (e) {
      _showErrorSnackbar('No se pudo eliminar la proyecto');
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
      _showErrorSnackbar('No se pudo actualizar el estado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'app_icon',
              child: Icon(
                Icons.task_alt_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Proyectos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadTasks,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Obx(
        () => isLoading.value
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando proyectos...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : tasks.isEmpty
                ? _buildEmptyState()
                : _buildTaskList(),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => _showScrollToTop.value
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FloatingActionButton.small(
                    heroTag: null,
                    onPressed: _scrollToTop,
                    child: const Icon(Icons.keyboard_arrow_up),
                  ),
                )
              : const SizedBox()),
          ScaleTransition(
            scale: _fabAnimation,
            child: FloatingActionButton.extended(
              onPressed: _showAddTaskDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nueva proyecto'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No hay proyectos pendientes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza agregando una nueva proyecto',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddTaskDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar proyecto'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 100),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return CardTask(
            key: ValueKey(task.id),
            task: task,
            onEdit: _showEditTaskDialog,
            onDelete: _handleDeleteTask,
            onStatusChanged: (newStatus) =>
                _handleUpdateStatus(task, newStatus),
          );
        },
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    _fabController.reverse();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTaskForm(
        task: task,
        onSubmit: _handleEditTask,
      ),
    ).then((_) => _fabController.forward());
  }

  Future<void> _handleEditTask(Task updatedTask) async {
    try {
      await widget.database.taskDAO.update(updatedTask);
      await _loadTasks();
      Get.back();
      _showSuccessSnackbar('proyecto actualizada correctamente');
    } catch (e) {
      _showErrorSnackbar('No se pudo actualizar la proyecto');
    }
  }

  @override
  void dispose() {
    _fabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
