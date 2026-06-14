import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../academic/data/models/term_model.dart';
import '../../../academic/presentation/bloc/academic_bloc.dart';
import '../../../academic/presentation/bloc/academic_event.dart';
import '../../../academic/presentation/bloc/academic_state.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';

Future<void> showTaskFormBottomSheet(
  BuildContext context, {
  TaskEntity? task,
  String? initialSubjectName,
}) {
  final academicBloc = context.read<AcademicBloc>();
  if (academicBloc.state is! AcademicLoaded) {
    academicBloc.add(GetActiveTermRequested());
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFF8FAFC),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomSheetContext) {
      return _TaskFormBottomSheet(
        task: task,
        initialSubjectName: initialSubjectName,
      );
    },
  );
}

class _TaskFormBottomSheet extends StatefulWidget {
  final TaskEntity? task;
  final String? initialSubjectName;

  const _TaskFormBottomSheet({
    this.task,
    this.initialSubjectName,
  });

  @override
  State<_TaskFormBottomSheet> createState() => _TaskFormBottomSheetState();
}

class _TaskFormBottomSheetState extends State<_TaskFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _estimatedHoursController;
  late DateTime _selectedDate;
  String? _selectedSubjectId;
  String _selectedPriority = 'medium';

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _estimatedHoursController = TextEditingController(
      text: task?.estimatedHours != null ? _formatHours(task!.estimatedHours!) : '',
    );
    _selectedDate = task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _selectedSubjectId = task?.subjectId.isNotEmpty == true ? task!.subjectId : null;
    _selectedPriority = task?.priority ?? 'medium';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedHoursController.dispose();
    super.dispose();
  }

  String _formatHours(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  void _submit(List<SubjectModel> subjects) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedSubject = subjects.firstWhere(
      (subject) => subject.id == _selectedSubjectId,
      orElse: () => subjects.first,
    );

    final estimatedHoursText = _estimatedHoursController.text.trim();
    final estimatedHours =
        estimatedHoursText.isEmpty ? null : double.tryParse(estimatedHoursText);

    final task = TaskEntity(
      id: widget.task?.id ?? '',
      subjectId: selectedSubject.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: _selectedDate,
      estimatedHours: estimatedHours,
      priority: _selectedPriority,
      isCompleted: widget.task?.isCompleted ?? false,
      subjectName: selectedSubject.name,
      subjectColor: selectedSubject.colorCode,
    );

    final taskBloc = context.read<TaskBloc>();
    if (_isEditing) {
      taskBloc.add(UpdateTaskDetailsRequested(widget.task!.id, task));
    } else {
      taskBloc.add(CreateTaskRequested(task));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 24),
      child: BlocBuilder<AcademicBloc, AcademicState>(
        builder: (context, state) {
          final subjects = state is AcademicLoaded ? state.term.subjects : <SubjectModel>[];

          if (_selectedSubjectId == null && subjects.isNotEmpty) {
            final preferred = widget.initialSubjectName != null
                ? subjects.where((subject) => subject.name == widget.initialSubjectName).toList()
                : <SubjectModel>[];
            _selectedSubjectId = preferred.isNotEmpty ? preferred.first.id : subjects.first.id;
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isEditing ? 'Editar tarea' : 'Nueva tarea',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Completa los detalles para organizar mejor tu agenda.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _titleController,
                        label: 'Titulo',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa un titulo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Descripcion',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField<SubjectModel>(
                        label: 'Materia',
                        value: subjects.where((subject) => subject.id == _selectedSubjectId).isNotEmpty
                            ? subjects.firstWhere((subject) => subject.id == _selectedSubjectId)
                            : null,
                        items: subjects,
                        itemLabel: (subject) => subject.name,
                        enabled: state is AcademicLoaded,
                        hint: state is AcademicLoading || state is AcademicInitial
                            ? 'Cargando materias...'
                            : 'Selecciona una materia',
                        onChanged: (subject) {
                          setState(() {
                            _selectedSubjectId = subject?.id;
                          });
                        },
                        validator: (_) {
                          if (_selectedSubjectId == null || _selectedSubjectId!.isEmpty) {
                            return 'Selecciona una materia';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(14),
                        child: InputDecorator(
                          decoration: _inputDecoration('Fecha de entrega'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(Icons.calendar_today_outlined, color: Color(0xFF64748B)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _estimatedHoursController,
                        label: 'Horas estimadas',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }

                          if (double.tryParse(value.trim()) == null) {
                            return 'Ingresa un numero valido';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField<String>(
                        label: 'Prioridad',
                        value: _selectedPriority,
                        items: const ['low', 'medium', 'high'],
                        itemLabel: (priority) => _priorityLabel(priority),
                        onChanged: (priority) {
                          if (priority != null) {
                            setState(() {
                              _selectedPriority = priority;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(color: Color(0xFF475569)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: subjects.isEmpty ? null : () => _submit(subjects),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D4ED8),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(_isEditing ? 'Guardar cambios' : 'Crear tarea'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
    T? value,
    String? Function(T?)? validator,
    bool enabled = true,
    String? hint,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      decoration: _inputDecoration(label),
      hint: hint != null ? Text(hint) : null,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.2),
      ),
    );
  }

  String _priorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return 'Alta';
      case 'low':
        return 'Baja';
      default:
        return 'Media';
    }
  }
}
