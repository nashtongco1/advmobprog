import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() =>
      _SignUpScreenState();
}

class _SignUpScreenState
    extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController =
      TextEditingController();
  final _lastNameController =
      TextEditingController();
  final _ageController =
      TextEditingController();
  final _contactController =
      TextEditingController();
  final _usernameController =
      TextEditingController();
  final _emailController =
      TextEditingController();
  final _passwordController =
      TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  final UserService _userService =
      UserService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await _userService.createAccount(
        fName: _firstNameController.text.trim(),
        lName: _lastNameController.text.trim(),
        age: int.parse(
          _ageController.text.trim(),
        ),
        contactNo:
            _contactController.text.trim(),
        username:
            _usernameController.text.trim(),
        emailAddress:
            _emailController.text.trim(),
        password:
            _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Account created successfully.',
          ),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/splash',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
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
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark
          ? const Color(0xFF1C1C1C)
          : const Color(0xFFF7F7F7),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12.r),
        borderSide: const BorderSide(
          color: Color(0xFFFFB91F),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 7.h,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF151515),
                    const Color(0xFF202020),
                  ]
                : [
                    const Color(0xFFFFF5DA),
                    Colors.white,
                  ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -70.h,
              right: -80.w,
              child: Container(
                width: 220.w,
                height: 220.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      const Color(0xFFFFB91F)
                          .withValues(
                    alpha: 0.12,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.pop(
                                    context,
                                  );
                                },
                          icon: const Icon(
                            Icons.arrow_back,
                          ),
                        ),
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        SingleChildScrollView(
                      padding:
                          EdgeInsets.fromLTRB(
                        26.w,
                        10.h,
                        26.w,
                        30.h,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              width: 82.w,
                              height: 82.w,
                              decoration:
                                  BoxDecoration(
                                gradient:
                                    const LinearGradient(
                                  begin: Alignment
                                      .topLeft,
                                  end: Alignment
                                      .bottomRight,
                                  colors: [
                                    Color(
                                      0xFFFFD45A,
                                    ),
                                    Color(
                                      0xFFFFB91F,
                                    ),
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  23.r,
                                ),
                              ),
                              child: Icon(
                                Icons
                                    .sports_basketball,
                                size: 48.sp,
                                color:
                                    Colors.black,
                              ),
                            ),
                            SizedBox(
                              height: 14.h,
                            ),
                            Text(
                              'Join HoopsHub',
                              style: TextStyle(
                                fontSize: 25.sp,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            Text(
                              'Create your Firebase account.',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color:
                                    Colors.grey,
                              ),
                            ),
                            SizedBox(
                              height: 22.h,
                            ),
                            Container(
                              width:
                                  double.infinity,
                              padding:
                                  EdgeInsets.all(
                                18.r,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: isDark
                                    ? const Color(
                                        0xFF252525,
                                      )
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  18.r,
                                ),
                                boxShadow:
                                    const [
                                  BoxShadow(
                                    color: Color(
                                      0x12000000,
                                    ),
                                    blurRadius:
                                        15,
                                    offset:
                                        Offset(
                                      0,
                                      6,
                                    ),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  _fieldLabel(
                                    'First Name',
                                  ),
                                  TextFormField(
                                    controller:
                                        _firstNameController,
                                    textInputAction:
                                        TextInputAction
                                            .next,
                                    decoration:
                                        _inputDecoration(
                                      hint:
                                          'Enter your first name',
                                      icon: Icons
                                          .person_outline,
                                    ),
                                    validator:
                                        (value) {
                                      if (value ==
                                              null ||
                                          value
                                              .trim()
                                              .isEmpty) {
                                        return 'First name is required.';
                                      }

                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 16.h,
                                  ),
                                  _fieldLabel(
                                    'Last Name',
                                  ),
                                  TextFormField(
                                    controller:
                                        _lastNameController,
                                    textInputAction:
                                        TextInputAction
                                            .next,
                                    decoration:
                                        _inputDecoration(
                                      hint:
                                          'Enter your last name',
                                      icon: Icons
                                          .person_outline,
                                    ),
                                    validator:
                                        (value) {
                                      if (value ==
                                              null ||
                                          value
                                              .trim()
                                              .isEmpty) {
                                        return 'Last name is required.';
                                      }

                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 16.h,
                                  ),
                                  _fieldLabel(
                                    'Age',
                                  ),
                                  TextFormField(
                                    controller:
                                        _ageController,
                                    keyboardType:
                                        TextInputType
                                            .number,
                                    textInputAction:
                                        TextInputAction
                                            .next,
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .digitsOnly,
                                    ],
                                    decoration:
                                        _inputDecoration(
                                      hint:
                                          'Enter your age',
                                      icon: Icons
                                          .cake_outlined,
                                    ),
                                    validator:
                                        (value) {
                                      if (value ==
                                              null ||
                                          value
                                              .trim()
                                              .isEmpty) {
                                        return 'Age is required.';
                                      }

                                      final age =
                                          int.tryParse(
                                        value.trim(),
                                      );

                                      if (age ==
                                              null ||
                                          age <= 0 ||
                                          age > 120) {
                                        return 'Enter a valid age.';
                                      }

                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 16.h,
                                  ),
                                  _fieldLabel(
                                    'Contact Number',
                                  ),
                                  TextFormField(
                                    controller:
                                        _contactController,
                                    keyboardType:
                                        TextInputType
                                            .phone,
                                    textInputAction:
                                        TextInputAction
                                            .next,
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .allow(
                                        RegExp(
                                          r'[0-9+]',
                                        ),
                                      ),
                                    ],
                                    decoration:
                                        _inputDecoration(
                                      hint:
                                          'Enter your contact number',
                                      icon: Icons
                                          .phone_outlined,
                                    ),
                                    validator:
                                        (value) {
                                      if (value ==
                                              null ||
                                          value
                                              .trim()
                                              .isEmpty) {
                                        return 'Contact number is required.';
                                      }

                                      if (value
                                              .trim()
                                              .length <
                                          7) {
                                        return 'Enter a valid contact number.';
                                      }

                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 16.h,
                                  ),
                                  _fieldLabel(
                                    'Username',
                                  ),
                                  TextFormField(
                                    controller:
                                        _usernameController,
                                    textInputAction:
                                        TextInputAction
                                            .next,
                                    decoration:
                                        _inputDecoration(
                                      hint:
                                          'Choose a username',
                                      icon: Icons
                                          .alternate_email,
                                    ),
                                    validator:
                                        (value) {
                                      if (value ==
                                              null ||
                                          value
                                              .trim()
                                              .isEmpty) {
                                        return 'Username is required.';
                                      }

                                      if (value
                                              .trim()
                                              .length <
                                          3) {
                                        return 'Username must be at least 3 characters.';
                                      }

                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 16.h,
                                  ),
                                  _fieldLabel(
                                    'Email Address',
                                  ),
                                  TextFormField(
                                    controller:
                                        _emailController,
                                    keyboardType:
                                        TextInputType
                                            .emailAddress,
                                    textInputAction:
                                        TextInputAction
                                            .next,
                                    decoration:
                                        _inputDecoration(
                                      hint:
                                          'Enter your email address',
                                      icon: Icons
                                          .email_outlined,
                                    ),
                                    validator:
                                        (value) {
                                      final email =
                                          value
                                                  ?.trim() ??
                                              '';

                                      if (email
                                          .isEmpty) {
                                        return 'Email address is required.';
                                      }

                                      final emailRegex =
                                          RegExp(
                                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                      );

                                      if (!emailRegex
                                          .hasMatch(
                                        email,
                                      )) {
                                        return 'Enter a valid email address.';
                                      }

                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 16.h,
                                  ),
                                  _fieldLabel(
                                    'Password',
                                  ),
                                  TextFormField(
                                    controller:
                                        _passwordController,
                                    obscureText:
                                        _obscurePassword,
                                    textInputAction:
                                        TextInputAction
                                            .next,
                                    decoration:
                                        _inputDecoration(
                                      hint:
                                          'Create a password',
                                      icon: Icons
                                          .lock_outline,
                                      suffixIcon:
                                          IconButton(
                                        onPressed:
                                            () {
                                          setState(
                                            () {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            },
                                          );
                                        },
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons
                                                  .visibility_outlined
                                              : Icons
                                                  .visibility_off_outlined,
                                        ),
                                      ),
                                    ),
                                    validator:
                                        (value) {
                                      if (value ==
                                              null ||
                                          value
                                              .isEmpty) {
                                        return 'Password is required.';
                                      }

                                      if (value
                                              .length <
                                          6) {
                                        return 'Password must be at least 6 characters.';
                                      }

                                      if (!RegExp(
                                        r'[A-Z]',
                                      ).hasMatch(
                                        value,
                                      )) {
                                        return 'Include at least one uppercase letter.';
                                      }

                                      if (!RegExp(
                                        r'[a-z]',
                                      ).hasMatch(
                                        value,
                                      )) {
                                        return 'Include at least one lowercase letter.';
                                      }

                                      if (!RegExp(
                                        r'[0-9]',
                                      ).hasMatch(
                                        value,
                                      )) {
                                        return 'Include at least one number.';
                                      }

                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 16.h,
                                  ),
                                  _fieldLabel(
                                    'Confirm Password',
                                  ),
                                  TextFormField(
                                    controller:
                                        _confirmPasswordController,
                                    obscureText:
                                        _obscureConfirmPassword,
                                    textInputAction:
                                        TextInputAction
                                            .done,
                                    onFieldSubmitted:
                                        (_) =>
                                            _createAccount(),
                                    decoration:
                                        _inputDecoration(
                                      hint:
                                          'Confirm your password',
                                      icon: Icons
                                          .lock_outline,
                                      suffixIcon:
                                          IconButton(
                                        onPressed:
                                            () {
                                          setState(
                                            () {
                                              _obscureConfirmPassword =
                                                  !_obscureConfirmPassword;
                                            },
                                          );
                                        },
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons
                                                  .visibility_outlined
                                              : Icons
                                                  .visibility_off_outlined,
                                        ),
                                      ),
                                    ),
                                    validator:
                                        (value) {
                                      if (value ==
                                              null ||
                                          value
                                              .isEmpty) {
                                        return 'Confirm your password.';
                                      }

                                      if (value !=
                                          _passwordController
                                              .text) {
                                        return 'Passwords do not match.';
                                      }

                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 24.h,
                                  ),
                                  SizedBox(
                                    width: double
                                        .infinity,
                                    height: 52.h,
                                    child:
                                        ElevatedButton(
                                      onPressed:
                                          _isLoading
                                              ? null
                                              : _createAccount,
                                      style:
                                          ElevatedButton
                                              .styleFrom(
                                        backgroundColor:
                                            const Color(
                                          0xFFFFB91F,
                                        ),
                                        foregroundColor:
                                            Colors
                                                .black,
                                        elevation: 0,
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              width:
                                                  23.w,
                                              height:
                                                  23.w,
                                              child:
                                                  const CircularProgressIndicator(
                                                strokeWidth:
                                                    2.5,
                                                color:
                                                    Colors.black,
                                              ),
                                            )
                                          : Text(
                                              'Create Account',
                                              style:
                                                  TextStyle(
                                                fontSize:
                                                    15.sp,
                                                fontWeight:
                                                    FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 18.h,
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style:
                                      TextStyle(
                                    fontSize:
                                        12.sp,
                                    color:
                                        Colors.grey,
                                  ),
                                ),
                                TextButton(
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : () {
                                              Navigator
                                                  .pop(
                                                context,
                                              );
                                            },
                                  child: Text(
                                    'Sign In',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          12.sp,
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                      color:
                                          const Color(
                                        0xFFE69B00,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}