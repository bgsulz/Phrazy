import 'package:go_router/go_router.dart';
import '../data/puzzle.dart';
import '../screens/screen.dart';
import '../screens/screen_archive.dart';
import '../screens/screen_game.dart';
import '../screens/screen_invalid.dart';
import '../core/ext_ymd.dart';
import '../utility/ext.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PhrazyScreen(child: GameScreen()),
    ),
    GoRoute(
      path: '/demo',
      builder: (context, state) =>
          PhrazyScreen(child: GameScreen(puzzle: Puzzle.demo())),
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

GoRouter get router => _router;
