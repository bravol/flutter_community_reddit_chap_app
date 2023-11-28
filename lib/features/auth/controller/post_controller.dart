import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/core/providers/storage_repository_provider.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/auth_controller.dart';
import 'package:flutter_community_redit_chat_app/features/auth/repository/post_repository.dart';
import 'package:flutter_community_redit_chat_app/models/community_model.dart';
import 'package:flutter_community_redit_chat_app/models/post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_community_redit_chat_app/core/utils.dart';

//controller provider
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
    state = false;
    res.fold((l) => showErrorSnackBar(context, l.message), (r) {
      showSuccessSnackBar(context, 'Posed Successfully');
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
    state = false;
    res.fold((l) => showErrorSnackBar(context, l.message), (r) {
      showSuccessSnackBar(context, 'Posed Successfully');
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
      state = false;
      res.fold((l) => showErrorSnackBar(context, l.message), (r) {
        showSuccessSnackBar(context, 'Posed Successfully');
        Routemaster.of(context).pop();
      });
    });
  }
}
