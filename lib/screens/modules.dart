import 'package:codecraft/models/page.dart';
import 'package:codecraft/screens/module.dart';
import 'package:codecraft/widgets/custom_list_view.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Modules extends StatelessWidget {
  const Modules({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modules'),
      ),
      body: FutureBuilder<List<CustomPage>>(
        future: CustomPage.loadPagesFromYamlDirectory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 200,
              ),
            );
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return CustomListItem(
                title: snapshot.data![index].title,
                description: snapshot.data![index].description,
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
                unlockLevel: snapshot.data![index].level,
                imageUrl: snapshot.data![index].image,
              );
            },
          );
        },
      ),
    );
  }
}
