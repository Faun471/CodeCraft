import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:codecraft/firebase_options.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/providers/theme_provider.dart';
import 'package:codecraft/screens/account_setup/account_setup.dart';
import 'package:codecraft/screens/account_setup/additional_info.dart';
import 'package:codecraft/screens/account_setup/email_verification_screen.dart';
import 'package:codecraft/screens/account_setup/login.dart';
import 'package:codecraft/screens/account_setup/register.dart';
import 'package:codecraft/screens/apprentice/apprentice_home.dart';
import 'package:codecraft/screens/loading_screen.dart';
import 'package:codecraft/screens/mentor/mentor_home.dart';
import 'package:codecraft/services/quiz_service.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/widgets/cards/onboarding_card.dart';
import 'package:context_menus/context_menus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final providerContainer = ProviderContainer();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  QuizService().createQuizzesFromJson('assets/quizzes/quizzes.json', 'Default');

  FirebaseAuth.instance.authStateChanges().listen(
    (User? user) async {
      if (user == null) {
        providerContainer.read(appUserNotifierProvider.notifier).reset();

        if (navigatorKey.currentState == null) return;
        navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AccountSetup(Login()),
          ),
        );
      } else if (!user.emailVerified) {
        String email = user.email!;
        navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(
            builder: (context) => EmailVerifScreen(email: email),
          ),
        );
      }
    },
  );

  runApp(
    UncontrolledProviderScope(
      container: providerContainer,
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

Future<Widget> getLandingPage(AppUser appUserData) async {
  final auth = FirebaseAuth.instance;
  final user = auth.currentUser;

  print('App user data: $appUserData');

  if (user == null) {
    return kIsWeb ? const AccountSetup(Login()) : const OnboardingPage();
  }

  if (!user.emailVerified) {
    return EmailVerifScreen(email: user.email ?? '');
  }

  if (appUserData.firstName == null ||
      appUserData.firstName!.isEmpty ||
      appUserData.lastName == null ||
      appUserData.lastName!.isEmpty ||
      appUserData.phoneNumber == null ||
      appUserData.phoneNumber!.isEmpty) {
    return AccountSetup(AdditionalInfoScreen(user: user));
  }

  String accountType = appUserData.accountType ?? '';

  if (accountType == 'apprentice') {
    return const ApprenticeHome();
  } else if (accountType == 'mentor') {
    return const MentorHome();
  }

  return const AccountSetup(Register());
}

class MyApp extends ConsumerWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider).when(
          data: (data) {
            return data;
          },
          loading: () {
            return ThemeState(
              preferredColor: Colors.orange,
              lightTheme: ThemeUtils.createLightTheme(Colors.orange),
              darkTheme: ThemeUtils.createDarkTheme(Colors.orange),
            );
          },
          error: (error, _) => ThemeState(
            preferredColor: Colors.orange,
            lightTheme: ThemeUtils.createLightTheme(Colors.orange),
            darkTheme: ThemeUtils.createDarkTheme(Colors.orange),
          ),
        );

    return ref.watch(appUserNotifierProvider).when(
      data: (data) {
        return ContextMenuOverlay(
          child: AdaptiveTheme(
            light: currentTheme.lightTheme,
            dark: currentTheme.darkTheme,
            initial: savedThemeMode ?? AdaptiveThemeMode.light,
            builder: (theme, darkTheme) {
              return MaterialApp(
                title: 'CodeCraft',
                theme: theme,
                darkTheme: darkTheme,
                navigatorKey: navigatorKey,
                home: LoadingScreen(
                  futures: [
                    getLandingPage(data),
                  ],
                  onDone: (context, snapshot) async {
                    if (!context.mounted) return;

                    ThemeUtils.changeTheme(
                        context, currentTheme.preferredColor);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => snapshot.data[0],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
      error: (error, _) {
        return const Text(
          'Error loading user data',
          style: TextStyle(color: Colors.red),
        );
      },
      loading: () {
        return LoadingAnimationWidget.flickr(
          leftDotColor: Theme.of(context).primaryColor,
          rightDotColor: Theme.of(context).colorScheme.secondary,
          size: 200,
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
    List<Widget> onBoardingPages = [
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
              builder: (context) => const AccountSetup(
                Register(),
              ),
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
                children: onBoardingPages
                  ..lastWhere((element) => element is OnboardingCard),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: onBoardingPages.length,
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
