import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studytrack_design_system/studytrack_design_system.dart';

import '../../data/dtos/create_term_dto.dart';
import '../bloc/academic_bloc.dart';
import '../bloc/academic_event.dart';
import '../bloc/academic_state.dart';
import 'subject_manager_page.dart';

class CreateTermPage extends StatefulWidget {
  const CreateTermPage({super.key});

  @override
  State<CreateTermPage> createState() => _CreateTermPageState();
}

class _CreateTermPageState extends State<CreateTermPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() {
        if (isStart) {
          _startDate = selected;
          _startDateController.text = _formatDate(selected);
          if (_endDate != null && _endDate!.isBefore(selected)) {
            _endDate = null;
            _endDateController.clear();
          }
        } else {
          _endDate = selected;
          _endDateController.text = _formatDate(selected);
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AcademicBloc, AcademicState>(
      listenWhen: (_, state) => state is AcademicTermCreated || state is AcademicError,
      listener: (context, state) {
        if (state is AcademicTermCreated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SubjectManagerPage(term: state.term),
            ),
          );
        }
        if (state is AcademicError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Configurar semestre')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                StCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StTextField(
                        label: 'Nombre del semestre',
                        hint: 'Ej. Semestre 1 - 2026',
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa un nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      StTextField(
                        label: 'Fecha de inicio',
                        hint: 'Selecciona una fecha',
                        controller: _startDateController,
                        readOnly: true,
                        onTap: () => _pickDate(isStart: true),
                        validator: (value) {
                          if (_startDate == null) {
                            return 'Selecciona una fecha de inicio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      StTextField(
                        label: 'Fecha de fin',
                        hint: 'Selecciona una fecha',
                        controller: _endDateController,
                        readOnly: true,
                        onTap: () => _pickDate(isStart: false),
                        validator: (value) {
                          if (_endDate == null) {
                            return 'Selecciona una fecha de fin';
                          }
                          if (_startDate != null && _endDate!.isBefore(_startDate!)) {
                            return 'La fecha de fin debe ser posterior';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<AcademicBloc, AcademicState>(
                        builder: (context, state) {
                          final isLoading = state is AcademicLoading;
                          return StButton(
                            text: 'Crear semestre',
                            isLoading: isLoading,
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;
                              context.read<AcademicBloc>().add(
                                    CreateTermRequested(
                                      CreateTermDto(
                                        name: _nameController.text.trim(),
                                        startDate: _startDate!,
                                        endDate: _endDate!,
                                      ),
                                    ),
                                  );
                            },
                          );
                        },
                      ),
                    ],
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
