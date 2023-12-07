import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/auth_controller.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/community_controller.dart';
import 'package:flutter_community_redit_chat_app/core/common/error_text.dart';
import 'package:flutter_community_redit_chat_app/core/common/post_card.dart';
import 'package:flutter_community_redit_chat_app/core/loader.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/post_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    if (!isGuest) {
      return ref.watch(userCommuintiesControllerProvider).when(
            data: (communities) =>
                ref.watch(userPostControllerProvider(communities)).when(
                    data: (data) => ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          final post = data[index];
                          return PostCard(post: post);
                        }),
                    error: (error, stackTrace) {
                      // print(error);
                      return (ErrorText(error: error.toString()));
                    },
                    loading: () => const Loader()),
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          );
    }

    return ref.watch(userCommuintiesControllerProvider).when(
          data: (communities) => ref.watch(guestPostControllerProvider).when(
              data: (data) => ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final post = data[index];
                    return PostCard(post: post);
                  }),
              error: (error, stackTrace) {
                return (ErrorText(error: error.toString()));
              },
              loading: () => const Loader()),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
