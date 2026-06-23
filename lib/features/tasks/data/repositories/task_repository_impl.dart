import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  static const String _cacheKey = 'cached_tasks_list';

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TaskEntity>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final tasks = await remoteDataSource.getTasks();

      final List<Map<String, dynamic>> jsonList = tasks.map((task) {
        return TaskModel.fromEntity(task).toJson();
      }).toList();
      
      await prefs.setString(_cacheKey, jsonEncode(jsonList));

      return tasks;
    } catch (e) {
      final cachedData = prefs.getString(_cacheKey);
      
      if (cachedData != null) {
        final List<dynamic> decodedList = jsonDecode(cachedData);
        final List<TaskEntity> cachedTasks = decodedList.map((json) {
          return TaskModel.fromJson(json as Map<String, dynamic>);
        }).toList();
        
        return cachedTasks;
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> updateTaskStatus(String id, bool isCompleted) async {
    return await remoteDataSource.updateTaskStatus(id, isCompleted);
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    return await remoteDataSource.createTask(TaskModel.fromEntity(task));
  }

  @override
  Future<void> updateTaskDetails(String id, TaskEntity task) async {
    return await remoteDataSource.updateTaskDetails(id, TaskModel.fromEntity(task));
  }

  @override
  Future<void> deleteTask(String id) async {
    return await remoteDataSource.deleteTask(id);
  }
}