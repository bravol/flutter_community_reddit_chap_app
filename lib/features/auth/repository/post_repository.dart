import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community_redit_chat_app/core/constants/firebase_constants.dart';
import 'package:flutter_community_redit_chat_app/core/failure.dart';
import 'package:flutter_community_redit_chat_app/core/providers/firebase_provider.dart';
import 'package:flutter_community_redit_chat_app/core/type_def.dart';
import 'package:flutter_community_redit_chat_app/models/comment_model.dart';
import 'package:flutter_community_redit_chat_app/models/community_model.dart';
import 'package:flutter_community_redit_chat_app/models/post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

//a provider
final postRepositoryProvider = Provider((ref) {
  return PostRepository(firestore: ref.watch(firestoreProvider));
});

class PostRepository {
  final FirebaseFirestore _firestore;
  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _postsCollection =>
      _firestore.collection(FirebaseConstants.postsCollection);
  //commnets collection
  CollectionReference get _commentsCollection =>
      _firestore.collection(FirebaseConstants.commentsCollection);

  //a function to add post to database
  FutureVoid addPost(Post post) async {
    try {
      return right(_postsCollection.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //fetcing posts
  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    return _postsCollection
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  //deleting the post.
  FutureVoid deletePost(Post post) async {
    try {
      return right(_postsCollection.doc(post.id).delete());
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //upvoting
  void upvote(Post post, String userId) async {
    if (post.downvotes.contains(userId)) {
      _postsCollection.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId])
      });
    }

    if (post.upvotes.contains(userId)) {
      _postsCollection.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId])
      });
    } else {
      _postsCollection.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([userId])
      });
    }
  }

  //downvoting
  void downvote(Post post, String userId) async {
    if (post.upvotes.contains(userId)) {
      _postsCollection.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId])
      });
    }

    if (post.downvotes.contains(userId)) {
      _postsCollection.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId])
      });
    } else {
      _postsCollection.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([userId])
      });
    }
  }

  //get the post by id
  // Future<Either<Failure, Post>> getPostById(String id) async {}
  Stream<Post> getPostById(String postId) {
    return _postsCollection.doc(postId).snapshots().map(
          (event) => Post.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  //a function to add comment to database
  FutureVoid addComment(Comment comment) async {
    try {
      await _commentsCollection.doc(comment.id).set(comment.toMap());
      return right(_postsCollection.doc(comment.postId).update({
        'commentCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //getting the comments

  //fetcing posts
  Stream<List<Comment>> getCommentsofPost(String postId) {
    return _commentsCollection
        .where(
          'postId',
          isEqualTo: postId,
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Comment.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }
}
