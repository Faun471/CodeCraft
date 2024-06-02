import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/providers/invitation_provider.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/services/invitation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
        } else {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FutureBuilder(
                      future: InvitationService().getCurrentCode(
                          DatabaseHelper().auth.currentUser!.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return CircularProgressIndicator();
                        } else {
                          return Text('Code: ${snapshot.data}');
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await invitationProvider.createNewInvitation(
                            DatabaseHelper().auth.currentUser!.uid,
                            AppUser.instance.data['orgId']);
                      },
                      child: Text('Generate Code'),
                    ),
                  ),
                ],
              ),
              if (!snapshot.data!.isEmpty)
                ListView.builder(
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
                ),
            ],
          );
        }
      },
    );
  }
}
