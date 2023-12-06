import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/core/providers/storage_repository_provider.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/auth_controller.dart';
import 'package:flutter_community_redit_chat_app/features/auth/repository/user_profile_repository.dart';
import 'package:flutter_community_redit_chat_app/models/post_model.dart';
import 'package:flutter_community_redit_chat_app/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_community_redit_chat_app/core/utils.dart';

//stream provider to get user posts
final getUserPostsControllerProvider = StreamProvider.family(
  (ref, String uid) =>
      ref.read(userProfileControllerProvider.notifier).getUserPosts(uid),
);

//user controller provider
final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final userProfileRepository = ref.watch(userProfileRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return UserProfileController(
    userProfileRepository: userProfileRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;
  UserProfileController({
    required UserProfileRepository userProfileRepository,
    required StorageRepository storageRepository,
    required Ref ref,
  })  : _userProfileRepository = userProfileRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

  //edit user profile.
  void editUserprofile(
      {required File? profileFile,
      required File? bannerFile,
      required BuildContext context,
      required String name}) async {
    state = true;

    UserModel user = _ref.read(userProvider)!;
    const uuid = Uuid();
    final id = uuid.v4();

    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'users/profile',
        id: user.name + id,
        file: profileFile,
      );

      res.fold((l) => showErrorSnackBar(context, l.message),
          (r) => user = user.copyWith(profilePicture: r));
    }
    //banner
    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'users/user_banner',
        id: user.name + id,
        file: bannerFile,
      );

      res.fold(
        (l) => showErrorSnackBar(context, l.message),
        (r) => user = user.copyWith(banner: r),
      );
    }
    user = user.copyWith(name: name);
    final res = await _userProfileRepository.editProfile(user);
    state = false;
    res.fold((l) => showErrorSnackBar(context, l.message), (r) {
      //update the userState provider with the new provider
      _ref.read(userProvider.notifier).update((state) => user);
      Routemaster.of(context).pop();
    });
  }

  //getting users posts
  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }
}
