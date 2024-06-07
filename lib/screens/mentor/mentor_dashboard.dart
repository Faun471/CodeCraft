import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smooth_list_view/smooth_list_view.dart';

class MentorDashboard extends ConsumerStatefulWidget {
  const MentorDashboard({super.key});

  @override
  _MentorDashboardState createState() => _MentorDashboardState();
}

class _MentorDashboardState extends ConsumerState<MentorDashboard> {
  @override
  Widget build(BuildContext context) {
    final orgId = ref.watch(appUserNotifierProvider).requireValue.orgId!;

    return FutureBuilder(
        future: DatabaseHelper().getOrganizationMembers(orgId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: LoadingAnimationWidget.flickr(
                leftDotColor: Theme.of(context).primaryColor,
                rightDotColor: Theme.of(context).colorScheme.secondary,
                size: MediaQuery.of(context).size.width * 0.1,
              ),
            );
          }

          List<Map<String, dynamic>> members =
              snapshot.data as List<Map<String, dynamic>>;

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Welcome to the Mentor Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SmoothListView.builder(
                  shrinkWrap: true,
                  duration: const Duration(milliseconds: 200),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Row(
                        children: [
                          ClipOval(
                            child: CachedNetworkImage(
                              width: 40,
                              height: 40,
                              imageUrl: members[index]['photoURL'] ?? '',
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person_2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(members[index]['displayName'] ?? ''),
                        ],
                      ),
                      subtitle: Text(members[index]['email'] ?? ''),
                    );
                  },
                ),
              ],
            ),
          );
        });
  }
}
