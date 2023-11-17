import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community_redit_chat_app/core/constants/firebase_constants.dart';
import 'package:flutter_community_redit_chat_app/core/failure.dart';
import 'package:flutter_community_redit_chat_app/core/providers/firebase_provider.dart';
import 'package:flutter_community_redit_chat_app/core/type_def.dart';
import 'package:flutter_community_redit_chat_app/models/community_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communitiesCollection.doc(community.name).get();

      if (communityDoc.exists) {
        throw 'community with the same name already exists';
      }
      return right(await _communitiesCollection
          .doc(community.name)
          .set(community.toMap()));
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

//create community collection
  CollectionReference get _communitiesCollection =>
      _firestore.collection(FirebaseConstants.communitiesCollection);

  //getting users communities
  Stream<List<Community>> getUserCommunities(String uid) {
    return _communitiesCollection
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  //getting community by name.
  Stream<Community> getCommunityByName(String name) {
    return _communitiesCollection.doc(name).snapshots().map(
        (event) => Community.fromMap(event.data() as Map<String, dynamic>));
  }
}
