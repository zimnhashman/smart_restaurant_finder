import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_restaurant_finder/src/business_logic/blocs/category/category_bloc.dart';
import 'package:smart_restaurant_finder/src/business_logic/blocs/food/food_bloc.dart';
import 'package:smart_restaurant_finder/src/business_logic/blocs/theme/theme_bloc.dart';
import 'package:smart_restaurant_finder/src/data/repository/repository.dart';
import 'package:smart_restaurant_finder/src/presentation/screen/auth/login_screen.dart';
import 'package:smart_restaurant_finder/core/services/connection_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    ConnectionService.dispose(); // Clean up connectivity subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<Repository>(
      create: (context) => Repository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<FoodBloc>(
            create: (context) => FoodBloc(repository: context.read<Repository>()),
          ),
          BlocProvider<CategoryBloc>(
            create: (context) => CategoryBloc(repository: context.read<Repository>()),
          ),
          BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                },
              ),
              theme: state.theme,
              home: Builder(
                builder: (context) {
                  // Initialize connection service after first frame
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ConnectionService.initialize(context);
                  });
                  return const LoginView();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}