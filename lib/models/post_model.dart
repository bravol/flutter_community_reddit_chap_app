import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Post {
  final String id;
  final String title;
  final String? link;
  final String? description;
  final String communityName;
  final String communityId;
  final String communityProfile;
  final List<String> upvotes;
  final List<String> downvotes;
  final String username;
  final int commentCount;
  final String uid;
  final String type;
  final Timestamp createdAt;
  final List<String> awards;
  Post({
    required this.id,
    required this.title,
    this.link,
    this.description,
    required this.communityName,
    required this.communityId,
    required this.communityProfile,
    required this.upvotes,
    required this.downvotes,
    required this.username,
    required this.commentCount,
    required this.uid,
    required this.type,
    required this.createdAt,
    required this.awards,
  });

  Post copyWith({
    String? id,
    String? title,
    String? link,
    String? description,
    String? communityName,
    String? communityId,
    String? communityProfile,
    List<String>? upvotes,
    List<String>? downvotes,
    String? username,
    int? commentCount,
    String? uid,
    String? type,
    Timestamp? createdAt,
    List<String>? awards,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      description: description ?? this.description,
      communityName: communityName ?? this.communityName,
      communityId: communityId ?? this.communityId,
      communityProfile: communityProfile ?? this.communityProfile,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      username: username ?? this.username,
      commentCount: commentCount ?? this.commentCount,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'title': title});
    if (link != null) {
      result.addAll({'link': link});
    }
    if (description != null) {
      result.addAll({'description': description});
    }
    result.addAll({'communityName': communityName});
    result.addAll({'communityId': communityId});
    result.addAll({'communityProfile': communityProfile});
    result.addAll({'upvotes': upvotes});
    result.addAll({'downvotes': downvotes});
    result.addAll({'username': username});
    result.addAll({'commentCount': commentCount});
    result.addAll({'uid': uid});
    result.addAll({'type': type});
    result.addAll({'createdAt': createdAt});
    result.addAll({'awards': awards});

    return result;
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      link: map['link'],
      description: map['description'],
      communityName: map['communityName'] ?? '',
      communityId: map['communityId'] ?? '',
      communityProfile: map['communityProfile'] ?? '',
      upvotes: List<String>.from(map['upvotes'] ?? []),
      downvotes: List<String>.from(map['downvotes'] ?? []),
      username: map['username'] ?? '',
      commentCount: map['commentCount']?.toInt() ?? 0,
      uid: map['uid'] ?? '',
      type: map['type'] ?? '',
      createdAt: map['createdAt'] ?? '',
      awards: List<String>.from(map['awards'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Post(id: $id, title: $title, link: $link, description: $description, communityName: $communityName, communityId: $communityId, communityProfile: $communityProfile, upvotes: $upvotes, downvotes: $downvotes, username: $username, commentCount: $commentCount, uid: $uid, type: $type, createdAt: $createdAt, awards: $awards)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Post &&
        other.id == id &&
        other.title == title &&
        other.link == link &&
        other.description == description &&
        other.communityName == communityName &&
        other.communityId == communityId &&
        other.communityProfile == communityProfile &&
        listEquals(other.upvotes, upvotes) &&
        listEquals(other.downvotes, downvotes) &&
        other.username == username &&
        other.commentCount == commentCount &&
        other.uid == uid &&
        other.type == type &&
        other.createdAt == createdAt &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        link.hashCode ^
        description.hashCode ^
        communityName.hashCode ^
        communityId.hashCode ^
        communityProfile.hashCode ^
        upvotes.hashCode ^
        downvotes.hashCode ^
        username.hashCode ^
        commentCount.hashCode ^
        uid.hashCode ^
        type.hashCode ^
        createdAt.hashCode ^
        awards.hashCode;
  }
}
