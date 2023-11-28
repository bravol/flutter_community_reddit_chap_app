import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/community/repository/community_repository.dart';
import 'package:flutter_community_redit_chat_app/core/constants/constants.dart';
import 'package:flutter_community_redit_chat_app/core/failure.dart';
import 'package:flutter_community_redit_chat_app/core/providers/storage_repository_provider.dart';
import 'package:flutter_community_redit_chat_app/core/utils.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/auth_controller.dart';
import 'package:flutter_community_redit_chat_app/models/community_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

// stream user communities controller provider
final userCommuintiesControllerProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

//stream search community
final searchCommunityProvider = StreamProvider.family((ref, String query) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.searchCommunity(query);
});

//every time we create a stream, we need also a Stream provider for it
final getCommunityByIdControllerProvider =
    StreamProvider.family((ref, String id) {
  return ref.watch(communityControllerProvider.notifier).getCommunityByName(id);
});

//commuinty controller provider
final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return CommunityController(
    communityRepository: communityRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;
  CommunityController(
      {required CommunityRepository communityRepository,
      required StorageRepository storageRepository,
      required Ref ref})
      : _communityRepository = communityRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

  //create community
  void createCommunity(String name, BuildContext context) async {
    state = true;
    //getting users id
    final uid = _ref.read(userProvider)?.uid ?? '';
    const uuid = Uuid();
    final id = uuid.v4();
    Community community = Community(
      id: id,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );
    final res = await _communityRepository.createCommunity(community);
    state = false;
    //error message and success message
    res.fold((l) => showErrorSnackBar(context, l.message), (r) {
      showSuccessSnackBar(context, 'Community created successfully!');
      Routemaster.of(context).pop();
    });
  }

  //getting user communities
  Stream<List<Community>> getUserCommunities() {
    //current user id
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunities(uid);
  }

  //getting community by name
  Stream<Community> getCommunityByName(String id) {
    return _communityRepository.getCommunityByName(id);
  }

//editing the community profile pic
  void editCommunity(
      {required File? profileFile,
      required File? bannerFile,
      required BuildContext context,
      required Community community}) async {
    state = true;
    //profile picture
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
          path: 'communities/profile', id: community.name, file: profileFile);

      res.fold((l) => showErrorSnackBar(context, l.message),
          (r) => community = community.copyWith(avatar: r));
    }
    //banner
    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
          path: 'communities/banner', id: community.name, file: bannerFile);

      res.fold(
        (l) => showErrorSnackBar(context, l.message),
        (r) => community = community.copyWith(banner: r),
      );
    }

    final res = await _communityRepository.editCommunity(community);

    state = false; //for loading indicator

    res.fold((l) => showErrorSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  //search community
  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  //join community
  void leaveOrJoinCommunity(BuildContext context, Community community) async {
    // getting the user id
    final user = _ref.read(userProvider)!;

    Either<Failure, void> res;
    if (community.members.contains(user.uid)) {
      res = await _communityRepository.leaveCommunity(community.id, user.uid);
    } else {
      res = await _communityRepository.joinCommunity(community.id, user.uid);
    }

    res.fold((l) => showErrorSnackBar(context, l.message), (r) {
      if (community.members.contains(user.uid)) {
        showSuccessSnackBar(context, 'You left the community successfully');
      } else {
        showSuccessSnackBar(
            context, 'You have Joined the community successfully');
      }
    });
  }

  //add moderator
  void addModerator(
      String communityId, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addModerator(communityId, uids);
    res.fold((l) => showErrorSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }
}
