import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_community_redit_chat_app/core/constants/firebase_constants.dart';
import 'package:flutter_community_redit_chat_app/core/failure.dart';
import 'package:flutter_community_redit_chat_app/core/providers/firebase_provider.dart';
import 'package:flutter_community_redit_chat_app/core/type_def.dart';
import 'package:flutter_community_redit_chat_app/models/community_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(
      firestore: ref.watch(firestoreProvider), auth: ref.watch(authProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  CommunityRepository(
      {required FirebaseFirestore firestore, required FirebaseAuth auth})
      : _firestore = firestore,
        _auth = auth;

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communitiesCollection.doc(community.name).get();

      if (communityDoc.exists) {
        throw 'community with the same name already exists';
      }
      return right(await _communitiesCollection
          .doc(community.id)
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
  Stream<List<Community>> getUserCommunities() {
    return _communitiesCollection
        .where('members', arrayContains: _auth.currentUser!.uid)
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
  Stream<Community> getCommunityByName(String accountId) {
    return _communitiesCollection.doc(accountId).snapshots().map((event) {
      return Community.fromMap(event.data() as Map<String, dynamic>);
    }).handleError((error) {
      print("Error fetching account: $error");
      return null;
    });
  }

//editing the community
  FutureVoid editCommunity(Community community) async {
    try {
      return right(
          _communitiesCollection.doc(community.id).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //search community
  Stream<List<Community>> searchCommunity(String query) {
    return _communitiesCollection
        .where('name',
            isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
            isLessThan: query.isEmpty
                ? null
                : query.substring(0, query.length - 1) +
                    String.fromCharCode(query.codeUnitAt(query.length - 1) + 1))
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  //join community
  FutureVoid joinCommunity(String communityId, String userId) async {
    try {
      return right(_communitiesCollection.doc(communityId).update({
        'members': FieldValue.arrayUnion([userId])
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //leave community
  FutureVoid leaveCommunity(String communityId, String userId) async {
    try {
      return right(_communitiesCollection.doc(communityId).update({
        'members': FieldValue.arrayRemove([userId])
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //saving new list of moderators
  FutureVoid addModerator(String communityId, List<String> uids) async {
    try {
      return right(
          _communitiesCollection.doc(communityId).update({'mods': uids}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
