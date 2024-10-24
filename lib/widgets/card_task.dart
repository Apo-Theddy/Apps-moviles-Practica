import 'package:apps_moviles_practica/models/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class CardTask extends StatefulWidget {
  final Task task;
  final Function(Task task)? onEdit;
  final Function(Task task)? onDelete;
  final Function(TaskStatus newStatus)? onStatusChanged;

  const CardTask({
    super.key,
    required this.task,
    this.onEdit,
    this.onDelete,
    this.onStatusChanged,
  });

  @override
  State<CardTask> createState() => _CardTaskState();
}

class _CardTaskState extends State<CardTask> {
  late TaskStatus currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.task.status;
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return 'No disponible';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.5,
        children: [
          CustomSlidableAction(
            onPressed: (context) => widget.onEdit?.call(widget.task),
            backgroundColor: Colors.blue.shade400,
            foregroundColor: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.edit_rounded),
                SizedBox(height: 4),
                Text('Editar', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          CustomSlidableAction(
            onPressed: (context) => widget.onDelete?.call(widget.task),
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.delete_rounded),
                SizedBox(height: 4),
                Text('Eliminar', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: _getStatusColor(currentStatus),
                  width: 4,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Proyecto #${widget.task.proyectCode}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (widget.task.observation.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.task.observation,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey.shade700,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildStatusDropdown(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildInfoChip(
                            Icons.numbers_rounded, 'ID: ${widget.task.id}'),
                        const SizedBox(width: 8),
                        _buildInfoChip(Icons.task_rounded,
                            'Actividad: ${widget.task.activityCode}'),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.calendar_today_rounded,
                          'Creado: ${_formatDate(widget.task.createdAt)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Theme(
      data: Theme.of(context).copyWith(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _getStatusColor(currentStatus).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: PopupMenuButton<TaskStatus>(
          initialValue: currentStatus,
          onSelected: (TaskStatus status) {
            setState(() {
              currentStatus = status;
            });
            widget.onStatusChanged?.call(status);
          },
          itemBuilder: (BuildContext context) => TaskStatus.values
              .map((TaskStatus status) => PopupMenuItem<TaskStatus>(
                    value: status,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(status.value),
                      ],
                    ),
                  ))
              .toList(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(currentStatus),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  currentStatus.value,
                  style: TextStyle(
                    color: _getStatusColor(currentStatus),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  color: _getStatusColor(currentStatus),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.NOT_STARTED:
        return Colors.grey.shade600;
      case TaskStatus.DELAYED:
        return Colors.orange.shade600;
      case TaskStatus.EXECUTING:
        return Colors.blue.shade600;
      case TaskStatus.FINISHED:
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
