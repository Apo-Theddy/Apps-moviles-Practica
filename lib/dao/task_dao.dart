import 'package:apps_moviles_practica/models/task.dart';
import 'package:floor/floor.dart';

@dao
abstract class TaskDAO {
  @Query('SELECT * FROM Task')
  Future<List<Task>> getTasks();

  @Query('SELECT * FROM Task WHERE id = :id')
  Future<Task?> getTaskById(int id);

  @Insert()
  Future<void> insert(Task task);

  @Update()
  Future<void> update(Task task);

  @Query('DELETE FROM Task WHERE id = :id')
  Future<void> delete(int id);
}
