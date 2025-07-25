import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:phrazy/game/game_controller.dart';
import 'package:phrazy/utility/settings_notifier.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:phrazy/data/game_repository.dart';
import 'package:phrazy/data/local_data_source.dart';
import 'package:phrazy/data/remote_data_source.dart';
import 'package:phrazy/firebase_options.dart';
import 'package:phrazy/routes.dart';
import 'package:phrazy/sound.dart';
import 'package:phrazy/utility/copy.dart';
import 'package:phrazy/utility/events.dart';
import 'package:phrazy/utility/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    await SoLoud.instance.init();
    print("SoLoud initialized successfully!");
  } catch (e) {
    print("FATAL ERROR: Failed to initialize SoLoud: $e");
    return;
  }
  await loadSounds();
  runApp(const Phrazy());
}

class Phrazy extends StatelessWidget {
  const Phrazy({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GameController(
            repository: GameRepository(
              remote: RemoteDataSource(),
              local: LocalDataSource(),
            ),
          ),
        ),
        ChangeNotifierProvider(create: (_) => PhrazyThemeNotifier()),
        ChangeNotifierProvider(create: (_) => SettingsNotifier()), // ← NEW
      ],
      child: Consumer<PhrazyThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp.router(
            title: Copy.title,
            theme: themeNotifier.currentTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
