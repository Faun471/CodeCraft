import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/page.dart';
import 'package:codecraft/screens/loading_screen.dart';
import 'package:codecraft/widgets/cards/module_card.dart';
import 'package:codecraft/widgets/viewers/markdown_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:yaml/yaml.dart';

class Modules extends StatefulWidget {
  const Modules({super.key});

  @override
  ModulesState createState() => ModulesState();
}

class ModulesState extends State<Modules> {
  late int currentLevel = -1;

  @override
  void initState() {
    super.initState();

    currentLevel = AppUser.instance.data!['level'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ModulePage>>(
      future: ModulePage.loadPagesFromYamlDirectory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingAnimationWidget.inkDrop(
            color: AdaptiveTheme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            size: 100,
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return ModuleCard(
              title: snapshot.data![index].title,
              description: snapshot.data![index].description,
              unlockLevel: snapshot.data![index].level,
              imageUrl: snapshot.data![index].image,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoadingScreen(
                        futures: [
                          loadMarkdown(
                            'assets/pages/${snapshot.data![index].markdownName}.md',
                          )
                        ],
                        onDone: (context, snapshot1) async {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MarkdownViewer(
                                  markdownData: snapshot1.data[0]!,
                                  quizName:
                                      'assets/quizzes/${snapshot.data![index].quizName}.yaml'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<String> loadMarkdown(String markdown) async {
    return await rootBundle.loadString(markdown);
  }

  Future<ModulePage> getModulePage(String yaml) async {
    String yamlString = await rootBundle.loadString(yaml);
    Map<String, dynamic> yamlMap =
        Map<String, dynamic>.from(loadYaml(yamlString));

    return ModulePage(
      title: yamlMap['title'],
      description: yamlMap['description'],
      level: yamlMap['level'],
      markdownName: yamlMap['markdownName'],
      image: yamlMap['image'],
      quizName: yamlMap['quizName'],
    );
  }
}
