import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studytrack_design_system/studytrack_design_system.dart';

import '../../data/dtos/create_subject_dto.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/entities/term_entity.dart';
import '../bloc/academic_bloc.dart';
import '../bloc/academic_event.dart';
import '../bloc/academic_state.dart';

class SubjectManagerPage extends StatefulWidget {
  final TermEntity term;

  const SubjectManagerPage({super.key, required this.term});

  @override
  State<SubjectManagerPage> createState() => _SubjectManagerPageState();
}

class _SubjectManagerPageState extends State<SubjectManagerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<SubjectEntity> _addedSubjects = [];
  String _selectedColor = '#1D4ED8';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubjectCreated(SubjectEntity subject) {
    setState(() {
      _addedSubjects.add(subject);
      _nameController.clear();
      _selectedColor = '#1D4ED8';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Materia "${subject.name}" agregada')),
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AcademicBloc, AcademicState>(
      listenWhen: (_, state) =>
          state is AcademicSubjectCreated || state is AcademicError,
      listener: (context, state) {
        if (state is AcademicSubjectCreated) {
          final subject = SubjectEntity(
            id: '${_addedSubjects.length + 1}',
            name: _nameController.text.trim(),
            colorCode: _selectedColor,
          );
          _handleSubjectCreated(subject);
        }

        if (state is AcademicError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Configurar materias', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFFF8FAFC),
          elevation: 0,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Text(
                            'Semestre: ${widget.term.name}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_addedSubjects.isNotEmpty) ...[
                            Text(
                              'Materias agregadas',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._addedSubjects.map(
                              (subject) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: StCard(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: _hexToColor(subject.colorCode),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          subject.name,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          StCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                StTextField(
                                  label: 'Nombre de la materia',
                                  hint: 'Ej. Matemática',
                                  controller: _nameController,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Ingresa un nombre';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                StColorPicker(
                                  selectedColorHex: _selectedColor,
                                  onColorSelected: (colorHex) {
                                    setState(() {
                                      _selectedColor = colorHex;
                                    });
                                  },
                                ),
                                const SizedBox(height: 20),
                                BlocBuilder<AcademicBloc, AcademicState>(
                                  builder: (context, state) {
                                    return StButton(
                                      text: 'Añadir Materia',
                                      isLoading: state is AcademicLoading,
                                      onPressed: () {
                                        if (!_formKey.currentState!.validate()) return;

                                        context.read<AcademicBloc>().add(
                                              CreateSubjectRequested(
                                                termId: widget.term.id,
                                                dto: CreateSubjectDto(
                                                  termId: widget.term.id,
                                                  name: _nameController.text.trim(),
                                                  colorCode: _selectedColor,
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
                    const SizedBox(height: 12),
                    BlocBuilder<AcademicBloc, AcademicState>(
                      builder: (context, state) {
                        final enabled = _addedSubjects.isNotEmpty && state is! AcademicLoading;
                        return StButton(
                          text: 'Finalizar y entrar a StudyTrack',
                          onPressed: enabled
                              ? () {
                                  context.read<AcademicBloc>().add(GetActiveTermRequested());
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                }
                              : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}