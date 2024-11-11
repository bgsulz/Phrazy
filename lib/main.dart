import 'package:phrazy/data/puzzle.dart';
import 'package:phrazy/utility/copy.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'state.dart';
import 'screens/screen.dart';
import 'screens/screen_archive.dart';
import 'screens/screen_game.dart';
import 'screens/screen_invalid.dart';
import 'utility/style.dart';
import 'utility/ext.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PhraseApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PhrazyScreen(child: GameScreen()),
    ),
    GoRoute(
      path: '/demo',
      builder: (context, state) {
        return PhrazyScreen(child: GameScreen(puzzle: Puzzle.demo()));
      },
    ),
    GoRoute(
        path: '/games',
        builder: (context, state) => const PhrazyScreen(child: ArchiveScreen()),
        routes: [
          GoRoute(
            redirect: (context, state) {
              var date = state.pathParameters['date']?.fromYMD;
              if (date?.isToday ?? false) return "/";
              return null;
            },
            path: ':date',
            builder: (context, state) {
              var date = state.pathParameters['date']?.fromYMD;
              return PhrazyScreen(child: GameScreen(date: date));
            },
          ),
        ]),
  ],
  errorBuilder: (context, state) => const PhrazyScreen(child: InvalidScreen()),
);

class PhraseApp extends StatelessWidget {
  const PhraseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: MaterialApp.router(
        title: Copy.title,
        theme: PhrazyTheme.instance,
        routerConfig: _router,
      ),
    );
  }
}
