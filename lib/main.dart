import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/screens/modules.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/screens/register.dart';
import 'package:codecraft/themes/dark_mode.dart';
import 'package:codecraft/themes/light_mode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:codecraft/providers/level_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initDatabase();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

Future<void> initDatabase() async {
  DatabaseHelper();
}

Future<Widget> getLandingPage() async {
  return StreamBuilder<User?>(
    stream: DatabaseHelper().auth.userChanges(),
    builder: (BuildContext context, snapshot) {
      if (snapshot.hasData && (!snapshot.data!.isAnonymous)) {
        return Modules();
      }

      return const MyHomePage();
    },
  );
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LevelProvider(),
      child: AdaptiveTheme(
        light: lightTheme,
        dark: darkTheme,
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp(
          title: 'CodeCraft',
          theme: theme,
          darkTheme: darkTheme,
          themeMode: MediaQuery.platformBrightnessOf(context) == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          home: FutureBuilder<Widget>(
            future: getLandingPage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return snapshot.data!;
              } else {
                return LoadingAnimationWidget.inkDrop(
                    color: Colors.white,
                    size: 100); // Show loading spinner while waiting
              }
            },
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/flutter.png', width: 200, height: 200),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: const AutoSizeText(
                'Learn to apply and use your programming concepts!',
                minFontSize: 24,
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Register()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                ),
                child:
                    const Text('Get Started', style: TextStyle(fontSize: 20)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
