import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  final UserService _userService =
      UserService();

  late Future<User> _userFuture;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    _userFuture =
        _userService.getUser();
  }

  void _refreshUser() {
    if (!mounted) {
      return;
    }

    setState(() {
      _loadUser();
    });
  }

  String _errorMessage(
    Object error,
  ) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,
        backgroundColor:
            error
                ? Colors.redAccent
                : null,
        content: Text(
          message,
        ),
      ),
    );
  }


  Future<void> _updateUsername(
    User user,
  ) async {
    String enteredUsername =
        user.username;

    final newUsername =
        await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Update Username',
          ),
          content: TextFormField(
            initialValue:
                user.username,
            autofocus: true,
            textInputAction:
                TextInputAction.done,
            decoration:
                const InputDecoration(
              labelText: 'Username',
              hintText:
                  'Enter new username',
              prefixIcon: Icon(
                Icons
                    .account_circle_outlined,
              ),
            ),
            onChanged: (value) {
              enteredUsername =
                  value;
            },
            onFieldSubmitted:
                (value) {
              final username =
                  value.trim();

              if (username.length <
                  3) {
                return;
              }

              Navigator.of(
                dialogContext,
              ).pop(username);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final username =
                    enteredUsername
                        .trim();

                if (username.length <
                    3) {
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(username);
              },
              child: const Text(
                'Update',
              ),
            ),
          ],
        );
      },
    );

    if (newUsername == null ||
        newUsername.trim().isEmpty ||
        newUsername.trim() ==
            user.username ||
        !mounted) {
      return;
    }

    if (newUsername.trim().length <
        3) {
      _showMessage(
        'Username must be at least 3 characters.',
        error: true,
      );

      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _userService
          .updateUsername(
        newUsername.trim(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
        _loadUser();
      });

      _showMessage(
        'Username updated successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      _showMessage(
        _errorMessage(e),
        error: true,
      );
    }
  }

  Future<void>
      _changePassword() async {
    String currentPassword = '';
    String newPassword = '';
    String confirmPassword = '';

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    String? validationMessage;

    final result =
        await showDialog<
            Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (
        dialogContext,
      ) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            void submit() {
              final current =
                  currentPassword;

              final newPass =
                  newPassword;

              final confirm =
                  confirmPassword;

              String? error;

              if (current.isEmpty) {
                error =
                    'Current password is required.';
              } else if (newPass
                  .isEmpty) {
                error =
                    'New password is required.';
              } else if (newPass
                      .length <
                  6) {
                error =
                    'New password must be at least 6 characters.';
              } else if (!RegExp(
                r'[A-Z]',
              ).hasMatch(
                newPass,
              )) {
                error =
                    'Include at least one uppercase letter.';
              } else if (!RegExp(
                r'[a-z]',
              ).hasMatch(
                newPass,
              )) {
                error =
                    'Include at least one lowercase letter.';
              } else if (!RegExp(
                r'[0-9]',
              ).hasMatch(
                newPass,
              )) {
                error =
                    'Include at least one number.';
              } else if (newPass ==
                  current) {
                error =
                    'New password must be different.';
              } else if (confirm
                      .isEmpty ||
                  confirm !=
                      newPass) {
                error =
                    'New passwords do not match.';
              }

              if (error != null) {
                setDialogState(
                  () {
                    validationMessage =
                        error;
                  },
                );

                return;
              }

              Navigator.of(
                dialogContext,
              ).pop(
                {
                  'current':
                      current,
                  'new':
                      newPass,
                },
              );
            }

            return AlertDialog(
              title: const Text(
                'Change Password',
              ),
              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    TextFormField(
                      obscureText:
                          obscureCurrent,
                      autofocus: true,
                      textInputAction:
                          TextInputAction
                              .next,
                      onChanged:
                          (value) {
                        currentPassword =
                            value;

                        if (validationMessage !=
                            null) {
                          setDialogState(
                            () {
                              validationMessage =
                                  null;
                            },
                          );
                        }
                      },
                      decoration:
                          InputDecoration(
                        labelText:
                            'Current Password',
                        prefixIcon:
                            const Icon(
                          Icons
                              .lock_outline,
                        ),
                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setDialogState(
                              () {
                                obscureCurrent =
                                    !obscureCurrent;
                              },
                            );
                          },
                          icon: Icon(
                            obscureCurrent
                                ? Icons
                                    .visibility_outlined
                                : Icons
                                    .visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 14.h,
                    ),
                    TextFormField(
                      obscureText:
                          obscureNew,
                      textInputAction:
                          TextInputAction
                              .next,
                      onChanged:
                          (value) {
                        newPassword =
                            value;

                        if (validationMessage !=
                            null) {
                          setDialogState(
                            () {
                              validationMessage =
                                  null;
                            },
                          );
                        }
                      },
                      decoration:
                          InputDecoration(
                        labelText:
                            'New Password',
                        prefixIcon:
                            const Icon(
                          Icons
                              .lock_reset_outlined,
                        ),
                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setDialogState(
                              () {
                                obscureNew =
                                    !obscureNew;
                              },
                            );
                          },
                          icon: Icon(
                            obscureNew
                                ? Icons
                                    .visibility_outlined
                                : Icons
                                    .visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 14.h,
                    ),
                    TextFormField(
                      obscureText:
                          obscureConfirm,
                      textInputAction:
                          TextInputAction
                              .done,
                      onChanged:
                          (value) {
                        confirmPassword =
                            value;

                        if (validationMessage !=
                            null) {
                          setDialogState(
                            () {
                              validationMessage =
                                  null;
                            },
                          );
                        }
                      },
                      onFieldSubmitted:
                          (_) {
                        submit();
                      },
                      decoration:
                          InputDecoration(
                        labelText:
                            'Confirm New Password',
                        prefixIcon:
                            const Icon(
                          Icons
                              .lock_outline,
                        ),
                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setDialogState(
                              () {
                                obscureConfirm =
                                    !obscureConfirm;
                              },
                            );
                          },
                          icon: Icon(
                            obscureConfirm
                                ? Icons
                                    .visibility_outlined
                                : Icons
                                    .visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    if (validationMessage !=
                        null) ...[
                      SizedBox(
                        height: 12.h,
                      ),
                      Align(
                        alignment:
                            Alignment
                                .centerLeft,
                        child: Text(
                          validationMessage!,
                          style:
                              TextStyle(
                            color: Colors
                                .redAccent,
                            fontSize:
                                11.sp,
                            fontWeight:
                                FontWeight
                                    .w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                ElevatedButton(
                  onPressed: submit,
                  child: const Text(
                    'Change Password',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null ||
        !mounted) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _userService
          .resetPasswordFromCurrentPassword(
        result['current']!,
        result['new']!,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      _showMessage(
        'Password changed successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      _showMessage(
        _errorMessage(e),
        error: true,
      );
    }
  }

  Future<void>
      _deleteAccount() async {
    String enteredPassword = '';
    bool obscurePassword = true;
    String? validationMessage;

    final password =
        await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (
        dialogContext,
      ) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            void submit() {
              final value =
                  enteredPassword;

              if (value.isEmpty) {
                setDialogState(
                  () {
                    validationMessage =
                        'Current password is required.';
                  },
                );

                return;
              }

              Navigator.of(
                dialogContext,
              ).pop(value);
            }

            return AlertDialog(
              title: const Text(
                'Delete Account',
              ),
              content: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Text(
                    'Enter your current password to continue.',
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  TextFormField(
                    obscureText:
                        obscurePassword,
                    autofocus: true,
                    textInputAction:
                        TextInputAction
                            .done,
                    onChanged:
                        (value) {
                      enteredPassword =
                          value;

                      if (validationMessage !=
                          null) {
                        setDialogState(
                          () {
                            validationMessage =
                                null;
                          },
                        );
                      }
                    },
                    onFieldSubmitted:
                        (_) {
                      submit();
                    },
                    decoration:
                        InputDecoration(
                      labelText:
                          'Current Password',
                      prefixIcon:
                          const Icon(
                        Icons
                            .lock_outline,
                      ),
                      suffixIcon:
                          IconButton(
                        onPressed: () {
                          setDialogState(
                            () {
                              obscurePassword =
                                  !obscurePassword;
                            },
                          );
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  if (validationMessage !=
                      null) ...[
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      validationMessage!,
                      style:
                          TextStyle(
                        color: Colors
                            .redAccent,
                        fontSize:
                            11.sp,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child:
                      const Text(
                    'Cancel',
                  ),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors
                            .redAccent,
                    foregroundColor:
                        Colors.white,
                  ),
                  onPressed:
                      submit,
                  child:
                      const Text(
                    'Continue',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (password == null ||
        password.isEmpty ||
        !mounted) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Final Confirmation',
          ),
          content: const Text(
            'Are you sure you want to permanently delete this Firebase account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child:
                  const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    Colors.redAccent,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child:
                  const Text(
                'Delete Account',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _userService
          .deleteAccount(
        password,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context)
          .pushNamedAndRemoveUntil(
        '/signin',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      _showMessage(
        _errorMessage(e),
        error: true,
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Stack(
      children: [
        FutureBuilder<User>(
          future: _userFuture,
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot
                    .connectionState ==
                ConnectionState
                    .waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Text(
                      'Unable to load profile.',
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    ElevatedButton(
                      onPressed:
                          _refreshUser,
                      child:
                          const Text(
                        'Retry',
                      ),
                    ),
                  ],
                ),
              );
            }

            final user =
                snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async {
                final future =
                    _userService
                        .getUser();

                setState(() {
                  _userFuture =
                      future;
                });

                await future;
              },
              child:
                  SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    EdgeInsets.all(
                  16.r,
                ),
                child: Column(
                  children: [
                    _profileHeader(
                      user,
                    ),
                    SizedBox(
                      height: 16.h,
                    ),
                    _loginTypeCard(
                      user,
                    ),
                    SizedBox(
                      height: 16.h,
                    ),
                    _informationCard(
                      user,
                    ),
                    if (user
                        .isFirebase) ...[
                      SizedBox(
                        height: 16.h,
                      ),
                      _firebaseActions(
                        user,
                      ),
                    ],
                    SizedBox(
                      height: 22.h,
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (_isProcessing)
          Positioned.fill(
            child:
                AbsorbPointer(
              child: Container(
                color: Colors.black
                    .withValues(
                  alpha: 0.25,
                ),
                child:
                    const Center(
                  child:
                      CircularProgressIndicator(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _profileHeader(
    User user,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        22.r,
      ),
      decoration: BoxDecoration(
        color:
            Theme.of(context).cardColor,
        borderRadius:
            BorderRadius.circular(
          18.r,
        ),
        boxShadow: const [
          BoxShadow(
            color:
                Color(0x12000000),
            blurRadius: 10,
            offset:
                Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _profileImage(
            user,
          ),
          SizedBox(
            height: 14.h,
          ),
          Text(
            user.fullName,
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 21.sp,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          SizedBox(
            height: 4.h,
          ),
          Text(
            user.username.isEmpty
                ? 'No username'
                : '@${user.username}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginTypeCard(
    User user,
  ) {
    final firebase =
        user.isFirebase;

    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 13.h,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFFFFB91F,
        ).withValues(
          alpha: 0.12,
        ),
        borderRadius:
            BorderRadius.circular(
          14.r,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration:
                BoxDecoration(
              color: const Color(
                0xFFFFB91F,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                11.r,
              ),
            ),
            child: Icon(
              firebase
                  ? Icons
                      .local_fire_department
                  : Icons.language,
              color: Colors.black,
            ),
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
                  firebase
                      ? 'Firebase Account'
                      : 'DummyJSON Account',
                  style: TextStyle(
                    fontSize:
                        13.sp,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Text(
                  firebase
                      ? 'Firebase Authentication'
                      : 'DummyJSON API Authentication',
                  style: TextStyle(
                    fontSize:
                        10.sp,
                    color:
                        Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified,
            size: 20.sp,
            color:
                const Color(
              0xFFE69B00,
            ),
          ),
        ],
      ),
    );
  }

  Widget _informationCard(
    User user,
  ) {
    return Container(
      padding:
          EdgeInsets.all(
        16.r,
      ),
      decoration: BoxDecoration(
        color:
            Theme.of(context).cardColor,
        borderRadius:
            BorderRadius.circular(
          16.r,
        ),
        boxShadow: const [
          BoxShadow(
            color:
                Color(0x10000000),
            blurRadius: 8,
            offset:
                Offset(0, 2),
          ),
        ],
      ),
      child: user.isFirebase
          ? _firebaseInformation(
              user,
            )
          : _dummyJsonInformation(
              user,
            ),
    );
  }

  Widget _firebaseInformation(
    User user,
  ) {
    return Column(
      children: [
        _informationTile(
          icon:
              Icons.person_outline,
          label: 'First Name',
          value:
              user.firstName,
        ),
        const Divider(),
        _informationTile(
          icon:
              Icons.person_outline,
          label: 'Last Name',
          value:
              user.lastName,
        ),
        const Divider(),
        _informationTile(
          icon:
              Icons.cake_outlined,
          label: 'Age',
          value: user.age > 0
              ? '${user.age}'
              : '',
        ),
        const Divider(),
        _informationTile(
          icon:
              Icons.phone_outlined,
          label:
              'Contact Number',
          value:
              user.contactNo,
        ),
        const Divider(),
        _informationTile(
          icon:
              Icons.email_outlined,
          label: 'Email',
          value: user.email,
        ),
        const Divider(),
        _informationTile(
          icon: Icons
              .account_circle_outlined,
          label: 'Username',
          value:
              user.username,
        ),
        const Divider(),
        _informationTile(
          icon:
              Icons.fingerprint,
          label:
              'Firebase UID',
          value:
              user.firebaseUid,
        ),
      ],
    );
  }

  Widget _dummyJsonInformation(
    User user,
  ) {
    return Column(
      children: [
        _informationTile(
          icon:
              Icons.email_outlined,
          label: 'Email',
          value: user.email,
        ),
        const Divider(),
        _informationTile(
          icon:
              Icons.person_outline,
          label: 'Gender',
          value:
              user.gender.isEmpty
                  ? 'Not specified'
                  : user.gender,
        ),
        const Divider(),
        _informationTile(
          icon:
              Icons.badge_outlined,
          label: 'User ID',
          value: '${user.id}',
        ),
        const Divider(),
        _informationTile(
          icon: Icons
              .account_circle_outlined,
          label: 'Username',
          value:
              user.username,
        ),
      ],
    );
  }

  Widget _firebaseActions(
    User user,
  ) {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.all(
        16.r,
      ),
      decoration: BoxDecoration(
        color:
            Theme.of(context).cardColor,
        borderRadius:
            BorderRadius.circular(
          16.r,
        ),
        boxShadow: const [
          BoxShadow(
            color:
                Color(0x10000000),
            blurRadius: 8,
            offset:
                Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Text(
            'Account Management',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          SizedBox(
            height: 4.h,
          ),
          Text(
            'Manage your Firebase account.',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(
            height: 16.h,
          ),
          _actionTile(
            icon:
                Icons.edit_outlined,
            title:
                'Update Username',
            subtitle:
                'Change your Firebase display name',
            onTap: () {
              _updateUsername(
                user,
              );
            },
          ),
          const Divider(),
          _actionTile(
            icon: Icons
                .password_outlined,
            title:
                'Change Password',
            subtitle:
                'Verify your current password first',
            onTap:
                _changePassword,
          ),
          const Divider(),
          _actionTile(
            icon: Icons
                .delete_forever_outlined,
            title:
                'Delete Account',
            subtitle:
                'Permanently delete your Firebase account',
            destructive: true,
            onTap:
                _deleteAccount,
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final color =
        destructive
            ? Colors.redAccent
            : const Color(
                0xFFE69B00,
              );

    return InkWell(
      onTap:
          _isProcessing
              ? null
              : onTap,
      borderRadius:
          BorderRadius.circular(
        10.r,
      ),
      child: Padding(
        padding:
            EdgeInsets.symmetric(
          vertical: 10.h,
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration:
                  BoxDecoration(
                color: color
                    .withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  10.r,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 21.sp,
              ),
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
                    title,
                    style:
                        TextStyle(
                      fontSize:
                          13.sp,
                      fontWeight:
                          FontWeight
                              .w700,
                      color:
                          destructive
                              ? Colors
                                  .redAccent
                              : null,
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Text(
                    subtitle,
                    style:
                        TextStyle(
                      fontSize:
                          10.sp,
                      color:
                          Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons
                  .chevron_right,
              color: Colors.grey,
              size: 21.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileImage(
    User user,
  ) {
    if (user.image.isNotEmpty) {
      return CircleAvatar(
        radius: 48.r,
        backgroundColor:
            const Color(
          0xFFFFB91F,
        ),
        child: ClipOval(
          child: Image.network(
            user.image,
            width: 90.w,
            height: 90.w,
            fit: BoxFit.cover,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return Icon(
                Icons.person,
                size: 54.sp,
                color:
                    Colors.black,
              );
            },
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 48.r,
      backgroundColor:
          const Color(
        0xFFFFB91F,
      ),
      child: Icon(
        Icons.person,
        size: 54.sp,
        color: Colors.black,
      ),
    );
  }

  Widget _informationTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding:
          EdgeInsets.symmetric(
        vertical: 7.h,
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration:
                BoxDecoration(
              color: const Color(
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
              icon,
              size: 20.sp,
              color:
                  const Color(
                0xFFE69B00,
              ),
            ),
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
                  label,
                  style:
                      TextStyle(
                    fontSize:
                        10.sp,
                    color:
                        Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Text(
                  value.isEmpty
                      ? 'Not available'
                      : value,
                  style:
                      TextStyle(
                    fontSize:
                        13.sp,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}