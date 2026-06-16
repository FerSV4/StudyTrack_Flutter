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
          title: const Text('Pomodoro'),
          backgroundColor: StColors.background,
          foregroundColor: StColors.textPrimary,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<StudySessionBloc, StudySessionState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        StCard(
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 240,
                                height: 240,
                                child: CustomPaint(
                                  painter: _TimerRingPainter(
                                    progress: state.selectedDurationSeconds == 0
                                        ? 0
                                        : 1 -
                                            (state.remainingSeconds /
                                                state.selectedDurationSeconds),
                                    backgroundColor: StColors.border,
                                    progressColor: StColors.primary,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _formatDuration(state.remainingSeconds),
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            color: StColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                state.status.name.toUpperCase(),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: StColors.textPrimary,
                                    ),
                              ),
                              if (state.errorMessage != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  state.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.redAccent),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        StCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Duración',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final minutes in [15, 25, 50])
                                    ChoiceChip(
                                      label: Text('${minutes}m'),
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
                              const SizedBox(height: 20),
                              Text(
                                'Tarea',
                                style: Theme.of(context).textTheme.titleMedium,
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
                                    initialValue: selectedTaskId != null &&
                                            tasks.any((task) => task.id == selectedTaskId)
                                        ? selectedTaskId
                                        : null,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    hint: const Text('Selecciona una tarea'),
                                    items: tasks
                                        .map<DropdownMenuItem<String>>(
                                          (task) => DropdownMenuItem<String>(
                                            value: task.id,
                                            child: Text(task.title),
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
                        const SizedBox(height: 20),
                        BlocBuilder<StudySessionBloc, StudySessionState>(
                          builder: (context, state) {
                            final isRunning = state.status == StudySessionStatus.running;
                            final isPaused = state.status == StudySessionStatus.paused;

                            return Row(
                              children: [
                                Expanded(
                                  child: StButton(
                                    text: isRunning
                                        ? 'Pausar'
                                        : isPaused
                                            ? 'Reanudar'
                                            : 'Iniciar',
                                    onPressed: () {
                                      if (isRunning) {
                                        context.read<StudySessionBloc>().add(
                                              StudySessionPauseRequested(),
                                            );
                                      } else if (isPaused) {
                                        context.read<StudySessionBloc>().add(
                                              StudySessionResumeRequested(),
                                            );
                                      } else {
                                        final tasksState = context.read<TaskBloc>().state;
                                        final effectiveTaskId = state.selectedTaskId ??
                                            (tasksState is TaskLoaded && tasksState.tasks.isNotEmpty
                                                ? tasksState.tasks.first.id
                                                : null);
                                        if (effectiveTaskId != null) {
                                          context.read<StudySessionBloc>().add(
                                                StudySessionTaskSelected(effectiveTaskId),
                                              );
                                        }
                                        context.read<StudySessionBloc>().add(
                                              StudySessionStartRequested(),
                                            );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: StButton(
                                    text: 'Finalizar',
                                    onPressed: state.status == StudySessionStatus.initial
                                        ? null
                                        : () => context.read<StudySessionBloc>().add(
                                              StudySessionFinishRequested(),
                                            ),
                                  ),
                                ),
                              ],
                            );
                          },
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