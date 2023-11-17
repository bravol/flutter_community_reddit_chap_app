import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/community/repository/community_repository.dart';
import 'package:flutter_community_redit_chat_app/core/constants/constants.dart';
import 'package:flutter_community_redit_chat_app/core/utils.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/auth_controller.dart';
import 'package:flutter_community_redit_chat_app/models/community_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

//user communities controller provider
final userCommuintiesControllerProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

//every time we create a stream, we need also a Stream provider for it
final getCommunityByNameControllerProvider =
    StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});

//commuinty controller provider
final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  return CommunityController(
      communityRepository: ref.watch(communityRepositoryProvider), ref: ref);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  CommunityController(
      {required CommunityRepository communityRepository, required Ref ref})
      : _communityRepository = communityRepository,
        _ref = ref,
        super(false);

  //create community
  void createCommunity(String name, BuildContext context) async {
    state = true;
    //getting users id
    final uid = _ref.read(userProvider)?.uid ?? '';

    Community community = Community(
      id: name,
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
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunities(uid);
  }

  //getting community by name
  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }
}
