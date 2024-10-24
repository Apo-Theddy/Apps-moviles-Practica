import 'package:floor/floor.dart';

enum TaskStatus {
  NOT_STARTED,
  DELAYED,
  EXECUTING,
  FINISHED,
}

extension TaskStatusValue on TaskStatus {
  String get value {
    switch (this) {
      case TaskStatus.NOT_STARTED:
        return "No iniciado";
      case TaskStatus.DELAYED:
        return "Retrasado";
      case TaskStatus.EXECUTING:
        return "Ejecutando";
      case TaskStatus.FINISHED:
        return "Finalizado";
      default:
        return "NONE";
    }
  }
}

@entity
class Task {
  @PrimaryKey()
  final int id;

  @ColumnInfo(name: 'proyect_code') // Nombre explícito para columna
  final int proyectCode;

  @ColumnInfo(name: 'activity_code')
  final int activityCode;

  @ColumnInfo(name: 'status')
  final TaskStatus status;

  @ColumnInfo(name: 'observation')
  final String observation;

  @ColumnInfo(name: "created_at")
  int? createdAt;

  Task({
    required this.id,
    required this.proyectCode,
    required this.activityCode,
    required this.status,
    required this.observation,
    this.createdAt,
  });
}
