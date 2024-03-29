import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/firebase_options.dart';
import 'package:codecraft/providers/level_provider.dart';
import 'package:codecraft/providers/theme_provider.dart';
import 'package:codecraft/screens/body.dart';
import 'package:codecraft/screens/register.dart';
import 'package:codecraft/services/auth_helper.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/themes/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDatabase();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(MyApp(savedThemeMode: savedThemeMode));
}

Future<void> initDatabase() async {
  DatabaseHelper();
}

Future<Widget> getLandingPage() async {
  Auth auth = Auth(DatabaseHelper().auth);
  bool userLoggedIn = await auth.isLoggedIn();
  return userLoggedIn ? const Body() : const GettingStartedPage();
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LevelProvider>(
            create: (context) => LevelProvider()),
        ChangeNotifierProvider<ThemeProvider>(
            create: (context) => ThemeProvider()),
      ],
      builder: (appContext, child) {
        return AdaptiveTheme(
          light: AppTheme.lightTheme,
          dark: AppTheme.darkTheme,
          initial: savedThemeMode ?? AdaptiveThemeMode.light,
          debugShowFloatingThemeButton: true,
          builder: (theme, darkTheme) {
            return MaterialApp(
              title: 'CodeCraft',
              theme: theme,
              darkTheme: darkTheme,
              themeMode:
                  MediaQuery.platformBrightnessOf(appContext) == Brightness.dark
                      ? ThemeMode.dark
                      : ThemeMode.light,
              home: FutureBuilder<Widget>(
                future: getLandingPage(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return snapshot.data ?? Container();
                  }

                  return LoadingAnimationWidget.inkDrop(
                      color: Colors.white, size: 100);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class GettingStartedPage extends StatelessWidget {
  const GettingStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/logo.png', width: 200, height: 200),
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
