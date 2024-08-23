import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

class ModulePage {
  final String title;
  final String description;
  final int level;
  final String image;
  final String markdownName;

  ModulePage({
    required this.title,
    required this.description,
    required this.level,
    required this.markdownName, 
    required this.image,
  });

  static Future<List<ModulePage>> loadPagesFromYamlDirectory() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final pageKeys = json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith('assets/pages'))
        .where((String key) => key.endsWith('.yaml'))
        .toList();

    List<ModulePage> pages = [];

    for (var key in pageKeys) {
      String yamlString = await rootBundle.loadString(key);
      Map<String, dynamic> yamlMap =
          Map<String, dynamic>.from(loadYaml(yamlString));

      pages.add(ModulePage(
        title: yamlMap['title'],
        description: yamlMap['description'],
        level: yamlMap['level'],
        markdownName: yamlMap['markdownName'],
        image: yamlMap['image'],
      ));
    }

    pages.sort((a, b) => a.level.compareTo(b.level));
    return pages;
  }
}
