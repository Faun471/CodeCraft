import 'package:codecraft/models/page.dart';
import 'package:codecraft/screens/module.dart';
import 'package:codecraft/widgets/custom_list_view.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Modules extends StatefulWidget {
  const Modules({super.key});

  @override
  ModulesState createState() => ModulesState();
}

class ModulesState extends State<Modules> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ModulePage>>(
      future: ModulePage.loadPagesFromYamlDirectory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.expand(
            child: LoadingAnimationWidget.inkDrop(
              color: Colors.white,
              size: 100,
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return CustomListItem(
              title: snapshot.data![index].title,
              description: snapshot.data![index].description,
              unlockLevel: snapshot.data![index].level,
              imageUrl: snapshot.data![index].image,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Module(
                      markdown:
                          'assets/pages/${snapshot.data![index].markdownName}.md',
                      quizName:
                          'assets/quizzes/${snapshot.data![index].quizName}.yaml',
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
