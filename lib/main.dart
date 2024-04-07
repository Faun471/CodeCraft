import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:codecraft/firebase_options.dart';
import 'package:codecraft/providers/level_provider.dart';
import 'package:codecraft/providers/theme_provider.dart';
import 'package:codecraft/screens/body.dart';
import 'package:codecraft/screens/register.dart';
import 'package:codecraft/services/auth_helper.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/themes/theme.dart';
import 'package:codecraft/widgets/onboarding_card.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
  
  return userLoggedIn ? const Body() : const OnboardingPage();
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

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    List<Widget> _onBoardingPages = [
      OnboardingCard(
        image: "assets/images/ccOrangeLogo.png",
        title: "Welcome to CodeCraft",
        description:
            "A multiplatform web application for Java and Python using unit tests with dynamic animations.",
        buttonText: "Next",
        onPressed: () {
          _pageController.animateToPage(
            1,
            duration: Durations.long1,
            curve: Curves.linear,
          );
        },
      ),
      OnboardingCard(
        image: "assets/images/onboarding1.png",
        title: "Create an Account",
        description:
            "Sign up to start learning with CodeCraft. We have a lot of challenges and courses for you to learn from.",
        buttonText: "Next",
        onPressed: () {
          _pageController.animateToPage(
            2,
            duration: Durations.long1,
            curve: Curves.linear,
          );
        },
      ),
      OnboardingCard(
        image: "assets/images/onboarding3.png",
        title: "Start Coding Now! 🚀",
        description: "",
        buttonText: "Done",
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Register(),
            ),
          );
        },
      ),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 50.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: PageView(
                  controller: _pageController,
                  children: _onBoardingPages
                    ..lastWhere((element) => element is OnboardingCard)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _onBoardingPages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.orange,
                  dotColor: Colors.orange.shade300,
                ),
                onDotClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: Durations.long1,
                    curve: Curves.linear,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
