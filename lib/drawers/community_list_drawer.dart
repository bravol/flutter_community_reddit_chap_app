import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/community_controller.dart';
import 'package:flutter_community_redit_chat_app/core/common/error_text.dart';
import 'package:flutter_community_redit_chat_app/core/loader.dart';
import 'package:flutter_community_redit_chat_app/models/community_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunity(
    BuildContext context,
  ) {
    Routemaster.of(context).push('/create_community');
  }

  void navigateToCommunity(BuildContext context, Community community) {
    Routemaster.of(context).push('/r/${community.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: const Text('Create a community'),
              leading: const Icon(Icons.add),
              onTap: () => navigateToCreateCommunity(context),
            ),
            ref.watch(userCommuintiesControllerProvider).when(
                  data: (communities) => Expanded(
                    child: ListView.builder(
                      itemCount: communities.length,
                      itemBuilder: (BuildContext context, int index) {
                        final community = communities[index];
                        return ListTile(
                          title: Text(
                            'r/${community.name}',
                          ),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(community.avatar),
                          ),
                          onTap: () {
                            navigateToCommunity(context, community);
                          },
                        );
                      },
                    ),
                  ),
                  error: (error, stackTrace) => ErrorText(
                    error: error.toString(),
                  ),
                  loading: () => const Loader(),
                )
          ],
        ),
      ),
    );
  }
}
