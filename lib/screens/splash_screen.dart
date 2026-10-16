import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final UserService _userService = UserService();

  late final AnimationController _logoController;
  late final AnimationController _contentController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  User? _user;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 850,
      ),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 700,
      ),
    );

    _logoScale = Tween<double>(
      begin: 0.65,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(
        0,
        0.18,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    _loadUser();
  }

  Future<void> _loadUser() async {
    _logoController.forward();

    final user =
        await _userService.getUser();

    if (!mounted) {
      return;
    }

    setState(() {
      _user = user;
    });

    await _contentController.forward();

    await Future.delayed(
      const Duration(
        milliseconds: 1800,
      ),
    );

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final name =
        _user?.fullName.isNotEmpty == true
            ? _user!.fullName
            : _user?.username ?? '';

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
                    const Color(
                      0xFF121212,
                    ),
                    const Color(
                      0xFF252525,
                    ),
                  ]
                : [
                    const Color(
                      0xFFFFF5D6,
                    ),
                    Colors.white,
                  ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -85.h,
              right: -75.w,
              child: Container(
                width: 230.w,
                height: 230.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(
                    0xFFFFB91F,
                  ).withValues(
                    alpha: 0.14,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -100.h,
              left: -95.w,
              child: Container(
                width: 270.w,
                height: 270.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(
                    0xFFFFB91F,
                  ).withValues(
                    alpha: 0.09,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 28.w,
                      ),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: _logoFade,
                            child:
                                ScaleTransition(
                              scale:
                                  _logoScale,
                              child:
                                  Container(
                                width: 135.w,
                                height: 135.w,
                                decoration:
                                    BoxDecoration(
                                  gradient:
                                      const LinearGradient(
                                    begin:
                                        Alignment
                                            .topLeft,
                                    end:
                                        Alignment
                                            .bottomRight,
                                    colors: [
                                      Color(
                                        0xFFFFD65C,
                                      ),
                                      Color(
                                        0xFFFFB91F,
                                      ),
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    36.r,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color(
                                        0xFFFFB91F,
                                      ).withValues(
                                        alpha:
                                            0.35,
                                      ),
                                      blurRadius:
                                          35,
                                      offset:
                                          const Offset(
                                        0,
                                        14,
                                      ),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment:
                                      Alignment
                                          .center,
                                  children: [
                                    Icon(
                                      Icons
                                          .sports_basketball,
                                      size:
                                          77.sp,
                                      color:
                                          Colors
                                              .black,
                                    ),
                                    Positioned(
                                      right:
                                          13.w,
                                      bottom:
                                          14.h,
                                      child:
                                          Container(
                                        width:
                                            34.w,
                                        height:
                                            34.w,
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              Colors.black,
                                          shape:
                                              BoxShape.circle,
                                          border:
                                              Border.all(
                                            color:
                                                Colors.white,
                                            width:
                                                3,
                                          ),
                                        ),
                                        child:
                                            Icon(
                                          Icons
                                              .check,
                                          size:
                                              18.sp,
                                          color:
                                              Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 34.h,
                          ),

                          if (_user != null)
                            SlideTransition(
                              position:
                                  _contentSlide,
                              child:
                                  FadeTransition(
                                opacity:
                                    _contentFade,
                                child:
                                    Column(
                                  mainAxisSize:
                                      MainAxisSize
                                          .min,
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets
                                              .symmetric(
                                        horizontal:
                                            12.w,
                                        vertical:
                                            6.h,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color:
                                            const Color(
                                          0xFFFFB91F,
                                        ).withValues(
                                          alpha:
                                              0.15,
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          30.r,
                                        ),
                                      ),
                                      child:
                                          Text(
                                        'LOGIN SUCCESSFUL',
                                        style:
                                            TextStyle(
                                          fontSize:
                                              9.sp,
                                          fontWeight:
                                              FontWeight.w800,
                                          letterSpacing:
                                              1,
                                          color:
                                              const Color(
                                            0xFFE69B00,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(
                                      height:
                                          14.h,
                                    ),

                                    Text(
                                      'Welcome back,',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            17.sp,
                                        color:
                                            Colors.grey,
                                        fontWeight:
                                            FontWeight.w500,
                                      ),
                                    ),

                                    SizedBox(
                                      height:
                                          5.h,
                                    ),

                                    Text(
                                      name,
                                      textAlign:
                                          TextAlign.center,
                                      style:
                                          TextStyle(
                                        fontSize:
                                            29.sp,
                                        fontWeight:
                                            FontWeight.w900,
                                      ),
                                    ),

                                    SizedBox(
                                      height:
                                          9.h,
                                    ),

                                    Text(
                                      '@${_user!.username}',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            12.sp,
                                        color:
                                            Colors.grey,
                                        fontWeight:
                                            FontWeight.w500,
                                      ),
                                    ),

                                    SizedBox(
                                      height:
                                          20.h,
                                    ),

                                    Text(
                                      'Your account is ready.\nLet\'s get you back in the game.',
                                      textAlign:
                                          TextAlign.center,
                                      style:
                                          TextStyle(
                                        fontSize:
                                            12.sp,
                                        height:
                                            1.5,
                                        color:
                                            Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 30.h,
                    child:
                        FadeTransition(
                      opacity: _logoFade,
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 190.w,
                            child:
                                ClipRRect(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20.r,
                              ),
                              child:
                                  LinearProgressIndicator(
                                minHeight:
                                    5.h,
                                color:
                                    const Color(
                                  0xFFFFB91F,
                                ),
                                backgroundColor:
                                    Colors.grey
                                        .withValues(
                                  alpha:
                                      0.18,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 13.h,
                          ),

                          Text(
                            'Preparing your HoopsHub...',
                            style:
                                TextStyle(
                              fontSize:
                                  11.sp,
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
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