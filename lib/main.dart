import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:codecraft/providers/level_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

final globalNavigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  await initDatabase();
  runApp(const MyApp());
}

Future<void> initDatabase() async {
  // Create an instance of DatabaseHelper
  DatabaseHelper();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LevelProvider(),
      child: MaterialApp(
        title: 'CodeCraft',
        navigatorKey: globalNavigatorKey,
        themeMode: MediaQuery.platformBrightnessOf(context) == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          primaryColor: Colors.blue[800],
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            color: Colors.blue[700],
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.blue[700],
            textTheme: ButtonTextTheme.primary,
          ),
          textTheme: TextTheme(
              displayLarge: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: GoogleFonts.poppins().fontFamily),
              displayMedium: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: GoogleFonts.poppins().fontFamily),
              displaySmall: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: GoogleFonts.poppins().fontFamily),
              headlineMedium: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: GoogleFonts.poppins().fontFamily),
              headlineSmall: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: GoogleFonts.poppins().fontFamily),
              titleLarge: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: GoogleFonts.poppins().fontFamily),
              bodyLarge: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontFamily: GoogleFonts.poppins().fontFamily),
              bodyMedium: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontFamily: GoogleFonts.poppins().fontFamily),
              bodySmall: TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                  fontFamily: GoogleFonts.poppins().fontFamily)),
        ),
        home: const MyHomePage(title: 'Getting Started'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

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
              child: const Text(
                'Learn to apply and use your programming concepts!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20, color: Color.fromARGB(255, 89, 89, 89)),
              ),
            ),
            Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Register()),
                    );
                  },
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(60)),
                  child:
                      const Text('Get Started', style: TextStyle(fontSize: 20)),
                ))
          ],
        ),
      ),
    );
  }
}
