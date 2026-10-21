import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/home/data/datasources/feed_local_data_source.dart';
import 'features/home/data/repositories/feed_repository_impl.dart';
import 'features/home/presentation/bloc/feed_bloc.dart';
import 'features/home/presentation/bloc/feed_event.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() {
  runApp(const FikratyApp());
}

class FikratyApp extends StatelessWidget {
  const FikratyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedBloc(
        feedRepository: FeedRepositoryImpl(
          localDataSource: FeedLocalDataSourceImpl(),
        ),
      )..add(const LoadFeedEvent()),
      child: MaterialApp(
        title: 'Fikraty',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4F46E5),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
