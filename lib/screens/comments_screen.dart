import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/core/common/error_text.dart';
import 'package:flutter_community_redit_chat_app/core/common/post_card.dart';
import 'package:flutter_community_redit_chat_app/core/loader.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/post_controller.dart';
import 'package:flutter_community_redit_chat_app/models/post_model.dart';
import 'package:flutter_community_redit_chat_app/responsive/responsive.dart';
import 'package:flutter_community_redit_chat_app/widgets/comment_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/controller/auth_controller.dart';

class CommentScreen extends ConsumerStatefulWidget {
  const CommentScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final commentController = TextEditingController();

//dispose method to clean incase of the controller
  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

// add comment
  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
          text: commentController.text.trim(),
          context: context,
          post: post,
        );

    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostbyIdControllerProvider(widget.postId)).when(
            data: (post) {
              return Column(
                children: [
                  PostCard(post: post),
                  if (!isGuest)
                    Responsive(
                      child: TextField(
                        onSubmitted: (val) => addComment(post),
                        controller: commentController,
                        decoration: const InputDecoration(
                            hintText: 'What is your thought',
                            filled: true,
                            border: InputBorder.none),
                      ),
                    ),
                  ref
                      .watch(getPostCommentsControllerProvider(widget.postId))
                      .when(
                        data: (comments) => Expanded(
                          child: ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (BuildContext context, int index) {
                              return CommentCard(comment: comments[index]);
                            },
                          ),
                        ),
                        error: (error, stackTrace) {
                          // print(error.toString());
                          return ErrorText(error: error.toString());
                        },
                        loading: () => const Loader(),
                      )
                ],
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
