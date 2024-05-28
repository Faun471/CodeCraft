import 'package:codecraft/providers/invitation_provider.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ManageRequestsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final invitationProvider = Provider.of<InvitationProvider>(context);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: invitationProvider.getJoinRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingAnimationWidget.flickr(
            leftDotColor: Theme.of(context).primaryColor,
            rightDotColor: Theme.of(context).primaryColorDark,
            size: 100,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No join requests');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var request = snapshot.data![index];
              return ListTile(
                title: Text('Apprentice: ${request['apprenticeId']}'),
                subtitle: Text('Status: ${request['status']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () async {
                        await invitationProvider.updateRequestStatus(
                            request['id'], 'approved');
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () async {
                        await invitationProvider.updateRequestStatus(
                            request['id'], 'rejected');
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
