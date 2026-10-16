import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/chat_service.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final ChatService _chatService =
      ChatService();

  final TextEditingController
      _searchController =
      TextEditingController();

  String _searchQuery = '';

  String get _currentUserId {
    return _auth.currentUser?.uid ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId.isEmpty) {
      return _firebaseRequired();
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            14.h,
            16.w,
            10.h,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery =
                    value
                        .trim()
                        .toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText:
                  'Search name or email',
              prefixIcon:
                  const Icon(
                Icons.search,
              ),
              suffixIcon:
                  _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController
                                .clear();

                            FocusScope.of(
                              context,
                            ).unfocus();

                            setState(() {
                              _searchQuery =
                                  '';
                            });
                          },
                          icon:
                              const Icon(
                            Icons.close,
                          ),
                        ),
              filled: true,
              fillColor:
                  Theme.of(context)
                      .cardColor,
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  14.r,
                ),
                borderSide:
                    BorderSide.none,
              ),
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  14.r,
                ),
                borderSide:
                    BorderSide.none,
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  14.r,
                ),
                borderSide:
                    const BorderSide(
                  color: Color(
                    0xFFFFB91F,
                  ),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<
              QuerySnapshot<
                  Map<String, dynamic>>>(
            stream: _firestore
                .collection('users')
                .snapshots(),
            builder: (
              context,
              snapshot,
            ) {
              if (snapshot.hasError) {
                return _errorState(
                  snapshot.error,
                );
              }

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              final documents =
                  snapshot.data?.docs ??
                      [];

              final users =
                  documents.where(
                (document) {
                  if (document.id ==
                      _currentUserId) {
                    return false;
                  }

                  final data =
                      document.data();

                  final firstName =
                      (data['firstName'] ??
                              '')
                          .toString();

                  final lastName =
                      (data['lastName'] ??
                              '')
                          .toString();

                  final username =
                      (data['username'] ??
                              '')
                          .toString();

                  final email =
                      (data['email'] ??
                              '')
                          .toString();

                  if (_searchQuery
                      .isEmpty) {
                    return true;
                  }

                  final fullName =
                      '$firstName $lastName'
                          .trim()
                          .toLowerCase();

                  return fullName
                          .contains(
                        _searchQuery,
                      ) ||
                      username
                          .toLowerCase()
                          .contains(
                            _searchQuery,
                          ) ||
                      email
                          .toLowerCase()
                          .contains(
                            _searchQuery,
                          );
                },
              ).toList();

              users.sort(
                (
                  first,
                  second,
                ) {
                  final firstData =
                      first.data();

                  final secondData =
                      second.data();

                  final firstName =
                      _displayName(
                    firstData,
                  ).toLowerCase();

                  final secondName =
                      _displayName(
                    secondData,
                  ).toLowerCase();

                  return firstName
                      .compareTo(
                    secondName,
                  );
                },
              );

              if (users.isEmpty) {
                return _emptyState();
              }

              return ListView.separated(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior
                        .onDrag,
                padding:
                    EdgeInsets.fromLTRB(
                  16.w,
                  4.h,
                  16.w,
                  20.h,
                ),
                itemCount:
                    users.length,
                separatorBuilder: (
                  context,
                  index,
                ) {
                  return SizedBox(
                    height: 10.h,
                  );
                },
                itemBuilder: (
                  context,
                  index,
                ) {
                  return _userCard(
                    users[index],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _displayName(
    Map<String, dynamic> data,
  ) {
    final firstName =
        (data['firstName'] ?? '')
            .toString()
            .trim();

    final lastName =
        (data['lastName'] ?? '')
            .toString()
            .trim();

    final username =
        (data['username'] ?? '')
            .toString()
            .trim();

    final email =
        (data['email'] ?? '')
            .toString()
            .trim();

    final fullName =
        '$firstName $lastName'
            .trim();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    if (username.isNotEmpty) {
      return username;
    }

    if (email.isNotEmpty) {
      return email;
    }

    return 'Firebase User';
  }

  Widget _userCard(
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        document,
  ) {
    final data =
        document.data();

    final username =
        (data['username'] ?? '')
            .toString()
            .trim();

    final email =
        (data['email'] ?? '')
            .toString()
            .trim();

    final image =
        (data['image'] ?? '')
            .toString()
            .trim();

    final displayName =
        _displayName(data);

    return Material(
      color: Theme.of(context)
          .cardColor,
      borderRadius:
          BorderRadius.circular(
        14.r,
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          14.r,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (
                context,
              ) {
                return ChatDetailScreen(
                  receiverId:
                      document.id,
                  receiverName:
                      displayName,
                  receiverEmail:
                      email,
                  receiverImage:
                      image,
                );
              },
            ),
          );
        },
        child: Container(
          padding:
              EdgeInsets.all(
            12.r,
          ),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              14.r,
            ),
            boxShadow:
                const [
              BoxShadow(
                color: Color(
                  0x10000000,
                ),
                blurRadius: 8,
                offset: Offset(
                  0,
                  2,
                ),
              ),
            ],
          ),
          child: Row(
            children: [
              _avatar(
                image,
                displayName,
              ),
              SizedBox(
                width: 12.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        fontSize:
                            14.sp,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                    if (username
                        .isNotEmpty) ...[
                      SizedBox(
                        height: 2.h,
                      ),
                      Text(
                        '@$username',
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            TextStyle(
                          fontSize:
                              11.sp,
                          color:
                              const Color(
                            0xFFE69B00,
                          ),
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                    ],
                    if (email
                        .isNotEmpty) ...[
                      SizedBox(
                        height: 2.h,
                      ),
                      Text(
                        email,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            TextStyle(
                          fontSize:
                              10.sp,
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              StreamBuilder<int>(
                stream: _chatService
                    .getUnreadCount(
                  document.id,
                ),
                initialData: 0,
                builder: (
                  context,
                  snapshot,
                ) {
                  final unreadCount =
                      snapshot.data ?? 0;

                  return Stack(
                    clipBehavior:
                        Clip.none,
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFFFB91F,
                          ).withValues(
                            alpha: 0.15,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10.r,
                          ),
                        ),
                        child: Icon(
                          Icons
                              .chat_bubble_outline,
                          size: 19.sp,
                          color:
                              const Color(
                            0xFFE69B00,
                          ),
                        ),
                      ),
                      if (unreadCount >
                          0)
                        Positioned(
                          right: -6.w,
                          top: -7.h,
                          child:
                              Container(
                            constraints:
                                BoxConstraints(
                              minWidth:
                                  20.w,
                              minHeight:
                                  20.w,
                            ),
                            padding:
                                EdgeInsets
                                    .symmetric(
                              horizontal:
                                  5.w,
                              vertical:
                                  2.h,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors
                                      .red,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20.r,
                              ),
                              border:
                                  Border.all(
                                color: Theme.of(
                                  context,
                                ).cardColor,
                                width: 2,
                              ),
                            ),
                            alignment:
                                Alignment
                                    .center,
                            child: Text(
                              unreadCount >
                                      99
                                  ? '99+'
                                  : '$unreadCount',
                              style:
                                  TextStyle(
                                color:
                                    Colors
                                        .white,
                                fontSize:
                                    9.sp,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar(
    String image,
    String name,
  ) {
    if (image.isNotEmpty) {
      return CircleAvatar(
        radius: 25.r,
        backgroundColor:
            const Color(
          0xFFFFB91F,
        ),
        child: ClipOval(
          child: Image.network(
            image,
            width: 50.w,
            height: 50.w,
            fit: BoxFit.cover,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return _initialAvatar(
                name,
              );
            },
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 25.r,
      backgroundColor:
          const Color(
        0xFFFFB91F,
      ),
      child:
          _initialAvatar(name),
    );
  }

  Widget _initialAvatar(
    String name,
  ) {
    final initial =
        name.trim().isEmpty
            ? '?'
            : name
                .trim()
                .substring(
                  0,
                  1,
                )
                .toUpperCase();

    return Text(
      initial,
      style: TextStyle(
        color: Colors.black,
        fontSize: 18.sp,
        fontWeight:
            FontWeight.w800,
      ),
    );
  }

  Widget _emptyState() {
    final searching =
        _searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding:
            EdgeInsets.all(
          30.r,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 70.w,
              height: 70.w,
              decoration:
                  BoxDecoration(
                color: const Color(
                  0xFFFFB91F,
                ).withValues(
                  alpha: 0.15,
                ),
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                searching
                    ? Icons
                        .person_search_outlined
                    : Icons
                        .forum_outlined,
                size: 34.sp,
                color:
                    const Color(
                  0xFFE69B00,
                ),
              ),
            ),
            SizedBox(
              height: 14.h,
            ),
            Text(
              searching
                  ? 'No users found'
                  : 'No users yet',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              searching
                  ? 'Try searching for another name or email.'
                  : 'Other registered Firebase users will appear here.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _firebaseRequired() {
    return Center(
      child: Padding(
        padding:
            EdgeInsets.all(
          30.r,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .chat_bubble_outline,
              size: 55.sp,
              color:
                  const Color(
                0xFFE69B00,
              ),
            ),
            SizedBox(
              height: 14.h,
            ),
            Text(
              'Firebase Chat',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            SizedBox(
              height: 6.h,
            ),
            Text(
              'Sign in with a Firebase account to use real-time chat.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(
    Object? error,
  ) {
    return Center(
      child: Padding(
        padding:
            EdgeInsets.all(
          30.r,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 50.sp,
              color:
                  Colors.redAccent,
            ),
            SizedBox(
              height: 12.h,
            ),
            Text(
              'Unable to load users',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              error
                      ?.toString()
                      .replaceFirst(
                        'Exception: ',
                        '',
                      ) ??
                  'Firestore could not load the user list.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}