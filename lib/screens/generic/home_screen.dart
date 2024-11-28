import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

final GlobalKey _heroSectionKey = GlobalKey();
final GlobalKey _featuresSectionKey = GlobalKey();
final GlobalKey _walkthroughSectionKey = GlobalKey();
final GlobalKey _pricingSectionKey = GlobalKey();

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectableRegion(
        focusNode: FocusNode(),
        selectionControls: MaterialTextSelectionControls(),
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  minHeight: 100.0,
                  maxHeight: 100.0,
                  child: HeaderSection(),
                ),
                pinned: true,
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    HeroSection(key: _heroSectionKey),
                    const SizedBox(height: 40),
                    FeaturesSection(key: _featuresSectionKey),
                    const SizedBox(height: 40),
                    WalkthroughSection(key: _walkthroughSectionKey),
                    const SizedBox(height: 40),
                    PricingSection(key: _pricingSectionKey),
                    const SizedBox(height: 40),
                    FooterSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CodeCraft',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // Replace with github link to binary
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Download",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 20,
                    child: VerticalDivider(color: Colors.black),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Register",
                        style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text("Login"),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Header Text
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.anton(
                height: 1,
              ),
              children: [
                TextSpan(
                  text: "MASTER ",
                  style: TextStyle(
                    fontSize: 124,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: "CODING, ",
                  style: TextStyle(
                      fontSize: 124,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 140, 50)),
                ),
                TextSpan(
                  text: "\nONE CHALLENGE\nAT A TIME!",
                  style: TextStyle(
                    fontSize: 124,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Subtext
        Center(
          child: SizedBox(
            width: 600,
            child: Text(
              "Dive into coding challenges, quizzes, debugging, and code clashes designed to level up your skills while making programming fun and engaging!",
              style: GoogleFonts.anton(
                fontSize: 24,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class FeaturesSection extends StatefulWidget {
  const FeaturesSection({super.key});

  @override
  _FeaturesSectionState createState() => _FeaturesSectionState();
}

class _FeaturesSectionState extends State<FeaturesSection> {
  String selectedFeature = 'assets/images/landing/screens_front.png';

  void updateFeatureImage(String imagePath) {
    setState(() {
      selectedFeature = imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display image of devices with transition
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Image.asset(
              selectedFeature,
              key: ValueKey<String>(selectedFeature),
              fit: BoxFit.contain,
              width: double.infinity,
              height: 500,
            ),
          ),
        ),
        // Features section
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            FeatureChip(
              icon: Icons.devices,
              text: "Multi-Platform Accessibility",
              isSelected:
                  selectedFeature == 'assets/images/landing/screens_front.png',
              onSelected: () =>
                  updateFeatureImage('assets/images/landing/screens_front.png'),
            ),
            FeatureChip(
              icon: Icons.extension,
              text: "Diverse Challenges",
              isSelected:
                  selectedFeature == 'assets/images/landing/challenges.png',
              onSelected: () =>
                  updateFeatureImage('assets/images/landing/challenges.png'),
            ),
            FeatureChip(
              icon: Icons.movie,
              text: "Dynamic Animations",
              isSelected: selectedFeature ==
                  'assets/images/landing/dynamic_animations.png',
              onSelected: () => updateFeatureImage(
                  'assets/images/landing/dynamic_animations.png'),
            ),
            FeatureChip(
              icon: Icons.emoji_events,
              text: "Leaderboards & Rankings",
              isSelected:
                  selectedFeature == 'assets/images/landing/leaderboards.png',
              onSelected: () =>
                  updateFeatureImage('assets/images/landing/leaderboards.png'),
            ),
            FeatureChip(
              icon: Icons.group,
              text: "Mentor-Apprentice Collaboration",
              isSelected:
                  selectedFeature == 'assets/images/landing/screens_side.png',
              onSelected: () =>
                  updateFeatureImage('assets/images/landing/screens_side.png'),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class FeatureChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isSelected;
  final VoidCallback onSelected;

  const FeatureChip({
    super.key,
    required this.icon,
    required this.text,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      child: Chip(
        avatar: Icon(icon, color: isSelected ? Colors.white : Colors.black),
        label: Text(
          text,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
        backgroundColor: isSelected ? Colors.orange : Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }
}

class WalkthroughSection extends StatefulWidget {
  const WalkthroughSection({super.key});

  @override
  createState() => WalkthroughSectionState();
}

class WalkthroughSectionState extends State<WalkthroughSection> {
  VideoPlayerController controller = VideoPlayerController.asset(
    'assets/videos/codecraft-walkthrough.mp4',
    videoPlayerOptions: VideoPlayerOptions(
      webOptions: VideoPlayerWebOptions(
        allowContextMenu: false,
        controls: VideoPlayerWebOptionsControls.enabled(
          allowDownload: false,
          allowPictureInPicture: false,
          allowPlaybackRate: false,
        ),
      ),
    ),
  )..initialize();

  bool isMuted = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.play();
      controller.setVolume(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 400,
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

class PricingSection extends StatefulWidget {
  const PricingSection({super.key});

  @override
  PricingSectionState createState() => PricingSectionState();
}

class PricingSectionState extends State<PricingSection> {
  double _currentSliderValue = 10.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Preview Plans',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Adjust the slider to see the new plan details.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.blue[100],
              inactiveTrackColor: Colors.blue[100],
              thumbColor: Theme.of(context).primaryColor,
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 20,
                elevation: 5,
              ),
            ),
            child: Slider(
              value: _currentSliderValue,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (double value) {
                _currentSliderValue = value;
              },
              onChangeEnd: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
              },
            ),
          ),
          Text(
            '${_currentSliderValue.toInt()} Apprentices - ₱${_currentSliderValue.toInt() * 10} / month',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/register');
            },
            child: Text('Register to Upgrade'),
          ),
        ],
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'CodeCraft',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            '© 2021 CodeCraft. All rights reserved.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
