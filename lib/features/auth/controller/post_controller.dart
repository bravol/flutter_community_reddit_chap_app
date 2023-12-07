import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/core/enums/enums.dart';
import 'package:flutter_community_redit_chat_app/core/providers/storage_repository_provider.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/auth_controller.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/user_profile_controller.dart';
import 'package:flutter_community_redit_chat_app/features/auth/repository/post_repository.dart';
import 'package:flutter_community_redit_chat_app/models/comment_model.dart';
import 'package:flutter_community_redit_chat_app/models/community_model.dart';
import 'package:flutter_community_redit_chat_app/models/post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_community_redit_chat_app/core/utils.dart';

//a stream provider to get comments of the particular post by post id
final getPostCommentsControllerProvider = StreamProvider.family(
  (ref, String postId) =>
      ref.watch(postControllerProvider.notifier).getPostComments(postId),
);

//a stream provider to get post by id
final getPostbyIdControllerProvider = StreamProvider.family(
  (ref, String postId) =>
      ref.watch(postControllerProvider.notifier).getPostById(postId),
);

//stream provider for user posts
final userPostControllerProvider = StreamProvider.family(
    (ref, List<Community> communities) =>
        ref.watch(postControllerProvider.notifier).fetchUserPosts(communities));

//post controller provider
final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);

  return PostController(
      postRepository: postRepository,
      storageRepository: storageRepository,
      ref: ref);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;
  PostController(
      {required PostRepository postRepository,
      required StorageRepository storageRepository,
      required Ref ref})
      : _postRepository = postRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

  //test post
  void shareTextPost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required String description}) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityId: selectedCommunity.id,
      communityProfile: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      username: user.name,
      commentCount: 0,
      uid: user.uid,
      type: 'text',
      createdAt: Timestamp.fromDate(DateTime.now()),
      awards: [],
      description: description,
    );

    final res = await _postRepository.addPost(post);
    //update the karma
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;
    res.fold((l) => showErrorSnackBar(context, l.message), (r) {
      showSuccessSnackBar(context, 'Posted Successfully');
      Routemaster.of(context).pop();
    });
  }

  //link post
  void shareLinkPost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required String link}) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityId: selectedCommunity.id,
      communityProfile: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      username: user.name,
      commentCount: 0,
      uid: user.uid,
      type: 'link',
      createdAt: Timestamp.fromDate(DateTime.now()),
      awards: [],
      link: link,
    );

    final res = await _postRepository.addPost(post);
    //update the karma
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.linkPost);
    state = false;
    res.fold((l) => showErrorSnackBar(context, l.message), (r) {
      showSuccessSnackBar(context, 'Posted Successfully');
      Routemaster.of(context).pop();
    });
  }

  //image post
  void shareImagePost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required File? file}) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final imageRes = await _storageRepository.storeFile(
        path: 'posts/${selectedCommunity.name}', id: postId, file: file);

    imageRes.fold((l) => showErrorSnackBar(context, l.message), (r) async {
      final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityId: selectedCommunity.id,
        communityProfile: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        username: user.name,
        commentCount: 0,
        uid: user.uid,
        type: 'image',
        createdAt: Timestamp.fromDate(DateTime.now()),
        awards: [],
        link: r,
      );

      final res = await _postRepository.addPost(post);
      //update the karma
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);
      state = false;
      res.fold((l) => showErrorSnackBar(context, l.message), (r) {
        showSuccessSnackBar(context, 'Posted Successfully');
        Routemaster.of(context).pop();
      });
    });
  }

  //getting user posts
  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  //delete post
  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);

    //update the karma
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);

    res.fold(
      (l) => showErrorSnackBar(context, l.message),
      (r) => showSuccessSnackBar(context, 'Deleted Successfully'),
    );
  }

  //upvoting
  void upvote(Post post) async {
    final userId = _ref.read(userProvider)!.uid;
    _postRepository.upvote(post, userId);
  }

  //downvote
  void downvote(Post post) async {
    final userId = _ref.read(userProvider)!.uid;
    _postRepository.downvote(post, userId);
  }

  //getting post by id
  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  //add comment
  void addComment(
      {required String text,
      required BuildContext context,
      required Post post}) async {
    state = true;
    final user = _ref.read(userProvider)!;
    const uuid = Uuid();

    Comment comment = Comment(
      id: uuid.v4(),
      text: text,
      createdAt: Timestamp.fromDate(DateTime.now()),
      postId: post.id,
      userName: user.name,
      profilePic: user.profilePicture,
    );

    final res = await _postRepository.addComment(comment);
    //update the karma
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);
    state = false;
    res.fold((l) => showErrorSnackBar(context, l.message),
        (r) => showSuccessSnackBar(context, 'Your comment has been recieved'));
  }

  //getting comments of the particular post
  Stream<List<Comment>> getPostComments(String postId) {
    return _postRepository.getCommentsofPost(postId);
  }

  //sending/gfting award to the opposite user
  void awardPost(
      {required BuildContext context,
      required String award,
      required Post post}) async {
    final user = _ref.read(userProvider)!;

    final res = await _postRepository.awardPost(
        post: post, award: award, senderId: user.uid);

    res.fold((l) => showErrorSnackBar(context, l.message), (r) {
      //updating the user karma of the user sent to
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.awardPost);
      //update the users award of the loggd in user/sender
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }
}
