import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/page.dart';
import 'package:codecraft/screens/loading_screen.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/viewers/markdown_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:popup_menu_plus/popup_menu_plus.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  List<Offset> levelPositions = const [
    Offset(101.6, 262.8),
    Offset(328.0, 46.0),
    Offset(604.0, 147.6),
    Offset(843.2, -12.4),
    Offset(1064.0, 137.2),
    Offset(1080.0, 382.8),
    Offset(1004.8, 604.4),
    Offset(633.6, 524.4),
    Offset(337.2, 571.6),
    Offset(242.4, 414.0),
    Offset(511.2, 257.2)
  ];

  final double sidebarWidth = 250;
  bool isSmallScreen = false;

  late PopupMenu _menu;

  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    // Set the initial zoom to minimum when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transformationController.value = Matrix4.identity()..scale(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    isSmallScreen = MediaQuery.of(context).size.width < 800;
    return FutureBuilder<List<ModulePage>>(
      future: ModulePage.loadPagesFromYamlDirectory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildMap(snapshot.data!);
        } else {
          return LoadingAnimationWidget.flickr(
            leftDotColor: Theme.of(context).primaryColor,
            rightDotColor: Theme.of(context).primaryColorDark,
            size: 100,
          );
        }
      },
    );
  }

  Widget _buildMap(List<ModulePage> modules) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            InteractiveViewer(
              transformationController: _transformationController,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              constrained: false,
              maxScale: 4.0,
              child: SizedBox(
                width: 1280,
                height: 720,
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: Image.asset(
                        AdaptiveTheme.of(context).mode.isDark
                            ? 'assets/images/map_night.png'
                            : 'assets/images/map.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    ...levelPositions.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Offset pos = entry.value;
                      if (idx < modules.length) {
                        ModulePage module = modules[idx];
                        return Positioned(
                          left: pos.dx,
                          top: pos.dy,
                          child: _buildLevelNode(idx, module),
                        );
                      } else {
                        return Container();
                      }
                    }),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: Container(
                width: 250,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      AdaptiveTheme.of(context).mode.isDark
                          ? 'assets/images/level_bg_night.png'
                          : 'assets/images/level_bg.png',
                    ),
                    fit: BoxFit.scaleDown,
                    scale: 3.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 30,
                    bottom: 30,
                    left: 25,
                    right: 25,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level ${ref.watch(appUserNotifierProvider).value!.level}',
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${ref.watch(appUserNotifierProvider).value!.experience}XP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      LinearProgressIndicator(
                        value: (ref
                                    .watch(appUserNotifierProvider)
                                    .value!
                                    .experience ??
                                0) /
                            100,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.yellow),
                        backgroundColor: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelNode(int idx, ModulePage module) {
    final appUser = ref.watch(appUserNotifierProvider).value;
    int currentLevel = appUser!.level ?? 0;
    bool isUnlocked = currentLevel >= module.level;

    GlobalKey btnKey = GlobalKey();

    return LevelNode(
      key: btnKey,
      level: idx + 1,
      isUnlocked: isUnlocked,
      isCompleted: false,
      title: module.title,
      description: module.description,
      imageUrl: module.image,
      onTap: () {
        SystemSound.play(SystemSoundType.click);
        if (isUnlocked) {
          _showModuleInfoPopup(context, module, btnKey);
        } else {
          Utils.displayDialog(
            context: context,
            title: 'Level Locked',
            content: 'You have not unlocked this level yet!',
            buttonText: 'Okay!',
            lottieAsset: 'assets/anim/locked.json',
            onPressed: () {
              Navigator.pop(context);
            },
          );
        }
      },
    );
  }

  void _showModuleInfoPopup(
    BuildContext context,
    ModulePage module,
    GlobalKey key,
  ) {
    _menu = PopupMenu(
      context: context,
      config: MenuConfig(
        backgroundColor: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        type: MenuType.custom,
        itemHeight: MediaQuery.of(context).size.height * 0.4,
        itemWidth: 300,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.width * 0.2,
          maxWidth: 300,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: module.image,
                    width: double.infinity,
                    height: 75,
                    fit: BoxFit.contain,
                    errorWidget: (context, url, error) {
                      return Container();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        module.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _navigateToModule(context, module);
                          },
                          child: Text(
                            'Start Module',
                            style: TextStyle(
                              color: ThemeUtils.getTextColorForBackground(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _menu.show(widgetKey: key);
  }

  void _navigateToModule(BuildContext context, ModulePage module) {
    if (_menu.isShow) {
      _menu.dismiss();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return LoadingScreen(
            futures: [
              loadMarkdown(
                'assets/pages/${module.markdownName}.md',
              )
            ],
            onDone: (context, snapshot1) async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MarkdownViewer(
                    markdownData: snapshot1.data[0]!,
                    introAnimation: module.introAnimation,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String> loadMarkdown(String markdown) async {
    return await rootBundle.loadString(markdown);
  }
}

class LevelNode extends StatelessWidget {
  final int level;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onTap;
  final String title;
  final String description;
  final String? imageUrl;

  const LevelNode({
    super.key,
    required this.level,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onTap,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 125,
        height: 125,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                AdaptiveTheme.of(context).mode.isDark
                    ? 'assets/images/level_node_night.png'
                    : 'assets/images/level_node.png',
                fit: BoxFit.cover,
                color: isUnlocked ? null : Colors.grey,
                colorBlendMode: BlendMode.saturation,
              ),
            ),
            Text(
              '$level',
              style: GoogleFonts.vampiroOne(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.yellow : Colors.black45,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: isUnlocked ? Colors.black : Colors.grey,
                    offset: const Offset(5.0, 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
