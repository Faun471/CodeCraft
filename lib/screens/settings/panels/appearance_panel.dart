import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:codecraft/providers/theme_provider.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppearancePanel extends ConsumerStatefulWidget {
  const AppearancePanel({super.key});

  @override
  _AppearancePanelState createState() => _AppearancePanelState();
}

class _AppearancePanelState extends ConsumerState<AppearancePanel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          _buildColourSchemeSection(),
          const SizedBox(height: 20),
          _buildLightDarkModeSection(),
        ],
      ),
    );
  }

  Widget _buildColourSchemeSection() {
    // Define a color map with gradients (from darkest to lightest shades)
    Map<String, List<Color>> colourGradients = {
      'Red': [
        Colors.red[900]!,
        Colors.red[700]!,
        Colors.red[500]!,
        Colors.red[300]!,
        Colors.red[100]!
      ],
      'Orange': [
        Colors.orange[900]!,
        Colors.orange[700]!,
        Colors.orange[500]!,
        Colors.orange[300]!,
        Colors.orange[100]!
      ],
      'Yellow': [
        Colors.yellow[900]!,
        Colors.yellow[700]!,
        Colors.yellow[500]!,
        Colors.yellow[300]!,
        Colors.yellow[100]!
      ],
      'Green': [
        Colors.green[900]!,
        Colors.green[700]!,
        Colors.green[500]!,
        Colors.green[300]!,
        Colors.green[100]!
      ],
      'Blue': [
        Colors.blue[900]!,
        Colors.blue[700]!,
        Colors.blue[500]!,
        Colors.blue[300]!,
        Colors.blue[100]!
      ],
      'Indigo': [
        Colors.indigo[900]!,
        Colors.indigo[700]!,
        Colors.indigo[500]!,
        Colors.indigo[300]!,
        Colors.indigo[100]!
      ],
      'Violet': [
        Colors.purple[900]!,
        Colors.purple[700]!,
        Colors.purple[500]!,
        Colors.purple[300]!,
        Colors.purple[100]!
      ],
    };

    Color selectedColor =
        ref.watch(themeNotifierProvider).value!.preferredColor;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: colourGradients.length,
      itemBuilder: (context, index) {
        final colorEntry = colourGradients.entries.elementAt(index);
        final colorName = colorEntry.key;
        final colorShades = colorEntry.value;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                colorName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(colorShades.length, (shadeIndex) {
                  final shade = colorShades[shadeIndex];

                  return Flexible(
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(themeNotifierProvider.notifier)
                            .updateColor(shade); // Update to the selected shade
                        ThemeUtils.changeTheme(context, shade);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width /
                                colorShades.length -
                            10, // Dynamic segment width
                        height: 50,
                        decoration: BoxDecoration(
                          color: shade,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(shadeIndex == 0 ? 25 : 0),
                            bottomLeft:
                                Radius.circular(shadeIndex == 0 ? 25 : 0),
                            topRight: Radius.circular(
                                shadeIndex == colorShades.length - 1 ? 25 : 0),
                            bottomRight: Radius.circular(
                                shadeIndex == colorShades.length - 1 ? 25 : 0),
                          ),
                          border: Border.all(
                            color: selectedColor == shade
                                ? Colors.black
                                : Colors
                                    .transparent, // Highlight selected shade
                            width: 2,
                          ),
                        ),
                        child: selectedColor == shade
                            ? Icon(
                                Icons.check,
                                color:
                                    ThemeUtils.getTextColorForBackground(shade),
                              ) // Show checkmark on selected shade
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLightDarkModeSection() {
    String themeMode = AdaptiveTheme.of(context).mode.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Mode',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        RadioListTile<String>(
          title: const Text('Light Mode'),
          value: 'light',
          groupValue: themeMode,
          onChanged: (value) {
            setState(() {
              themeMode = value!;
              AdaptiveTheme.of(context).setLight();
            });
          },
          selected: themeMode == 'light',
        ),
        RadioListTile<String>(
          title: const Text('Dark Mode'),
          value: 'dark',
          groupValue: themeMode,
          onChanged: (value) {
            setState(() {
              themeMode = value!;
              AdaptiveTheme.of(context).setDark();
            });
          },
          selected: themeMode == 'dark',
        ),
        RadioListTile<String>(
          title: const Text('System Mode'),
          value: 'system',
          groupValue: themeMode,
          onChanged: (value) {
            setState(() {
              themeMode = value!;
              AdaptiveTheme.of(context).setSystem();
            });
          },
          selected: themeMode == 'system',
        ),
      ],
    );
  }
}
