import 'package:apps_moviles_practica/models/task.dart';
import 'package:flutter/material.dart';

class AddTaskForm extends StatefulWidget {
  final Function(Task task) onSubmit;

  const AddTaskForm({
    super.key,
    required this.onSubmit,
  });

  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _proyectCodeController = TextEditingController();
  final TextEditingController _activityCodeController = TextEditingController();
  final TextEditingController _observationController = TextEditingController();
  TaskStatus _selectedStatus = TaskStatus.NOT_STARTED;

  @override
  void dispose() {
    _proyectCodeController.dispose();
    _activityCodeController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch,
        proyectCode: int.parse(_proyectCodeController.text),
        activityCode: int.parse(_activityCodeController.text),
        status: _selectedStatus,
        observation: _observationController.text,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      widget.onSubmit(task);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nueva Proyecto',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Project Code Field
                TextFormField(
                  controller: _proyectCodeController,
                  decoration: _buildInputDecoration(
                      'Código de Proyecto', Icons.folder_outlined),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Este campo es requerido';
                    }
                    if (int.tryParse(value!) == null) {
                      return 'Debe ser un número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Activity Code Field
                TextFormField(
                  controller: _activityCodeController,
                  decoration: _buildInputDecoration(
                      'Código de Actividad', Icons.assignment_outlined),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Este campo es requerido';
                    }
                    if (int.tryParse(value!) == null) {
                      return 'Debe ser un número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Status Dropdown
                DropdownButtonFormField<TaskStatus>(
                  value: _selectedStatus,
                  decoration:
                      _buildInputDecoration('Estado', Icons.flag_outlined),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  items: TaskStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.value,
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Observation Field
                TextFormField(
                  controller: _observationController,
                  decoration: _buildInputDecoration(
                      'Observación', Icons.description_outlined),
                  maxLines: 3,
                  style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Guardar Proyecto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
