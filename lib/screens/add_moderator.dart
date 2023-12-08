import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/community_controller.dart';
import 'package:flutter_community_redit_chat_app/core/common/error_text.dart';
import 'package:flutter_community_redit_chat_app/core/loader.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/auth_controller.dart';
import 'package:flutter_community_redit_chat_app/responsive/responsive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddModeratorScreen extends ConsumerStatefulWidget {
  const AddModeratorScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddModeratorScreenState();
}

class _AddModeratorScreenState extends ConsumerState<AddModeratorScreen> {
  //using set means you cannot have repeating values
  Set<String> uids = {};

  var counter = 0;
  //adding uid
  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  //remove uids
  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  // save moderator
  void saveModerators() {
    ref
        .read(communityControllerProvider.notifier)
        .addModerator(widget.id, uids.toList(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: saveModerators, icon: const Icon(Icons.done))
        ],
      ),
      body: ref.watch(getCommunityByIdControllerProvider(widget.id)).when(
          data: (community) => Responsive(
                child: ListView.builder(
                    itemCount: community.members.length,
                    itemBuilder: (BuildContext context, int index) {
                      final memberId = community.members[index];

                      return ref.watch(getUserDataProvider(memberId)).when(
                          data: (userData) {
                            if (community.mods.contains(memberId) &&
                                counter == 0) {
                              uids.add(memberId);
                            }
                            counter++;
                            return CheckboxListTile(
                              value: uids.contains(memberId),
                              onChanged: (val) {
                                if (val!) {
                                  addUid(memberId);
                                } else {
                                  removeUid(memberId);
                                }
                              },
                              title: Text(userData.name),
                            );
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () => const Loader());
                    }),
              ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader()),
    );
  }
}
