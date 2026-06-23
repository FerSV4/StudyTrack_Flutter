import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';
import 'features/tasks/presentation/widgets/task_form_bottom_sheet.dart';
import 'features/academic/presentation/bloc/academic_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/study_sessions/presentation/bloc/study_session_bloc.dart';
import 'core/widgets/global_network_banner.dart';

import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  
  runApp(const StudyTrackApp());
}

class StudyTrackApp extends StatefulWidget {
  const StudyTrackApp({super.key});

  @override
  State<StudyTrackApp> createState() => _StudyTrackAppState();
}

class _StudyTrackAppState extends State<StudyTrackApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'studytrack' && uri.host == 'task') {
      final path = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';

      if (path == 'new') {
        final incomingTitle = uri.queryParameters['title'];
        final incomingDescription = uri.queryParameters['description'];

        Future.delayed(const Duration(milliseconds: 500), () {
          final context = _navigatorKey.currentContext;

          if (context != null && context.mounted) {
            showTaskFormBottomSheet(
              context,
              initialTitle: incomingTitle,
              initialDescription: incomingDescription,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => di.sl<AuthBloc>()),
        BlocProvider<TaskBloc>(create: (context) => di.sl<TaskBloc>()),
        BlocProvider<AcademicBloc>(create: (context) => di.sl<AcademicBloc>()),
        BlocProvider<ProfileBloc>(create: (context) => di.sl<ProfileBloc>()),
        BlocProvider<StudySessionBloc>(create: (context) => di.sl<StudySessionBloc>()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'StudyTrack',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1D4ED8),
            surface: const Color(0xFFF8FAFC),
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        builder: (context, child) {
          return GlobalNetworkBanner(child: child!);
        },
        home: const LoginPage(),
      ),
    );
  }
}