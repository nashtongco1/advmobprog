import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
  });

  @override
  State<SignInScreen> createState() =>
      _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _loginController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final UserService _userService =
      UserService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _useFirebase = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void _changeLoginType(bool useFirebase) {
    if (_isLoading) {
      return;
    }

    setState(() {
      _useFirebase = useFirebase;
      _loginController.clear();
      _passwordController.clear();
      _obscurePassword = true;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_useFirebase) {
        await _userService.signIn(
          _loginController.text.trim(),
          _passwordController.text,
        );
      } else {
        final response =
            await _userService.loginUser(
          _loginController.text.trim(),
          _passwordController.text,
        );

        await _userService.saveUserData(
          response,
        );
      }

      if (!mounted) {
        return;
      }

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
            Positioned(
              bottom: -100.h,
              left: -90.w,
              child: Container(
                width: 260.w,
                height: 260.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      const Color(0xFFFFB91F)
                          .withValues(
                    alpha: 0.08,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 26.w,
                    vertical: 24.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          width: 100.w,
                          height: 100.w,
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
                              28.r,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(
                                  0xFFFFB91F,
                                ).withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 25,
                                offset:
                                    const Offset(
                                  0,
                                  10,
                                ),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons
                                .sports_basketball,
                            size: 58.sp,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 25.h),
                        Text(
                          'HoopsHub',
                          style: TextStyle(
                            fontSize: 31.sp,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          'Welcome back',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight:
                                FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          _useFirebase
                              ? 'Sign in with your Firebase account.'
                              : 'Sign in with your DummyJSON account.',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 22.h),
                        Container(
                          width: double.infinity,
                          padding:
                              EdgeInsets.all(
                            5.r,
                          ),
                          decoration:
                              BoxDecoration(
                            color: isDark
                                ? const Color(
                                    0xFF252525,
                                  )
                                : const Color(
                                    0xFFF0F0F0,
                                  ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14.r,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child:
                                    _loginTypeButton(
                                  title:
                                      'DummyJSON',
                                  icon: Icons
                                      .language,
                                  selected:
                                      !_useFirebase,
                                  onTap: () =>
                                      _changeLoginType(
                                    false,
                                  ),
                                ),
                              ),
                              Expanded(
                                child:
                                    _loginTypeButton(
                                  title:
                                      'Firebase',
                                  icon: Icons
                                      .local_fire_department_outlined,
                                  selected:
                                      _useFirebase,
                                  onTap: () =>
                                      _changeLoginType(
                                    true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Container(
                          width: double.infinity,
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
                                blurRadius: 15,
                                offset: Offset(
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
                              Text(
                                _useFirebase
                                    ? 'Email Address'
                                    : 'Username',
                                style:
                                    TextStyle(
                                  fontSize:
                                      12.sp,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                              SizedBox(
                                height: 7.h,
                              ),
                              TextFormField(
                                controller:
                                    _loginController,
                                keyboardType:
                                    _useFirebase
                                        ? TextInputType
                                            .emailAddress
                                        : TextInputType
                                            .text,
                                textInputAction:
                                    TextInputAction
                                        .next,
                                decoration:
                                    InputDecoration(
                                  hintText: _useFirebase
                                      ? 'Enter your email address'
                                      : 'Enter your username',
                                  prefixIcon:
                                      Icon(
                                    _useFirebase
                                        ? Icons
                                            .email_outlined
                                        : Icons
                                            .person_outline,
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? const Color(
                                          0xFF1C1C1C,
                                        )
                                      : const Color(
                                          0xFFF7F7F7,
                                        ),
                                  border:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      12.r,
                                    ),
                                    borderSide:
                                        BorderSide
                                            .none,
                                  ),
                                ),
                                validator:
                                    (value) {
                                  final input =
                                      value
                                              ?.trim() ??
                                          '';

                                  if (input
                                      .isEmpty) {
                                    return _useFirebase
                                        ? 'Email address is required.'
                                        : 'Username is required.';
                                  }

                                  if (_useFirebase) {
                                    final emailRegex =
                                        RegExp(
                                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                    );

                                    if (!emailRegex
                                        .hasMatch(
                                      input,
                                    )) {
                                      return 'Enter a valid email address.';
                                    }
                                  }

                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 18.h,
                              ),
                              Text(
                                'Password',
                                style:
                                    TextStyle(
                                  fontSize:
                                      12.sp,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                              SizedBox(
                                height: 7.h,
                              ),
                              TextFormField(
                                controller:
                                    _passwordController,
                                obscureText:
                                    _obscurePassword,
                                onFieldSubmitted:
                                    (_) =>
                                        _login(),
                                decoration:
                                    InputDecoration(
                                  hintText:
                                      'Enter your password',
                                  prefixIcon:
                                      const Icon(
                                    Icons
                                        .lock_outline,
                                  ),
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
                                  filled: true,
                                  fillColor: isDark
                                      ? const Color(
                                          0xFF1C1C1C,
                                        )
                                      : const Color(
                                          0xFFF7F7F7,
                                        ),
                                  border:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      12.r,
                                    ),
                                    borderSide:
                                        BorderSide
                                            .none,
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
                                          : _login,
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
                                          BorderRadius
                                              .circular(
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
                                          'Sign In',
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
                        SizedBox(height: 14.h),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Text(
                              'Don\'t have an account?',
                              style:
                                  TextStyle(
                                fontSize: 12.sp,
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
                                              .pushNamed(
                                            context,
                                            '/signup',
                                          );
                                        },
                              child: Text(
                                'Create Account',
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
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(
                              Icons
                                  .verified_user_outlined,
                              size: 15.sp,
                              color:
                                  Colors.grey,
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            Text(
                              'Secure authentication',
                              style:
                                  TextStyle(
                                fontSize: 10.sp,
                                color:
                                    Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginTypeButton({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected
          ? const Color(0xFFFFB91F)
          : Colors.transparent,
      borderRadius:
          BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(10.r),
        child: Padding(
          padding:
              EdgeInsets.symmetric(
            vertical: 11.h,
            horizontal: 6.w,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17.sp,
                color: selected
                    ? Colors.black
                    : Colors.grey,
              ),
              SizedBox(width: 6.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight:
                      FontWeight.w700,
                  color: selected
                      ? Colors.black
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}