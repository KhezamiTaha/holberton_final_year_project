
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';

import 'package:flutterquiz/features/quiz/cubits/set_category_played_cubit.dart';

import 'package:flutterquiz/features/quiz/cubits/subcategory_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlocked_level_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/update_level_cubit.dart';

import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/radial_result_container.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/custom_image.dart';
import 'package:flutterquiz/ui/widgets/custom_rounded_button.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:lottie/lottie.dart';
import 'package:screenshot/screenshot.dart';


class ResultScreen extends StatefulWidget {
  const ResultScreen({
    required this.isPremiumCategory,
    super.key,
    this.timeTakenToCompleteQuiz,
    this.hasUsedAnyLifeline,
    this.myPoints,
    this.questions,
    this.unlockedLevel,
    this.quizType,
    this.subcategoryMaxLevel,
    this.categoryId,
    this.subcategoryId,
  });

  final QuizTypes?
      quizType; //to show different kind of result data for different quiz type

  final int?
      myPoints; // 
  final List<Question>? questions; //to see review answers

  //if quizType is quizZone then it will be in use
  //to determine to show next level button
  //it will be in use if quizType is quizZone
  final String? subcategoryMaxLevel;

  //to determine if we need to update level or not
  //it will be in use if quizType is quizZone
  final int? unlockedLevel;

  //Time taken to complete the quiz in seconds
  final double? timeTakenToCompleteQuiz;

  //has used any lifeline - it will be in use to check badge earned or not for
  //quizZone quiz type
  final bool? hasUsedAnyLifeline;

  final String? categoryId;
  final String? subcategoryId;

  //This will be in use if quizType is  questions

  final bool isPremiumCategory;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments! as Map;

    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          //to update unlocked level for given subcategory
          BlocProvider<UpdateLevelCubit>(
            create: (_) => UpdateLevelCubit(QuizRepository()),
          ),
          //to update user score and coins
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
          ),
          //set quiz category played
          BlocProvider<SetCategoryPlayed>(
            create: (_) => SetCategoryPlayed(QuizRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],
        child: ResultScreen(
          categoryId: args['categoryId'] as String? ?? '',
          hasUsedAnyLifeline: args['hasUsedAnyLifeline'] as bool?,
          myPoints: args['myPoints'] as int?,
          questions: args['questions'] as List<Question>?,
          quizType: args['quizType'] as QuizTypes?,
          subcategoryId: args['subcategoryId'] as String? ?? '',
          subcategoryMaxLevel: args['subcategoryMaxLevel'] as String?,
          timeTakenToCompleteQuiz: args['timeTakenToCompleteQuiz'] as double?,
          unlockedLevel: args['unlockedLevel'] as int?,
          isPremiumCategory: args['isPremiumCategory'] as bool? ?? false,
        ),
      ),
    );
  }

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ScreenshotController screenshotController = ScreenshotController();
  List<Map<String, dynamic>> usersWithRank = [];
  late final String userName;
  late bool _isWinner;
  int _earnedCoins = 0;
  

  bool _displayedAlreadyLoggedInDialog = false;

  late final didSkipQue = widget.quizType == QuizTypes.quizZone &&
      widget.questions!.map((e) => e.submittedAnswerId).contains('0');

  @override
  void initState() {
    super.initState();

    //decide winner
    if (winPercentage() >=
        context.read<SystemConfigCubit>().quizWinningPercentage) {
      _isWinner = true;
    } else {
      _isWinner = false;
    }
    //earn coins based on percentage
    earnCoinsBasedOnWinPercentage();
    userName = context.read<UserDetailsCubit>().getUserName();

    Future.delayed(Duration.zero, () {
      //earnBadge will check the condition for unlocking badges and
      //will return true or false
      //we need to return bool value so we can pass this to
      //updateScoreAndCoinsCubit since dashing_debut badge will unlock
      //from set_user_coin_score api
      // ! holback _earnBadges();
      _updateScoreAndCoinsDetails();

      fetchUpdateUserDetails();
    });
  }

  Future<void> fetchUpdateUserDetails() async {
    if (widget.quizType == QuizTypes.quizZone) {
      await context.read<UserDetailsCubit>().fetchUserDetails();
    }
  }

  String _getCoinUpdateTypeBasedOnQuizZone() {
    return switch (widget.quizType) {
      QuizTypes.quizZone => wonQuizZoneKey,
      _ => '-',
    };
  }

  void _updateCoinsAndScore() {
    var points = widget.myPoints;
    if (widget.isPremiumCategory) {
      _earnedCoins = _earnedCoins * 2;
      points = widget.myPoints! * 2;
    }

    //update score and coins for user
    context.read<UpdateScoreAndCoinsCubit>().updateCoinsAndScore(
          widget.myPoints,
          _earnedCoins,
          _getCoinUpdateTypeBasedOnQuizZone(),
        );
    //update score locally and database
    context.read<UserDetailsCubit>().updateCoins(
          addCoin: true,
          coins: _earnedCoins,
        );

    context.read<UserDetailsCubit>().updateScore(points);
  }

  //
  void _updateScoreAndCoinsDetails() {
    //if percentage is more than 30 then update score and coins
    if (_isWinner) {
      //
      //if quizType is quizZone we need to update unlocked level,coins and score
      //only one time
      //
      if (widget.quizType == QuizTypes.quizZone) {
        //if given level is same as unlocked level then update level
        if (int.parse(widget.questions!.first.level!) == widget.unlockedLevel) {
          final updatedLevel = int.parse(widget.questions!.first.level!) + 1;
          //update level

          context.read<UpdateLevelCubit>().updateLevel(
                widget.categoryId!,
                widget.subcategoryId ?? '',
                updatedLevel.toString(),
              );

          _updateCoinsAndScore();
        }

        if (widget.subcategoryId == '0') {
          context.read<UnlockedLevelCubit>().fetchUnlockLevel(
                widget.categoryId!,
                '0',
              );
        } else {
          context.read<SubCategoryCubit>().fetchSubCategory(widget.categoryId!);
        }
      }
    }
    // fetchUpdateUserDetails();
  }

  void earnCoinsBasedOnWinPercentage() {
    if (_isWinner) {
      final percentage = winPercentage();
      _earnedCoins = UiUtils.coinsBasedOnWinPercentage(
        percentage: percentage,
        quizType: widget.quizType!,
        maxCoinsWinningPercentage:
            context.read<SystemConfigCubit>().maxCoinsWinningPercentage,
        maxWinningCoins: context.read<SystemConfigCubit>().maxWinningCoins,
      );
    }
  }

  //This will execute once user press back button or go back from result screen
  //so respective data of category,sub category 
  void onPageBackCalls() {
    if (widget.quizType == QuizTypes.quizZone) {
      if (widget.subcategoryId == '') {
        context.read<UnlockedLevelCubit>().fetchUnlockLevel(
              widget.categoryId!,
              '0',
            );
      } else {
        context.read<SubCategoryCubit>().fetchSubCategory(widget.categoryId!);
      }
    }
    fetchUpdateUserDetails();
  }

  String getCategoryIdOfQuestion() {
    return widget.questions!.first.categoryId!.isEmpty
        ? '-'
        : widget.questions!.first.categoryId!;
  }

  int correctAnswer() {
    var correctAnswer = 0;
    for (final question in widget.questions!) {
      if (AnswerEncryption.decryptCorrectAnswer(
            rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
            correctAnswer: question.correctAnswer!,
          ) ==
          question.submittedAnswerId) {
        correctAnswer++;
      }
    }
    return correctAnswer;
  }

  int attemptedQuestion() {
    var attemptedQuestion = 0;

    for (final question in widget.questions!) {
      if (question.attempted) {
        attemptedQuestion++;
      }
    }

    return attemptedQuestion;
  }

  double winPercentage() {
    
    return (correctAnswer() * 100.0) / totalQuestions();
  }

  bool showCoinsAndScore() {


    if (widget.quizType == QuizTypes.quizZone) {
      return _isWinner &&
          (int.parse(widget.questions!.first.level!) == widget.unlockedLevel);
    }
    return _isWinner;
  }

  int totalQuestions() {


    if (didSkipQue) {
      return widget.questions!.length - 1;
    }

    return widget.questions!.length;
  }

  Widget _buildGreetingMessage() {
    final String title;
    final String message;


      final scorePct = winPercentage();

      if (scorePct <= 30) {
        title = goodEffort;
        message = keepLearning;
      } else if (scorePct <= 50) {
        title = wellDone;
        message = makingProgress;
      } else if (scorePct <= 70) {
        title = greatJob;
        message = closerToMastery;
      } else if (scorePct <= 90) {
        title = excellentWork;
        message = keepGoing;
      } else {
        title = fantasticJob;
        message = achievedMastery;
      }

    final titleStyle = TextStyle(
      fontSize: 26,
      color: Theme.of(context).colorScheme.onTertiary,
      fontWeight: FontWeights.bold,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr(title)!,
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
              if (true) ...[
                Flexible(
                  child: Text(
                    " ${userName.split(' ').first}",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 26,
                      color: Theme.of(context).primaryColor,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeights.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 5),
        Container(
          alignment: Alignment.center,
          width: context.shortestSide * .85,
          child: Text(
            context.tr(message)!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultDataWithIconContainer(
    String title,
    String icon,
    EdgeInsetsGeometry margin,
  ) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      // padding: const EdgeInsets.all(10),
      width: context.width * (0.2125),
      height: 33,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onTertiary,
              BlendMode.srcIn,
            ),
            width: 19,
            height: 19,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
              fontWeight: FontWeights.bold,
              fontSize: 18,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualResultContainer(String userProfileUrl) {
    final lottieAnimation = _isWinner
        ? 'assets/animations/confetti.json'
        : 'assets/animations/defeats.json';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// Don't show any
        if (true) ...[
          Align(
            alignment: Alignment.topCenter,
            child: Lottie.asset(lottieAnimation, fit: BoxFit.fill),
          ),
        ],
        Align(
          alignment: Alignment.topCenter,
          child: LayoutBuilder(
            builder: (context, constraints) {
              var verticalSpacePercentage = 0.0;

              var radialSizePercentage = 0.0;
              if (constraints.maxHeight <
                  UiUtils.profileHeightBreakPointResultScreen) {
                verticalSpacePercentage = 0.015;
                radialSizePercentage = 0.6;
              } else {
                verticalSpacePercentage = 0.035;
                radialSizePercentage = 0.525;
              }

              return Column(
                children: [
                  _buildGreetingMessage(),
                  SizedBox(
                    height: constraints.maxHeight * verticalSpacePercentage,
                  ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        QImage.circular(
                          imageUrl: userProfileUrl,
                          width: 107,
                          height: 107,
                        ),
                        SvgPicture.asset(
                          Assets.hexagonFrame,
                          width: 132,
                          height: 132,
                        ),
                      ],
                    ),
                    const SizedBox(),
                ],
              );
            },
          ),
        ),

        //incorrect answer
        Align(
          alignment: AlignmentDirectional.bottomStart,
          child: _buildResultDataWithIconContainer(
            '${totalQuestions() - correctAnswer()}/${totalQuestions()}',
            Assets.wrong,
            EdgeInsetsDirectional.only(
              start: 15,
              bottom: showCoinsAndScore() ? 20.0 : 30.0,
            ),
          ),
        ),
        //correct answer
        if (showCoinsAndScore())
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: _buildResultDataWithIconContainer(
              '${correctAnswer()}/${totalQuestions()}',
              Assets.correct,
              const EdgeInsetsDirectional.only(start: 15, bottom: 60),
            ),
          )
        else
          Align(
            alignment: Alignment.bottomRight,
            child: _buildResultDataWithIconContainer(
              '${correctAnswer()}/${totalQuestions()}',
              Assets.correct,
              const EdgeInsetsDirectional.only(end: 15, bottom: 30),
            ),
          ),

        //points
        if (showCoinsAndScore())
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: _buildResultDataWithIconContainer(
              '${widget.myPoints}',
              Assets.score,
              const EdgeInsetsDirectional.only(end: 15, bottom: 60),
            ),
          )
        else
          const SizedBox(),

        //earned coins
        if (showCoinsAndScore())
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: _buildResultDataWithIconContainer(
              '$_earnedCoins',
              Assets.earnedCoin,
              const EdgeInsetsDirectional.only(end: 15, bottom: 20),
            ),
          )
        else
          const SizedBox(),

        //build radial percentage container
          Align(
            alignment: Alignment.bottomCenter,
            child: LayoutBuilder(
              builder: (context, constraints) {
                var radialSizePercentage = 0.0;
                if (constraints.maxHeight <
                    UiUtils.profileHeightBreakPointResultScreen) {
                  radialSizePercentage = 0.4;
                } else {
                  radialSizePercentage = 0.325;
                }
                return Transform.translate(
                  offset: const Offset(0, 15),
                  child: RadialPercentageResultContainer(
                    percentage: winPercentage(),
                    timeTakenToCompleteQuizInSeconds:
                        widget.timeTakenToCompleteQuiz?.toInt(),
                    size: Size(
                      constraints.maxHeight * radialSizePercentage,
                      constraints.maxHeight * radialSizePercentage,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }



  Widget _buildResultDetails(BuildContext context) {
    final userProfileUrl =
        context.read<UserDetailsCubit>().getUserProfile().profileUrl ?? '';

      return _buildIndividualResultContainer(userProfileUrl);


    
  }

  Widget _buildResultContainer(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Container(
        height: context.height * (0.560),
        width: context.width * (0.90),
        decoration: BoxDecoration(
          color: _isWinner
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.onTertiary.withValues(alpha: .05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: _buildResultDetails(context),
      ),
    );
  }

  Widget _buildButton(
    String buttonTitle,
    Function onTap,
    BuildContext context,
  ) {
    return CustomRoundedButton(
      widthPercentage: 0.90,
      backgroundColor: Theme.of(context).primaryColor,
      buttonTitle: buttonTitle,
      radius: 8,
      elevation: 5,
      showBorder: false,
      fontWeight: FontWeights.regular,
      height: 50,
      titleColor: Theme.of(context).colorScheme.surface,
      onTap: onTap as VoidCallback,
      textSize: 20,
    );
  }

  //play again button will be build different for every quizType
  Widget _buildPlayAgainButton() {   // * play agin or play next
     if (widget.quizType == QuizTypes.quizZone) {
      //if user is winner
      if (_isWinner) {
        //we need to check if currentLevel is last level or not
        final maxLevel = int.parse(widget.subcategoryMaxLevel!);
        final currentLevel = int.parse(widget.questions!.first.level!);
        if (maxLevel == currentLevel) {
          return const SizedBox.shrink();
        }
        return _buildButton(
          context.tr('nextLevelBtn')!,
          () {
            //if given level is same as unlocked level then we need to update level
            //else do not update level
            final unlockedLevel = int.parse(widget.questions!.first.level!) ==
                    widget.unlockedLevel
                ? (widget.unlockedLevel! + 1)
                : widget.unlockedLevel;
            //play quiz for next level
            Navigator.of(context).pushReplacementNamed(
              Routes.quiz,
              arguments: {
                
                'quizType': widget.quizType,
                //if subcategory id is empty for question means we need to fetch question by it's category
                'categoryId': widget.categoryId,
                'subcategoryId': widget.subcategoryId,
                'level': (currentLevel + 1).toString(),
                //increase level
                'subcategoryMaxLevel': widget.subcategoryMaxLevel,
                'unlockedLevel': unlockedLevel,
              },
            );
          },
          context,
        );
      }
      //if user failed to complete this level
      return _buildButton(
        context.tr('playAgainBtn')!,
        () {
          fetchUpdateUserDetails();
          //to play this level again (for quizZone quizType)
          Navigator.of(context).pushReplacementNamed(
            Routes.quiz,
            arguments: {
              
              'quizType': widget.quizType,
              //if subcategory id is empty for question means we need to fetch questions by it's category
              'categoryId': widget.categoryId,
              'subcategoryId': widget.subcategoryId,
              'level': widget.questions!.first.level,
              'unlockedLevel': widget.unlockedLevel,
              'subcategoryMaxLevel': widget.subcategoryMaxLevel,
            },
          );
        },
        context,
      );
    }

    return const SizedBox.shrink();
  }

  



  Widget _buildReviewAnswersButton() {
    // void onTapYesReviewAnswers() {   //! holback  review button
      
      
    //   Navigator.of(context).pushNamed(
    //     Routes.reviewAnswers,
    //     arguments:  {
    //             'quizType': widget.quizType,
    //             'questions': widget.questions,
                
    //           },
    //   );
    // }

    return _buildButton(
      context.tr('reviewAnsBtn')!,
      () {
        
          Navigator.of(context).pushNamed(
            Routes.reviewAnswers,
            arguments: {
                    'quizType': widget.quizType,
                    'questions': widget.questions,
                    
                  },
          );
          return;
      },
      context,
    );
  }

  Widget _buildHomeButton() {
    void onTapHomeButton() {
      fetchUpdateUserDetails();
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.home,
        (_) => false,
        arguments: false,
      );
    }

    return _buildButton(
      context.tr('homeBtn')!,
      onTapHomeButton,
      context,
    );
  }

  Widget _buildResultButtons(BuildContext context) {
    const buttonSpace = SizedBox(height: 15);

    return Column(
      children: [
        if (true) ...[
          _buildPlayAgainButton(),
          buttonSpace,
        ],
        if (widget.quizType == QuizTypes.quizZone ) ...[
          _buildReviewAnswersButton(),
          buttonSpace,
        ],
        
        buttonSpace,
        _buildHomeButton(),
        buttonSpace,
      ],
    );
  }

  String get _appbarTitle {
    final title = switch (widget.quizType) {
      _ => 'quizResultLbl',
    };

    return context.tr(title)!;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          context.read<UserDetailsCubit>().state is! UserDetailsFetchInProgress,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        onPageBackCalls();
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<UpdateScoreAndCoinsCubit, UpdateScoreAndCoinsState>(
            listener: (context, state) {
              if (state is UpdateScoreAndCoinsFailure) {
                if (state.errorMessage == errorCodeUnauthorizedAccess) {
                  //already showed already logged in from other api error
                  if (!_displayedAlreadyLoggedInDialog) {
                    _displayedAlreadyLoggedInDialog = true;
                    showAlreadyLoggedInDialog(context);
                    return;
                  }
                }
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: QAppBar(
            roundedAppBar: false,
            title: Text(_appbarTitle),
            onTapBackButton: () {
              onPageBackCalls();
              Navigator.pop(context);
            },
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Center(child: _buildResultContainer(context)),
                const SizedBox(height: 20),
                _buildResultButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
