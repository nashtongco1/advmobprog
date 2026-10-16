import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverEmail;
  final String receiverImage;

  const ChatDetailScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverEmail,
    this.receiverImage = '',
  });

  @override
  State<ChatDetailScreen> createState() =>
      _ChatDetailScreenState();
}

class _ChatDetailScreenState
    extends State<ChatDetailScreen> {
  final ChatService _chatService =
      ChatService();

  final TextEditingController
      _messageController =
      TextEditingController();

  final ScrollController
      _scrollController =
      ScrollController();

  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _markMessagesAsSeen();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _markMessagesAsSeen() async {
    try {
      await _chatService.markMessagesAsSeen(
        widget.receiverId,
      );
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final message =
        _messageController.text.trim();

    if (message.isEmpty ||
        _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _chatService.sendMessage(
        widget.receiverId,
        message,
      );

      _messageController.clear();

      _scrollToBottom();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              Colors.redAccent,
          content: Text(
            e
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController
            .position.maxScrollExtent,
        duration:
            const Duration(
          milliseconds: 280,
        ),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        widget.receiverName.trim().isEmpty
            ? widget.receiverEmail
            : widget.receiverName;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            _buildAvatar(
              displayName,
            ),
            SizedBox(
              width: 10.w,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  if (widget
                      .receiverEmail
                      .isNotEmpty)
                    Text(
                      widget.receiverEmail,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight:
                            FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<
                  List<MessageModel>>(
                stream:
                    _chatService.getMessages(
                  widget.receiverId,
                ),
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
                          ConnectionState
                              .waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  final messages =
                      snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return _emptyState(
                      displayName,
                    );
                  }

                  WidgetsBinding.instance
                      .addPostFrameCallback(
                    (_) {
                      _markMessagesAsSeen();
                      _scrollToBottom();
                    },
                  );

                  return ListView.builder(
                    controller:
                        _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior
                            .onDrag,
                    padding:
                        EdgeInsets.fromLTRB(
                      14.w,
                      16.h,
                      14.w,
                      12.h,
                    ),
                    itemCount:
                        messages.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final message =
                          messages[index];

                      final isMine =
                          message.isSentBy(
                        _chatService
                            .currentUserId,
                      );

                      return _AnimatedMessageBubble(
                        key: ValueKey(
                          message.id,
                        ),
                        message: message,
                        isMine: isMine,
                        showTime:
                            _shouldShowTime(
                          messages,
                          index,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            _messageComposer(),
          ],
        ),
      ),
    );
  }

  bool _shouldShowTime(
    List<MessageModel> messages,
    int index,
  ) {
    if (index ==
        messages.length - 1) {
      return true;
    }

    final current =
        messages[index];

    final next =
        messages[index + 1];

    final difference = next.timestamp
        .difference(
          current.timestamp,
        )
        .inMinutes
        .abs();

    return difference >= 5 ||
        current.senderId !=
            next.senderId;
  }

  Widget _messageComposer() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12.w,
        8.h,
        12.w,
        10.h,
      ),
      decoration: BoxDecoration(
        color:
            Theme.of(context)
                .scaffoldBackgroundColor,
        boxShadow: const [
          BoxShadow(
            color: Color(
              0x12000000,
            ),
            blurRadius: 10,
            offset: Offset(
              0,
              -2,
            ),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller:
                  _messageController,
              minLines: 1,
              maxLines: 5,
              textCapitalization:
                  TextCapitalization
                      .sentences,
              keyboardType:
                  TextInputType.multiline,
              decoration:
                  InputDecoration(
                hintText:
                    'Type a message...',
                filled: true,
                fillColor:
                    Theme.of(context)
                        .cardColor,
                contentPadding:
                    EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 11.h,
                ),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    22.r,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
                enabledBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    22.r,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    22.r,
                  ),
                  borderSide:
                      const BorderSide(
                    color: Color(
                      0xFFFFB91F,
                    ),
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8.w,
          ),
          Material(
            color: const Color(
              0xFFFFB91F,
            ),
            shape:
                const CircleBorder(),
            child: InkWell(
              customBorder:
                  const CircleBorder(),
              onTap: _isSending
                  ? null
                  : _sendMessage,
              child: SizedBox(
                width: 46.w,
                height: 46.w,
                child: Center(
                  child: _isSending
                      ? SizedBox(
                          width: 19.w,
                          height: 19.w,
                          child:
                              const CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.black,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          size: 21.sp,
                          color:
                              Colors.black,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    String name,
  ) {
    if (widget.receiverImage
        .isNotEmpty) {
      return CircleAvatar(
        radius: 18.r,
        backgroundColor:
            const Color(
          0xFFFFB91F,
        ),
        child: ClipOval(
          child: Image.network(
            widget.receiverImage,
            width: 36.w,
            height: 36.w,
            fit: BoxFit.cover,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return _avatarInitial(
                name,
              );
            },
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 18.r,
      backgroundColor:
          const Color(
        0xFFFFB91F,
      ),
      child:
          _avatarInitial(name),
    );
  }

  Widget _avatarInitial(
    String name,
  ) {
    final initial =
        name.trim().isEmpty
            ? '?'
            : name
                .trim()
                .substring(0, 1)
                .toUpperCase();

    return Text(
      initial,
      style: TextStyle(
        color: Colors.black,
        fontSize: 14.sp,
        fontWeight:
            FontWeight.w800,
      ),
    );
  }

  Widget _emptyState(
    String name,
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
            Container(
              width: 72.w,
              height: 72.w,
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
                Icons
                    .waving_hand_outlined,
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
              'Start a conversation',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              'Send your first message to $name.',
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
              'Unable to load messages',
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
                  'Something went wrong.',
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

class _AnimatedMessageBubble
    extends StatefulWidget {
  final MessageModel message;
  final bool isMine;
  final bool showTime;

  const _AnimatedMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.showTime,
  });

  @override
  State<_AnimatedMessageBubble>
      createState() =>
          _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState
    extends State<
        _AnimatedMessageBubble>
    with
        SingleTickerProviderStateMixin {
  late final AnimationController
      _animationController;

  late final Animation<double>
      _fadeAnimation;

  late final Animation<Offset>
      _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(
        milliseconds: 280,
      ),
    );

    _fadeAnimation =
        CurvedAnimation(
      parent:
          _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(
      begin: Offset(
        widget.isMine
            ? 0.12
            : -0.12,
        0.08,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent:
            _animationController,
        curve:
            Curves.easeOutCubic,
      ),
    );

    _animationController
        .forward();
  }

  @override
  void dispose() {
    _animationController
        .dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position:
            _slideAnimation,
        child: Align(
          alignment: widget.isMine
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            constraints:
                BoxConstraints(
              maxWidth:
                  MediaQuery.sizeOf(
                        context,
                      ).width *
                      0.76,
            ),
            margin:
                EdgeInsets.only(
              bottom: widget.showTime
                  ? 12.h
                  : 5.h,
            ),
            child: Column(
              crossAxisAlignment:
                  widget.isMine
                      ? CrossAxisAlignment
                          .end
                      : CrossAxisAlignment
                          .start,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration:
                      BoxDecoration(
                    color: widget.isMine
                        ? const Color(
                            0xFFFFB91F,
                          )
                        : Theme.of(
                            context,
                          ).cardColor,
                    borderRadius:
                        BorderRadius.only(
                      topLeft:
                          Radius.circular(
                        16.r,
                      ),
                      topRight:
                          Radius.circular(
                        16.r,
                      ),
                      bottomLeft:
                          Radius.circular(
                        widget.isMine
                            ? 16.r
                            : 4.r,
                      ),
                      bottomRight:
                          Radius.circular(
                        widget.isMine
                            ? 4.r
                            : 16.r,
                      ),
                    ),
                    boxShadow:
                        const [
                      BoxShadow(
                        color: Color(
                          0x10000000,
                        ),
                        blurRadius: 6,
                        offset:
                            Offset(
                          0,
                          2,
                        ),
                      ),
                    ],
                  ),
                  child: Text(
                    widget
                        .message
                        .message,
                    style: TextStyle(
                      color:
                          widget.isMine
                              ? Colors.black
                              : null,
                      fontSize: 13.sp,
                      height: 1.3,
                    ),
                  ),
                ),
                if (widget.showTime)
                  Padding(
                    padding:
                        EdgeInsets.only(
                      top: 3.h,
                      left: 4.w,
                      right: 4.w,
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(
                            widget
                                .message
                                .timestamp,
                          ),
                          style:
                              TextStyle(
                            color:
                                Colors.grey,
                            fontSize:
                                8.sp,
                          ),
                        ),
                        if (widget
                            .isMine) ...[
                          SizedBox(
                            width: 4.w,
                          ),
                          _statusIcon(),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusIcon() {
    final status =
        widget.message.status
            .toLowerCase();

    if (status == 'seen') {
      return Icon(
        Icons.done_all,
        size: 13.sp,
        color: Colors.blue,
      );
    }

    if (status ==
        'delivered') {
      return Icon(
        Icons.done_all,
        size: 13.sp,
        color: Colors.grey,
      );
    }

    if (status ==
        'sending') {
      return Icon(
        Icons.schedule,
        size: 12.sp,
        color: Colors.grey,
      );
    }

    return Icon(
      Icons.done,
      size: 12.sp,
      color: Colors.grey,
    );
  }

  String _formatTime(
    DateTime dateTime,
  ) {
    final local =
        dateTime.toLocal();

    final hour =
        local.hour == 0
            ? 12
            : local.hour > 12
                ? local.hour - 12
                : local.hour;

    final minute =
        local.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final period =
        local.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }
}