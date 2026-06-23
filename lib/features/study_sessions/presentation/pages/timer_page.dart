import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studytrack_design_system/studytrack_design_system.dart';

import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../bloc/study_session_bloc.dart';
import '../bloc/study_session_event.dart';
import '../bloc/study_session_state.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getStatusText(StudySessionStatus status) {
    switch (status) {
      case StudySessionStatus.initial:
        return 'LISTO PARA EMPEZAR';
      case StudySessionStatus.running:
        return 'ENFOQUE ACTIVO';
      case StudySessionStatus.paused:
        return 'EN PAUSA';
      case StudySessionStatus.finished:
        return 'SESIÓN FINALIZADA';
      default:
        return status.name.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TaskBloc, TaskState>(
          listenWhen: (_, current) => current is TaskLoaded,
          listener: (context, state) {
            if (state is TaskLoaded &&
                state.tasks.isNotEmpty &&
                context.read<StudySessionBloc>().state.selectedTaskId == null) {
              context
                  .read<StudySessionBloc>()
                  .add(StudySessionTaskSelected(state.tasks.first.id));
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: StColors.background,
        appBar: AppBar(
          title: const Text('Pomodoro', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: StColors.background,
          foregroundColor: StColors.textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BlocBuilder<StudySessionBloc, StudySessionState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            StCard(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 260,
                                      height: 260,
                                      child: CustomPaint(
                                        painter: _TimerRingPainter(
                                          progress: state.selectedDurationSeconds == 0
                                              ? 0
                                              : 1 -
                                                  (state.remainingSeconds /
                                                      state.selectedDurationSeconds),
                                          backgroundColor: StColors.border.withValues(alpha: 0.5),
                                          progressColor: state.status == StudySessionStatus.paused 
                                              ? const Color(0xFFF59E0B)
                                              : StColors.primary,
                                        ),
                                        child: Center(
                                          child: Text(
                                            _formatDuration(state.remainingSeconds),
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium
                                                ?.copyWith(
                                                  color: StColors.textPrimary,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 2,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: state.status == StudySessionStatus.running 
                                            ? StColors.primary.withValues(alpha: 0.1)
                                            : StColors.border.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _getStatusText(state.status),
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              color: state.status == StudySessionStatus.running 
                                                  ? StColors.primary 
                                                  : StColors.textPrimary.withValues(alpha: 0.6),
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                      ),
                                    ),
                                    if (state.errorMessage != null) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        state.errorMessage!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.redAccent),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            _buildPlayerControls(context, state),
                            
                            const SizedBox(height: 32),
                            StCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Configuración',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'DURACIÓN',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: StColors.textPrimary.withValues(alpha: 0.5)),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      for (final minutes in [15, 25, 50])
                                        ChoiceChip(
                                          label: Text('${minutes}m', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          selected: state.selectedDurationSeconds == minutes * 60 &&
                                              state.status != StudySessionStatus.running,
                                          onSelected: state.status == StudySessionStatus.running
                                              ? null
                                              : (_) => context.read<StudySessionBloc>().add(
                                                    StudySessionDurationSelected(minutes * 60),
                                                  ),
                                          selectedColor: StColors.primary.withValues(alpha: 0.16),
                                          labelStyle: TextStyle(
                                            color: state.selectedDurationSeconds == minutes * 60
                                                ? StColors.primary
                                                : StColors.textPrimary,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'TAREA EN ENFOQUE',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: StColors.textPrimary.withValues(alpha: 0.5)),
                                  ),
                                  const SizedBox(height: 12),
                                  BlocBuilder<TaskBloc, TaskState>(
                                    builder: (context, taskState) {
                                      final tasks =
                                          taskState is TaskLoaded ? taskState.tasks : const [];
                                      final selectedTaskId = state.selectedTaskId ??
                                          (tasks.isNotEmpty ? tasks.first.id : null);
                                      if (taskState is TaskLoaded &&
                                          state.selectedTaskId == null &&
                                          tasks.isNotEmpty) {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          if (context.mounted) {
                                            context
                                                .read<StudySessionBloc>()
                                                .add(StudySessionTaskSelected(tasks.first.id));
                                          }
                                        });
                                      }
                                      return DropdownButtonFormField<String>(
                                        value: selectedTaskId != null &&
                                                tasks.any((task) => task.id == selectedTaskId)
                                            ? selectedTaskId
                                            : null,
                                        icon: const Icon(Icons.expand_more_rounded),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: StColors.border),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: StColors.border),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        hint: const Text('Selecciona una tarea'),
                                        items: tasks
                                            .map<DropdownMenuItem<String>>(
                                              (task) => DropdownMenuItem<String>(
                                                value: task.id,
                                                child: Text(
                                                  task.title,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: state.status == StudySessionStatus.running
                                            ? null
                                            : (value) {
                                                if (value != null) {
                                                  context
                                                      .read<StudySessionBloc>()
                                                      .add(StudySessionTaskSelected(value));
                                                }
                                              },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  Widget _buildPlayerControls(BuildContext context, StudySessionState state) {
    final isRunning = state.status == StudySessionStatus.running;
    final isPaused = state.status == StudySessionStatus.paused;
    final isInitial = state.status == StudySessionStatus.initial;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedOpacity(
          opacity: isInitial ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: InkWell(
            onTap: isInitial
                ? null
                : () => context.read<StudySessionBloc>().add(StudySessionFinishRequested()),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isInitial ? StColors.border : const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.stop_rounded,
                color: isInitial ? StColors.textPrimary.withValues(alpha: 0.5) : const Color(0xFFEF4444),
                size: 32,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 32),
        
        InkWell(
          onTap: () {
            if (isRunning) {
              context.read<StudySessionBloc>().add(StudySessionPauseRequested());
            } else if (isPaused) {
              context.read<StudySessionBloc>().add(StudySessionResumeRequested());
            } else {
              final tasksState = context.read<TaskBloc>().state;
              final effectiveTaskId = state.selectedTaskId ??
                  (tasksState is TaskLoaded && tasksState.tasks.isNotEmpty
                      ? tasksState.tasks.first.id
                      : null);
              if (effectiveTaskId != null) {
                context.read<StudySessionBloc>().add(StudySessionTaskSelected(effectiveTaskId));
              }
              context.read<StudySessionBloc>().add(StudySessionStartRequested());
            }
          },
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: StColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: StColors.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),

        const SizedBox(width: 32),

        const SizedBox(width: 56, height: 56), 
      ],
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _TimerRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    const strokeWidth = 14.0;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}