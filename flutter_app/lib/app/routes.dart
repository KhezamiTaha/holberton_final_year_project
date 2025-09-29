import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutterquiz/ui/screens/app_settings_screen.dart';
import 'package:flutterquiz/ui/screens/auth/otp_screen.dart';
import 'package:flutterquiz/ui/screens/auth/sign_in_screen.dart';
import 'package:flutterquiz/ui/screens/auth/sign_up_screen.dart';
import 'package:flutterquiz/ui/screens/home/home_screen.dart';
import 'package:flutterquiz/ui/screens/home/setting_screen.dart';
import 'package:flutterquiz/ui/screens/initial_language_selection_screen.dart';
import 'package:flutterquiz/ui/screens/menu/menu_screen.dart';
import 'package:flutterquiz/ui/screens/onboarding_screen.dart';
import 'package:flutterquiz/ui/screens/profile/create_or_edit_profile_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/category_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/levels_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/result_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/review_answers_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/subcategory_and_level_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/subcategory_screen.dart';
import 'package:flutterquiz/ui/screens/splash_screen.dart';


class Routes {
  static const home = '/';
  static const login = 'login';
  static const splash = 'splash';
  static const signUp = 'signUp';
  static const introSlider = 'introSlider';
  static const selectProfile = 'selectProfile';
  static const quiz = '/quiz';
  static const subcategoryAndLevel = '/subcategoryAndLevel';
  static const subCategory = '/subCategory';

  static const result = '/result';
  static const category = '/category';
  static const profile = '/profile';
  static const editProfile = '/editProfile';

  static const settings = '/settings';
  static const reviewAnswers = '/reviewAnswers';
  static const logOut = '/logOut';

  static const appSettings = '/appSettings';
  static const levels = '/levels';
  static const otpScreen = '/otpScreen';
  static const menuScreen = '/menuScreen';
  static const languageSelect = '/language-select';

  static String currentRoute = splash;

  static Route<dynamic>? onGenerateRouted(RouteSettings routeSettings) {
    //to track current route
    //this will only track pushed route on top of previous route
    currentRoute = routeSettings.name ?? '';

    log(name: 'Current Route', currentRoute);

    switch (routeSettings.name) {
      case splash:
        return CupertinoPageRoute(builder: (_) => const SplashScreen());
      case home:
        return HomeScreen.route(routeSettings);
      case introSlider:
        return CupertinoPageRoute(builder: (_) => const IntroSliderScreen());
      case login:
        return CupertinoPageRoute(builder: (_) => const SignInScreen());
      case signUp:
        return CupertinoPageRoute(builder: (_) => const SignUpScreen());
      case otpScreen:
        return OtpScreen.route(routeSettings);
      case subcategoryAndLevel:
        return SubCategoryAndLevelScreen.route(routeSettings);
      case selectProfile:
        return CreateOrEditProfileScreen.route(routeSettings);
      case quiz:
        return QuizScreen.route(routeSettings);
      case menuScreen:
        return MenuScreen.route(routeSettings);
      case result:
        return ResultScreen.route(routeSettings);
      case reviewAnswers:
        return ReviewAnswersScreen.route(routeSettings);
      case category:
        return CategoryScreen.route(routeSettings);
      case settings:
        return SettingScreen.route(routeSettings);
      case appSettings:
        return AppSettingsScreen.route(routeSettings);
      case levels:
        return LevelsScreen.route(routeSettings);
      case subCategory:
        return SubCategoryScreen.route(routeSettings);
      case languageSelect:
        return InitialLanguageSelectionScreen.route();
      default:
        return CupertinoPageRoute(builder: (_) => const Scaffold());
    }
  }
}
