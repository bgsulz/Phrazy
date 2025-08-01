import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:phrazy/sound.dart';
import 'package:phrazy/utility/events.dart';

import '../utility/copy.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'game/state.dart';
import 'utility/style.dart';
import 'routes.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

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
    Events.logVisit();
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: MaterialApp.router(
        title: Copy.title,
        theme: PhrazyTheme.instance,
        routerConfig: router,
      ),
    );
  }
}
