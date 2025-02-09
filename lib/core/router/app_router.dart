import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/fish_details/presentation/pages/fish_survey_details.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/survey/:id',
        builder: (context, state) => SurveyDetailsPage(
          fishId: state.pathParameters['id'] ?? '',
        ),
      ),
    ],
  );
}); 